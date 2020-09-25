import 'package:angel_framework/angel_framework.dart';
import 'package:angel_mongo/angel_mongo.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future configureServer(Angel app) async {
  final collection = app.container.findByName<DbCollection>('datastore');

  app.use('articles', MongoService(collection));
}
