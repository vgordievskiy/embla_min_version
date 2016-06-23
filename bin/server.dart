import 'package:tradem_srv/Srv.dart' as Srv;
import 'package:embla/http.dart';
import 'package:embla/http_basic_middleware.dart';
import 'package:trestle/gateway.dart';
import 'package:embla_trestle/embla_trestle.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http_server/src/http_body_impl.dart';
import 'package:http_server/src/http_body.dart';

export 'package:embla/application.dart';
export 'package:embla/bootstrap.dart';

final Map config = {
  'username': 'postgres',
  'password': 'bno9mjc',
  'database': 'tradem'
};


var driver = new InMemoryDriver();

/*
var driver = new Srv.PostgisPsqlDriver(username: config['username'],
                                       password: config['password'],
                                       database: config['database']);
*/

get embla => [
  new DatabaseBootstrapper(
    driver: driver
  ),
  new Srv.HttpsBootstrapper(
    port: 9090,
    pipeline: pipe(
      LoggerMiddleware, Srv.CORSMiddleware,
      Route.post('login/', Srv.JwtLoginMiddleware),
      Route.post('test/', (Request req) async {
        HttpBody tmp = await HttpBodyHandlerImpl.process(req.read(),
          new _HttpHeaders(req.headers, ContentType.parse(req.headers['content-type'])), UTF8);
        return tmp.type;
      }),
      RemoveTrailingSlashMiddleware, InputParserMiddleware,
      Route.all('users/*', Srv.JwtAuthMiddleware, Srv.UserFilter, Srv.UserService)
    )
  ),
  new Srv.TrademSrv()
];

class _HttpHeaders implements HttpHeaders {
  final Map<String, String> headers;
  ContentType _contentType;

  _HttpHeaders(this.headers, this._contentType);

  @override
  List<String> operator [](String name) {
    return headers[name].split(";");
  }

  @override
  ContentType get contentType => _contentType;

  @override
  void forEach(void f(String name, List<String> values)) {
    headers.forEach((k, v) => f(k, v.split(";")));
  }

  @override
  String value(String name) {
    return headers[name];
  }

  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
