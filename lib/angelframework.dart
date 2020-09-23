import 'src/routes.dart' as routes;
import 'src/config.dart' as config;
import 'src/services.dart' as services;
import 'package:file/local.dart';
import 'package:angel_framework/angel_framework.dart';

Future configureServer(Angel app) async {
  var fs = const LocalFileSystem();
  await app.configure(config.configurer(fs));
  await app.configure(routes.configServer());
  await app.configure(services.configureServer);
}
