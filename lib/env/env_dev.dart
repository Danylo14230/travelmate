import 'env.dart';

class DevEnv implements AppEnv {
  @override
  String get name => 'dev';

  @override
  String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL_DEV');

  @override
  String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY_DEV');

  @override
  bool get enableCrashlytics => false;
}
