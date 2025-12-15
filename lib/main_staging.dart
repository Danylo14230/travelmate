import 'main.dart';
import 'env/env_staging.dart';

Future<void> main() async {
  await runAppWithEnv(StagingEnv());
}
