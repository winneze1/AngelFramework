import 'package:angelframework/angelframework.dart' as angelframework;

import 'dart:io';

import 'package:angel_hot/angel_hot.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_container/mirrors.dart';

void main(List<String> arguments) async {
  var hot = HotReloader(() async {
    var app = Angel(reflector: MirrorsReflector());

    await app.configure(angelframework.configureServer);

    return app;
  }, [Directory('lib')]);

  var http = await hot.startServer('127.0.0.1', 8489);

  print('http://${http.address.address}:${http.port}');
}
