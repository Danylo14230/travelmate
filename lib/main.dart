import 'env/env_prod.dart';
import 'app.dart';

Future<void> main() async {
  await runAppWithEnv(ProdEnv());
}
