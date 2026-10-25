# Baytna — Customer App

Customer app for the Baytna home-services marketplace (Syria, Iraq): book
housekeepers for cleaning, cooking and ironing. Flutter + BLoC, Arabic-first
(RTL by default) with English as the secondary language.

> **Status — step 1 (foundation):** networking, session handling, phone + OTP
> login and a placeholder home screen. Booking, maps and other features come next.

- **Backend (staging):** `https://baytna-api-z7v9.onrender.com/api/v1`
- **Swagger:** https://baytna-api-z7v9.onrender.com/docs (request bodies only.
  Response shapes are not documented; see [Backend notes](#backend-notes))

---

## Run it

Requirements: Flutter 3.47 / Dart 3.13.

```bash
cp secrets.example.json secrets.json   # then paste the dev OTP key (see below)
flutter pub get
flutter run -d chrome --dart-define-from-file=secrets.json
```

In VS Code, the **"Baytna (staging, Chrome)"** launch configuration does the same.

> The staging server sleeps after inactivity (Render free tier). The first
> request can take **30–60 s**, and the app shows a "server is waking up" banner
> meanwhile. That's expected, not a bug.

### Dev OTP key

The backend never returns the OTP in its response. In staging, the last code
for a number can be read from `GET /dev/last-otp?phone=<E.164>` with the header
`x-dev-otp-key`. The app has a **debug-only** "Autofill code (dev mode)" button
on the OTP screen that uses it.

1. Get the key from the backend team.
2. Put it in **`secrets.json`** at the project root (gitignored, never commit it):
   ```json
   { "DEV_OTP_KEY": "…" }
   ```
3. Run with `--dart-define-from-file=secrets.json`.

Without the key the app runs normally and the button doesn't appear.

**Removed from release builds, not hidden.** In
[lib/core/dev/dev_otp.dart](lib/core/dev/dev_otp.dart), the key and
`DevOtp.enabled` are compile-time constants gated on `kDebugMode`, and every call
site is wrapped in `if (DevOtp.enabled)`. In profile/release builds that's
`if (false)`, so the compiler drops the class, the endpoint path, the header name
and the button. To check after changing it:

```bash
echo '{"DEV_OTP_KEY":"CANARY-123"}' > /tmp/canary.json
flutter build web --release --dart-define-from-file=/tmp/canary.json
grep -c -e CANARY-123 -e last-otp -e x-dev-otp-key build/web/main.dart.js   # → 0
```

### Environments

| `--dart-define`         | Default   | Meaning                                              |
|-------------------------|-----------|------------------------------------------------------|
| `APP_ENV`               | `staging` | `staging` or `production`                            |
| `API_BASE_URL`          | per env   | Overrides the base URL. **Required for production** until it has a URL, so a production build can't hit staging by accident. |

### Tests

```bash
flutter analyze                                 # must stay at zero issues
flutter test                                    # unit + bloc tests (no network)
dart run build_runner build --delete-conflicting-outputs   # after changing DI/models
flutter gen-l10n                                # after changing ARB files (also runs on build)
```

**Live end-to-end login** (real UI in Chrome against staging: country → phone →
dev OTP autofill → home → logout). Writes screenshots and the app's request log
(`log.txt`) to `build/e2e_screenshots/`. Needs a
[chromedriver](https://googlechromelabs.github.io/chrome-for-testing/) matching
your Chrome version, running on port 4444:

```bash
chromedriver --port=4444 &
flutter drive -d web-server --browser-name=chrome \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/login_e2e_test.dart \
  --dart-define-from-file=secrets.json
```

Use `-d web-server` (chromedriver owns the browser); `-d chrome` hangs after
launch. The test requests a real OTP, so wait 60 s between runs (cooldown).

---

## Structure

```
lib/
  main.dart                 bootstrap: DI → restore locale → AuthStarted → runApp
  app.dart                  MaterialApp.router, locale/RTL, global overlays
  core/
    config/                 AppConfig: environment, base URL, timeouts
    di/                     get_it + injectable (injection.config.dart is generated)
    error/                  sealed Failure hierarchy
    network/                Dio pipeline, ApiClient, interceptors, error mapping
    storage/                TokenStorage (flutter_secure_storage)
    localization/           ARB files, generated l10n, LocalizedText, LocaleCubit
    router/                 routes, go_router config, auth redirect policy
    theme/                  colors, Material 3 theme, Tajawal font
    widgets/                shared UI (PageScaffold, PrimaryButton, FailureView…)
    dev/                    debug-only tools (compiled out of release)
    utils/                  Result, JWT expiry, Ticker
  features/
    auth/                   phone + OTP login, session (AuthBloc)
      data/                 models, remote/local data sources, repository impl
      domain/               entities, repository interface, failures, PhoneNumber
      presentation/         blocs, screens, widgets
    countries/              GET /countries (data + domain only, used by auth)
    home/                   placeholder signed-in screen
```

### Request pipeline

Feature code only ever calls `ApiClient`. It gets the **unwrapped `data`
payload** back or a typed **`Failure`** thrown. It never sees the envelope or a
`DioException`.

```
ApiClient ─► WakeUpInterceptor ─► AcceptLanguage ─► AuthInterceptor ─► (log) ─► EnvelopeInterceptor ─► RefreshInterceptor ─► HTTP
```

| Piece | Job |
|---|---|
| `WakeUpInterceptor` | Flags requests slower than 4 s on `ServerStatus` (drives the waking-up banner). Retries 502/503/504 during a cold start. |
| `AuthInterceptor` | Attaches `Bearer <access>`. **Parks new requests while a refresh is running.** Refreshes up front if the JWT expires within 30 s. |
| `EnvelopeInterceptor` | `{success:true,data}` → `data`. Failure envelopes are parsed by `ApiError` (`message` may be a string *or* an array). |
| `RefreshInterceptor` | On 401: refresh once, then replay. If another request already rotated the token, replays without refreshing again. |
| `TokenRefresher` | **Single-flight** `POST /auth/refresh`: concurrent callers share one Future. A rejected refresh clears tokens and emits `SessionEvents.onExpired`, and AuthBloc signs out. Network errors keep the session. |
| `ErrorMapper` | `DioException` → `NetworkFailure`, `TimeoutFailure`, `ValidationFailure`, `UnauthorizedFailure`, `NotFoundFailure`, `RateLimitedFailure`, `ServerFailure`, `UnknownFailure`. |

Why single-flight matters: refresh tokens rotate on every use and the backend
has **reuse detection**. Presenting an already-rotated refresh token revokes
*every* session of that user. `test/core/network/api_pipeline_test.dart` checks
this against a fake backend that implements reuse detection: 10 concurrent 401s
cause exactly one refresh.

### Session & routing

`AuthBloc` (app-wide singleton) owns the session. Its states are `AuthUnknown`,
`AuthAuthenticated(user)` and `AuthUnauthenticated(sessionExpired)`. The router
re-runs `authRedirect` (a pure, tested function) on every state change:

- **unknown** → `/splash?from=<where you were going>`
- **unauthenticated** → only `/auth/*` is reachable
- **authenticated** → `/auth/*` and `/splash` redirect to `/home` (or back to `from`)

Auth screens take their inputs from the query string (`/auth/otp?countryId=…&phone=…`),
so a browser refresh mid-flow still works.

On startup with stored tokens, `GET /auth/me` validates the session. If the
server is unreachable or asleep, the cached user is used instead of logging out.

---

## Conventions for new features

Follow these so features stay consistent. `features/auth` is the reference
implementation.

1. **Folder layout:** `features/<name>/{data,domain,presentation}`.
   - `domain/`: entities (Equatable, no JSON), `abstract interface class XRepository`,
     feature failures. No Flutter or Dio imports.
   - `data/`: `*Model` with `json_serializable` + `toEntity()`, a `*RemoteDataSource`
     (1:1 with endpoints, uses `ApiClient`), and `*RepositoryImpl` registered with
     `@LazySingleton(as: XRepository)`.
   - `presentation/`: `bloc/<name>/` (bloc + `part` event/state files),
     `screens/`, `widgets/`.
2. **Networking:** use `ApiClient.get/post/patch/delete` with a `decode`
   callback. Pass `authenticated: false` for public endpoints. Never import Dio
   in a feature, and never touch the envelope.
3. **Errors:** repositories return `Result<T>` (`Ok`/`Err`) and wrap calls in
   `guard(...)`. When the backend encodes a specific case only in a message
   (like OTP "too many attempts"), map it in the repository to a
   `sealed class XFailure extends FeatureFailure` subtype so the UI can switch on it.
4. **Blocs:** explicit `sealed` events and `sealed` states with `final class`
   subtypes, so `switch` is exhaustive (the compiler flags a missing case).
   Form-like screens use one state class holding the data plus a sealed `status`
   (see `PhoneState`, `OtpState`). Screen blocs are `@injectable` (factory),
   created in the screen's `BlocProvider` via `getIt<XBloc>(param1: …)`.
   App-wide blocs are `@lazySingleton`. Cubits only for trivial single-value
   state (`LocaleCubit`).
5. **Strings:** no user-facing literals. Add keys to **both**
   `lib/core/localization/arb/app_ar.arb` (template) and `app_en.arb`, and use
   `context.l10n.key`. Show failures with `failure.message(context.l10n)`, never
   backend text. Backend `{ar, en}` objects → `LocalizedText`, resolved in the
   widget with `context.localize(text)`.
6. **RTL:** use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end`,
   never left/right. Phone numbers and codes are LTR: wrap inputs in
   `Directionality(textDirection: TextDirection.ltr)` and interpolated numbers in
   `ltrIsolate(...)`. Directional icons must mirror: check
   `IconData.matchTextDirection`, or wrap the icon in `DirectionalIcon`.
7. **Routing:** add paths to `AppRoutes`. Pass IDs through path/query
   parameters rather than `extra`, so web refresh and deep links work.
8. **Storage:** tokens and personal data go in `flutter_secure_storage`, never
   `SharedPreferences`.
9. **Lints:** `very_good_analysis` plus strict casts/inference/raw types. Keep it
   at zero issues.
10. **Tests:** bloc tests with `bloc_test` + `mocktail`. Network behaviour
    through `DioFactory` + `test/helpers/fake_backend.dart` (the real interceptor
    pipeline with a fake HTTP adapter).

---

## Backend notes

Observed against staging (not in Swagger). The error mapping is built on these:

| Situation | Response |
|---|---|
| Any success | `{ "success": true, "data": … }` |
| Any error | `{ "success": false, "error": { statusCode, message, error } }`. `message` is a **string or an array** of validation messages |
| OTP requested again within cooldown | `429 "Please wait before requesting another code"` → `RateLimitedFailure` |
| Wrong OTP | `400 "Invalid or expired code"` → `InvalidOtpCode` |
| 5th wrong attempt | `400 "Too many attempts — request a new code"` → `TooManyOtpAttempts` (code is burned) |
| `GET /dev/last-otp` without/with a wrong key | `404` (same as an unknown phone, by design) |
| Cold start | first request ~30–60 s (53 s observed) |

The resend cooldown (`OtpPolicy.resendCooldown`, 60 s) mirrors server behaviour.
`POST /auth/otp/request` returns only `{ message }`, with no cooldown field.

Known limitations:
- **Web token storage:** flutter_secure_storage on web encrypts with WebCrypto
  before writing to localStorage. That's better than plaintext but weaker than a
  device keystore.
- **Lost refresh response:** if `/auth/refresh` reaches the server but the
  response is lost (connection drops), the app still holds the old refresh
  token. Its next use triggers reuse detection, and the user is signed out
  cleanly. That's unavoidable with rotating tokens and is handled, not silent.
