import 'package:baytna_customer/core/network/json.dart';
import 'package:baytna_customer/core/storage/token_storage.dart';
import 'package:baytna_customer/features/auth/data/models/user_model.dart';

/// `data` of POST /auth/otp/verify:
/// `{ accessToken, refreshToken, isNewUser, user }`.
class VerifyOtpResponse {
  const VerifyOtpResponse({
    required this.tokens,
    required this.isNewUser,
    required this.user,
  });

  factory VerifyOtpResponse.fromJson(Json json) => VerifyOtpResponse(
    tokens: AuthTokens.fromJson(json),
    isNewUser: json['isNewUser'] as bool? ?? false,
    user: UserModel.fromJson(asJson(json['user'])),
  );

  final AuthTokens tokens;
  final bool isNewUser;
  final UserModel user;
}
