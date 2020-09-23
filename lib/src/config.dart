import 'package:angel_framework/angel_framework.dart';
import 'package:angel_jael/angel_jael.dart';
import 'package:file/file.dart';

AngelConfigurer configurer(FileSystem fileSystem) => (Angel app) async {
      await app.configure(jael(fileSystem.directory('views')));
    };
