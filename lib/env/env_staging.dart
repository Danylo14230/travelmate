import 'env.dart';

class StagingEnv implements AppEnv {
  @override
  String get name => 'staging';

  @override
  String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL_STAGING');

  @override
  String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY_STAGING');

  @override
  bool get enableCrashlytics => true;
}
