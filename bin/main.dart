import 'dart:io';
import 'package:redstone/server.dart' as app;
import 'package:di/di.dart';
import "package:ini/ini.dart";
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_web_socket/redstone_web_socket.dart';

import 'package:SrvCommon/SrvCommon.dart' as Common;

/*Services*/
import 'package:BMSrv/BMSrv.dart';
import 'package:BMSrv/Services/RealEstateService.dart';
import 'package:BMSrv/Services/BasedOnGoogle/ImageService.dart';

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


startServer(Config config) {
  Init().then((var res){
      app.addPlugin(getMapperPlugin());
      app.addPlugin(Common.UserGroupPlugin);
      app.addPlugin(Common.AccessPlugin);
      app.addPlugin(getWebSocketPlugin());
      app.addModule(new Module()..bind(Common.DBAdapter));
      app.addModule(new Module()..bind(Common.EventSys));
      app.addModule(new Module()..bind(RealEstateService));
      app.addModule(new Module()..bind(ImageService));
      app.addModule(new Module()..bind(Config, toValue: config));
      setupConsoleLog();
      
      String localFile(path) => Platform.script.resolve(path).toFilePath();
      
      print(localFile('ssl/private.pem'));
      
      SecurityContext serverContext = new SecurityContext()
        ..useCertificateChain(localFile('ssl/certificate.pem'))
        ..usePrivateKey(localFile('ssl/private.pem'),
                        password: 'semplex!2#');
      
      var secureOptions = { 
        #context: serverContext
      };

      app.start(port: 8001, secureOptions: secureOptions);
    });
}

main(List<String> args) {
  if (args.isEmpty) return;
  new File(args[0]).readAsLines()
  .then((lines) => new Config.fromStrings(lines))
  .then((Config config){
    startServer(config);
  });
  
  
}
