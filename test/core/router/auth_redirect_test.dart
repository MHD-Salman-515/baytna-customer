import 'package:baytna_customer/core/router/auth_redirect.dart';
import 'package:baytna_customer/features/auth/domain/entities/user.dart';
import 'package:baytna_customer/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const authed = AuthAuthenticated(User(id: 'u', phone: '+963911111111', countryId: 'c'));
  const guest = AuthUnauthenticated();
  const unknown = AuthUnknown();
  String? go(AuthState s, String loc) => authRedirect(s, Uri.parse(loc));

  group('bootstrapping', () {
    test('everything goes to splash, remembering the target', () {
      expect(go(unknown, '/splash'), isNull);
      expect(go(unknown, '/home'), '/splash?from=%2Fhome');
      expect(
        go(unknown, '/auth/otp?countryId=c&phone=%2B963911111111'),
        '/splash?from=%2Fauth%2Fotp%3FcountryId%3Dc%26phone%3D%252B963911111111',
      );
    });
  });

  group('unauthenticated', () {
    test('can reach the auth flow', () {
      expect(go(guest, '/auth/country'), isNull);
      expect(go(guest, '/auth/phone?countryId=c'), isNull);
    });

    test('cannot reach anything else', () {
      expect(go(guest, '/home'), '/auth/country');
      expect(go(guest, '/splash'), '/auth/country');
    });

    test('resumes an auth-flow page after a refresh, but never a private one', () {
      expect(go(guest, '/splash?from=%2Fauth%2Fphone%3FcountryId%3Dc'), '/auth/phone?countryId=c');
      expect(go(guest, '/splash?from=%2Fhome'), '/auth/country');
    });
  });

  group('authenticated', () {
    test('skips the auth flow and splash', () {
      expect(go(authed, '/auth/country'), '/home');
      expect(go(authed, '/auth/otp?countryId=c&phone=x'), '/home');
      expect(go(authed, '/splash'), '/home');
    });

    test('resumes a private page after a refresh', () {
      expect(go(authed, '/splash?from=%2Fhome'), '/home');
      expect(go(authed, '/home'), isNull);
    });

    test('does not resume into the auth flow or an external URL', () {
      expect(go(authed, '/splash?from=%2Fauth%2Fcountry'), '/home');
      expect(go(authed, '/splash?from=https%3A%2F%2Fevil.example'), '/home');
      expect(go(authed, '/splash?from=%2F%2Fevil.example'), '/home');
    });
  });
}
