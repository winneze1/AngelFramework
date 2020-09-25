import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future configureServer(Angel app) async {
  final db = Db('mongodb://localhost:27017/angel');

  await db.open();

  app.container.registerNamedSingleton('datastore', db.collection('articles'));
}
