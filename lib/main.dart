import 'package:baytna_customer/app.dart';
import 'package:baytna_customer/core/di/injection.dart';
import 'package:baytna_customer/core/localization/locale_cubit.dart';
import 'package:baytna_customer/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  // Western digits in Arabic dates too, like prices and phone numbers.
  DateFormat.useNativeDigitsByDefaultFor('ar', false);
  // Restore the language before the first frame to avoid an ar→en flash.
  await getIt<LocaleCubit>().load();
  getIt<AuthBloc>().add(const AuthStarted());
  runApp(const BaytnaApp());
}
