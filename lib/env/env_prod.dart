import 'env.dart';

class ProdEnv implements AppEnv {
  @override
  String get name => 'prod';

  @override
  String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL_PROD');

  @override
  String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY_PROD');

  @override
  bool get enableCrashlytics => true;
}
