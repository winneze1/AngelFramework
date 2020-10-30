import 'package:logger/logger.dart';

Logger getLogger(String callAPIs) {
  return Logger(printer: LoggerPrinter(callAPIs));
}

class LoggerPrinter extends LogPrinter {
  final String callAPIs;

  LoggerPrinter(this.callAPIs);

  @override
  // ignore: missing_return
  List<String> log(LogEvent event) {
    // TODO: implement log
    var color = PrettyPrinter.levelColors[event.level];
    var emoji = PrettyPrinter.levelEmojis[event.level];
    print(color('$emoji $callAPIs - ${event.message}'));
  }
}
