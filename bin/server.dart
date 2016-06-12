import 'dart:mirrors';
import 'dart:io';
import 'package:tradem_srv/Srv.dart' as Srv;
import 'package:embla/http.dart';
import 'package:embla/http_basic_middleware.dart';
import 'package:embla/application.dart';

export 'package:embla/application.dart';
export 'package:embla/bootstrap.dart';

get embla => [
  new Srv.HttpsBootstrapper(
    port: 9090,
    pipeline: pipe(
      Route.all('login/', Srv.JwtLoginMiddleware),
      Route.all('users/*', Srv.JwtAuthMiddleware, Srv.UserService)
    )
  ),
  new Srv.TrademSrv()
];
