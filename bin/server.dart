import 'package:tradem_srv/Srv.dart' as Srv;
import 'package:embla/http.dart';
import 'package:embla/http_basic_middleware.dart';
import 'package:trestle/gateway.dart';
import 'package:embla_trestle/embla_trestle.dart';

export 'package:embla/application.dart';
export 'package:embla/bootstrap.dart';

final Map config = {
  'username': 'postgres',
  'password': 'bno9mjc',
  'database': 'tradem'
};


//var driver = new InMemoryDriver();

//*
var driver = new Srv.PostgisPsqlDriver(username: config['username'],
                                       password: config['password'],
                                       database: config['database']);
//*/

get embla => [
  new DatabaseBootstrapper(
    driver: driver
  ),
  new Srv.HttpsBootstrapper(
    port: 9090,
    pipeline: pipe(
      LoggerMiddleware, Srv.CORSMiddleware,
      Route.post('login/', Srv.JwtLoginMiddleware),
      RemoveTrailingSlashMiddleware, Srv.InputParserMiddleware,
      Route.all('users/*', Srv.JwtAuthMiddleware, Srv.UserIdFilter, Srv.UserService)
    )
  ),
  new Srv.TrademSrv()
];
