# Baytna — Customer App

Customer app for the Baytna home-services marketplace (Syria, Iraq): book
housekeepers for cleaning, cooking and ironing. Flutter + BLoC, Arabic-first
(RTL by default) with English as the secondary language.

> **Status — step 2 (minimum path to a booking):** services → browse workers by
> city → her profile → live price preview → free time → map pin + landmark →
> SCHEDULED booking → My bookings (status, frozen price, cancel with the fee
> shown first). Not yet: live tracking, share-trip, panic, reviews, trusted
> contacts, notifications, INSTANT bookings.
>
> **Booking needs one backend change before release** — see
> [Backend gaps](#backend-gaps): the public worker projection doesn't expose
> `workerServiceId`, which quoting and booking require.

- **Backend (staging):** `https://baytna-api-z7v9.onrender.com/api/v1`
- **Swagger:** https://baytna-api-z7v9.onrender.com/docs (request bodies only.
  Response shapes are not documented; see [Backend notes](#backend-notes))

---

## Run it

Requirements: Flutter 3.47 / Dart 3.13.

```bash
cp secrets.example.json secrets.json   # then paste the dev keys (see below)
flutter pub get
flutter run -d emulator-5556 --dart-define-from-file=secrets.json   # Android
flutter run -d chrome --dart-define-from-file=secrets.json          # or web
```

In VS Code, the **"Baytna (staging, Chrome)"** launch configuration runs the web build.
The main `AndroidManifest.xml` declares `INTERNET` (release builds need it, not
only debug) and the optional location permissions used by the address map.

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

### Dev worker-service ids (`DEV_WORKER_SERVICES`)

Quoting and booking need a `workerServiceId`, which the customer-facing worker
projection doesn't include yet ([Backend gaps](#backend-gaps)). Until it does,
a **debug** build can be given the ids:

```json
{ "DEV_WORKER_SERVICES": "<workerProfileId>/<serviceId>=<workerServiceId>;…" }
```

Staging today: `6adf1a91b4c4645d759bc2a0/6adbb9cad141d68e8737557b=6adf3e0f9915d0e047e12441`
(the one bookable worker, CLEANING). The app reads `workerServiceId` from the
API first, so this becomes dead weight the day the backend sends it. It is
compiled out of release exactly like the OTP key
([dev_worker_services.dart](lib/core/dev/dev_worker_services.dart)); a release
build shows the offering as "can't be booked in the app yet".

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
It also runs on Android: `flutter drive -d emulator-5556 …` with the same flags.

**Live end-to-end booking** (Android emulator, staging): a fresh random customer
signs in → CLEANING → picks Damascus → her profile → price preview (minimum
stated first, +1 h re-quoted) → a day and a free time → drags the map pin,
types a landmark → review → **creates a real booking** → opens it (phone hidden,
cancel fee previewed but not confirmed) → finds it in My bookings:

```bash
flutter drive -d emulator-5556 \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/booking_e2e_test.dart \
  --dart-define-from-file=secrets.json
```

To let the app ask for GPS, grant location after the APK installs
(`adb shell pm grant com.baytna.baytna_customer android.permission.ACCESS_FINE_LOCATION`);
`flutter drive` uninstalls at the end, so a grant beforehand doesn't stick.
On the API 36 emulator used here, neither `emu geo fix` nor shell test
providers produced a fresh fix (the emulator stayed in Mountain View), so the
location request times out after 10 s and the pin starts at the city centre,
which the screen says. On a real phone in the city the pin starts at her position.

**Re-verify without booking again:** to check an existing booking instead of
creating a new one, run the same test with
`--dart-define=E2E_VERIFY_ONLY=true --dart-define=E2E_PHONE=<its customer> --dart-define=E2E_BOOKING=<its number>`.
It walks the flow to the review, stops before confirming (no `POST /bookings`),
then opens that booking from My bookings. Each run leaves a real
PENDING_WORKER booking, which lapses after the country's response deadline.
Staging also has a **global per-IP throttle** on OTP requests: after a burst of
logins every number gets 429 for a while.

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
    geo/                    GeoPoint — the ONE place that knows GeoJSON is [lng, lat]
    time/                   CountryTime — dates/times in the country's zone
    location/               optional GPS (geolocator), never throws
    format/                 money
    utils/                  Result, JWT expiry, Ticker, Clock
  features/
    auth/                   phone + OTP login, session (AuthBloc)
      data/                 models, remote/local data sources, repository impl
      domain/               entities, repository interface, failures, PhoneNumber
      presentation/         blocs, screens, widgets
    countries/              GET /countries, incl. the per-country bookingPolicy
    cities/                 GET /cities?countryId= (paged), with a GeoJSON centre
    home/                   the service catalog + entry to My bookings
    services/               GET /services
    workers/                browse (GET /workers), profile (GET /workers/:id), slots
    pricing/                GET /pricing/quote, QuoteBloc, JobSize
    bookings/               create flow, list, detail, cancel; StartTimes,
                            CancellationFee, BookingFailure
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

## Booking: the decisions that matter

- **Only the server prices.** Every number on screen comes from
  `GET /pricing/quote` (before) or the booking's frozen `pricing` (after). The
  quote has no commission and no earnings, and neither does the app. `POST
  /bookings` never carries a price.
- **HOURLY minimum, said first.** A quote *without* `estimatedHours` returns her
  minimum (`hours: 2`): that's how the app learns `minHours`, which the public
  projection doesn't include. The minimum is stated in its own notice *above*
  the hours control, and the control can't go below it.
- **Times she can actually be booked at.** Start times come from
  `GET /workers/:id/slots` (free intervals; a job must *end* by the interval
  end), filtered for the past and the country's `bookingHorizonDays`, and shown
  in the **country's** timezone, not the phone's.
- **Pin and words.** OpenStreetMap (flutter_map, no key). The pin is fixed at the
  centre; she drags the map. It starts at her GPS fix only if she allows it *and*
  it's within 40 km of the booking city (an emulator in California, or booking for
  her mother elsewhere, falls back to the city centre). The **landmark is the
  first field**, written like any other, with a hint showing what a good one
  looks like.
- **Refusals in plain Arabic.** Overlap (409), beyond the horizon, outside her
  hours, in the past, city not served, missing landmark and an unavailable worker
  each have their own message ([booking_failures.dart](lib/features/bookings/domain/booking_failures.dart)).
  Time-related refusals send her back to freshly loaded times.
- **No double booking.** A 504 is never auto-retried for POST. If the create
  ends ambiguously (timeout, dropped connection, 5xx), the app looks for the
  booking among her PENDING ones before reporting failure, and never re-sends.
- **Phone hidden until accepted.** The backend's projection sends
  `workerPhone: null` until she ACCEPTS; the app shows only what it gets, with a
  sentence saying when the number will appear.
- **Cancellation fee shown first**, from the country's `freeCancellationHours` and
  `cancellationFeeBasisPoints`. Afterwards the server's `feeAmount` is shown.
- **Empty is normal.** With one bookable worker on staging, an empty city is an
  explained state that points to the city picker, not an error.

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
   Paginated endpoints use `ApiClient.getPage`, which keeps `meta`.
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
| Too many OTP requests from one IP | `429 "ThrottlerException: Too Many Requests"` for **any** number, for well over 5 min |
| `GET /workers`, `/workers/:id` | **401 without a bearer** (browsing requires sign-in). Paged, `meta` next to `data`, `limit` ≤ 100 |
| Worker projection | `{ id, displayName, profilePhotoUrl, bio{ar,en}, rating, cityId, serviceAreas[], services[{serviceId, serviceName, pricingType, displayPrice, currency}] }`. Same shape for list and detail. `displayName` is the literal `"Worker"` when unset; `rating` 0 = no reviews |
| `GET /workers/<malformed id>` | **500** (not 400/404) |
| `GET /pricing/quote` | `{ price, currency, pricingType, hours }`. `hours` is the effective value: below `minHours` (or omitted) → `minHours` |
| `GET /workers/:id/slots?date=` | `[{ start, end }]` free intervals (UTC). Exclude her bookings **plus the 30-min buffer**; **include past hours today** and **dates beyond the 90-day horizon** |
| `POST /bookings` body | `workerId` → **400 "property workerId should not exist"**. `cityId` is required and must be in her `serviceAreas`. `serviceId` is accepted |
| `POST /bookings` refusals | 409 overlap (incl. buffer) · 400 "may not be more than 90 days in the future" · 400 "falls outside her available hours" · 400 "must be in the future" · 400 "does not serve the selected city" · 400 "address.landmark should not be empty" · 404 "Worker service not found" |
| Booking payload | `{ id, bookingNumber, status, workerProfileId, serviceId, workerServiceId, countryId, cityId, type, scheduledFor, estimatedDurationMinutes, address, pricing{pricingType, hours, roomCount, basePrice, currency}, finalPricing, responseDeadline, acceptedAt, …, cancellation, workerPhone }`. No commission. `workerPhone: null` while PENDING_WORKER |
| `POST /bookings/:id/cancel` | Needs a non-empty `reason`. Late cancel (inside `freeCancellationHours`) charges `basePrice × bp / 10000` **even while PENDING_WORKER** (12,000 → 2,400). Cancellable from SEARCHING, PENDING_WORKER, ACCEPTED, ON_THE_WAY, ARRIVED |
| `GET /services` | `icon` is `null` on every service; the app picks a glyph by `key` |

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

## Backend gaps

Found while building the booking path; the app doesn't paper over them.

1. **`workerServiceId` isn't exposed to customers.** `GET /pricing/quote` and
   `POST /bookings` both require it, but `GET /workers` and `GET /workers/:id`
   list only `serviceId` per offering, and no customer route returns the id
   (`/workers/:id/services` → 404). A real customer **cannot quote or book**.
   Fix: add `workerServiceId` (the WorkerService `id`) to each element of
   `services[]` in the public projection. The app already reads it; until then a
   debug-only override supplies it (see *Dev worker-service ids*).
2. **No `minHours` or BY_SIZE tiers in the projection.** The app gets `minHours`
   from a quote without hours (works, costs a request). BY_SIZE tiers aren't
   available at all, so the app re-quotes per room count instead of showing a
   tier table. Fix: add `hourly.minHours` and `bySize.tiers` (prices, not
   commission) to the projection.
3. **Slots ignore "now" and the horizon.** `GET /workers/:id/slots` returns
   intervals that started in the past (today) and dates beyond
   `bookingHorizonDays`. The app filters both; other clients may not.
4. **Malformed ids return 500** (`GET /workers/bad`), not 400/404.
5. **The brief listed `workerId` as a booking field**; the server rejects it.

