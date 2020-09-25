import 'package:angel_framework/angel_framework.dart';
import 'package:angel_jael/angel_jael.dart';
import 'package:file/file.dart';
import 'package:code_buffer/code_buffer.dart';
import 'plugins.dart' as plugins;

AngelConfigurer configurer(FileSystem fileSystem) => (Angel app) async {
      await app.configure(jael(fileSystem.directory('views'),
          createBuffer: () => CodeBuffer.noWhitespace()));

      await plugins.configureServer(app);
    };
