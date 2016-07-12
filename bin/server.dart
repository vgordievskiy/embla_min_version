import 'package:srv_base/Srv.dart' as base;
import 'package:embla/http.dart';
import 'package:embla/http_basic_middleware.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:tradem_srv/Services/UserService.dart';
import 'package:tradem_srv/Srv.dart' as Srv;
import 'package:tradem_srv/Config/Config.dart';

export 'package:embla/application.dart';
export 'package:embla/bootstrap.dart';

final Map config = {
  'username': 'postgres',
  'password': 'bno9mjc',
  'database': 'tradem'
};


//var driver = new InMemoryDriver();

//*
var driver = new base.PostgisPsqlDriver(username: config['username'],
                                        password: config['password'],
                                        database: config['database']);
//*/

AppConfig getAppConfig() {
  AppConfig config = new AppConfig()
    ..isEnabledEmail = true
    ..emailLogin = 'service@semplex.ru'
    ..emailPassword = 'SSemplex!2#';
  return config;
}

get embla => [
  new DatabaseBootstrapper(
    driver: driver
  ),
  new base.HttpsBootstrapper(
    port: 9090,
    pipeline: pipe(
      LoggerMiddleware, base.CORSMiddleware,
      Route.post('login/', base.JwtLoginMiddleware),
      RemoveTrailingSlashMiddleware, base.InputParserMiddleware,
      Route.all('users/*', base.JwtAuthMiddleware, base.UserIdFilter, UserService)
    )
  ),
  new Srv.TrademSrv(getAppConfig())
];
