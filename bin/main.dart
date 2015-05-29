import 'package:redstone/server.dart' as app;
import 'package:di/di.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/BMSrv.dart';
import 'package:BMSrv/Events/EventBus.dart';
import 'package:BMSrv/Utils/DbAdapter.dart';

import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';

List<String> filter = ["LoginService"]; 

void setupConsoleLog([Level level = Level.INFO]) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((LogRecord rec) {
    
    if (filter.contains(rec.loggerName)) return;
    
    if (rec.level >= Level.SEVERE) {
      var stack = rec.stackTrace != null ? "\n${Trace.format(rec.stackTrace)}" : "";
      print('[${rec.loggerName}] - ${rec.level.name}: ${rec.time}: ${rec.message} - ${rec.error}${stack}');
    } else {
      print('[${rec.loggerName}] - ${rec.level.name}: ${rec.time}: ${rec.message}');
    }
  });
}


main() {
  Init().then((var res){
    app.addPlugin(getMapperPlugin());
    app.addModule(new Module()..bind(DBAdapter));
    app.addModule(new Module()..bind(EventSys));
    setupConsoleLog();

    app.start(port: 8001);
  });
}
