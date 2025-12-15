import 'main.dart';
import 'env/env_prod.dart';

Future<void> main() async {
  await runAppWithEnv(ProdEnv());
}
