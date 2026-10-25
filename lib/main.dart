import 'package:baytna_customer/app.dart';
import 'package:baytna_customer/core/di/injection.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const BaytnaApp());
}
