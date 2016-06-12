import 'package:tradem_srv/Srv.dart' as Srv;
import 'package:embla/http.dart';
import 'package:embla/http_basic_middleware.dart';
import 'package:trestle/gateway.dart';
import 'package:embla_trestle/embla_trestle.dart';

export 'package:embla/application.dart';
export 'package:embla/bootstrap.dart';

var driver = new InMemoryDriver();

get embla => [
  new DatabaseBootstrapper(
    driver: driver
  ),
  new Srv.HttpsBootstrapper(
    port: 9090,
    pipeline: pipe(
      LoggerMiddleware, Srv.CORSMiddleware,
      Route.post('login/', Srv.JwtLoginMiddleware),
      RemoveTrailingSlashMiddleware, InputParserMiddleware,
      Route.all('users/*', Srv.JwtAuthMiddleware, Srv.UserService)
    )
  ),
  new Srv.TrademSrv()
];
