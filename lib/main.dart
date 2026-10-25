import 'package:baytna_customer/app.dart';
import 'package:baytna_customer/core/di/injection.dart';
import 'package:baytna_customer/core/localization/locale_cubit.dart';
import 'package:baytna_customer/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  // Restore the language before the first frame to avoid an ar→en flash.
  await getIt<LocaleCubit>().load();
  getIt<AuthBloc>().add(const AuthStarted());
  runApp(const BaytnaApp());
}
