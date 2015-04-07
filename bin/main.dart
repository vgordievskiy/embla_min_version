import 'package:redstone/server.dart' as app;
import 'package:di/di.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/BMSrv.dart';
import 'package:BMSrv/Events/EventBus.dart';
import 'package:BMSrv/Utils/DbAdapter.dart';
import 'package:BMSrv/Controllers/UserManager.dart';

main() {
  Init().then((var res){
    app.addPlugin(getMapperPlugin());
    app.addModule(new Module()..bind(DBAdapter));
    app.addModule(new Module()..bind(EventSys));
    app.addModule(new Module()..bind(UserManager));
    app.setupConsoleLog();

    app.start(port: 8001);
  });
}
