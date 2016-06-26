import 'dart:convert';
import "package:test/test.dart";
import 'package:trestle/gateway.dart';
import 'package:embla/http.dart';
import "package:embla/application.dart";
import 'package:embla/http_basic_middleware.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:SemplexClientCmn/Utils/HttpCommunicator/IOHttpCommunicator.dart';
import 'package:SemplexClientCmn/Utils/RestAdapter.dart';
import 'package:tradem_srv/Srv.dart' as Srv;

final Map config = {
  'username': 'postgres',
  'password': 'bno9mjc',
  'database': 'tradem'
};

/*
var driver = new Srv.PostgisPsqlDriver(username: config['username'],
                                       password: config['password'],
                                       database: config['database']);
*/

main() async {
  Application app;
  var driver = new InMemoryDriver();


  final String serverUrl = "http://localhost:9090";

  setUpAll(() async {
    List<Bootstrapper> bootstrappers = [
      new DatabaseBootstrapper(
        driver: driver
      ),
      new Srv.HttpsBootstrapper(
        port: 9090,
        pipeline: pipe(
          LoggerMiddleware, RemoveTrailingSlashMiddleware,
          Srv.InputParserMiddleware,
          Route.post('login/', Srv.JwtLoginMiddleware),
          Route.post('test/', (Srv.Input req) async {
            Map tmp = req.body;
            print(tmp);
            return 'ok';
          }),
          Route.all('users/*', Srv.JwtAuthMiddleware, Srv.UserFilter, Srv.UserService)
        )
      ),
      new Srv.TrademSrv()
    ];
    app = await Application.boot(bootstrappers);
  });
  tearDownAll(() async {
    await app.exit();
  });

  group("user service: ", () {

    IoHttpCommunicator cmn = new IoHttpCommunicator();
    RestAdapter rest = new RestAdapter(cmn);

    setUp(() async {
      print("---------------");
    });
    tearDown(() async {
      
    });

    test("create user", () async {
      var resp = await rest.Create("$serverUrl/users",
        { 'email' : 'gardi',
          'password' : 'bno9mjc'
      });
      resp = JSON.decode(resp);

      expect(resp, allOf([
        containsPair('msg', 'ok'),
        containsPair('userId', 1)
      ]));
    });

    test("create exist user user", () async {
      try {
        var resp = await rest.Create("$serverUrl/users",
          { 'email' : 'gardi',
            'password' : 'bno9mjc'
        });
      } catch(err) {
        IoHttpResponseAdapter resp = err;
        expect(resp.Status, /*Conflict*/409);
        expect(resp.Data, 'user exist');
      }
    });

    test(".split() splits the string on the delimiter", () {
      expect("foo,bar,baz", allOf([
        contains("foo"),
        isNot(startsWith("bar")),
        endsWith("baz")
      ]));
    });
  });
}
