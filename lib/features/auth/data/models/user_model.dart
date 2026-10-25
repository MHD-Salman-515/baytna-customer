import 'package:baytna_customer/features/auth/domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(createToJson: true)
class UserModel {
  const UserModel({required this.id, required this.phone, this.locale});

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  final String id;
  final String phone;
  final String? locale;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() => User(id: id, phone: phone, locale: locale);
}
