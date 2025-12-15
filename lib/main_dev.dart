import 'main.dart';
import 'env/env_dev.dart';

Future<void> main() async {

  await runAppWithEnv(DevEnv());
}
