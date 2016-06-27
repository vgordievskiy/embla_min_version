import 'dart:convert';
import "package:test/test.dart";
import 'package:trestle/gateway.dart';
import 'package:embla/http.dart';
import "package:embla/application.dart";
import 'package:embla/http_basic_middleware.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:SemplexClientCmn/Utils/HttpCommunicator/IOHttpCommunicator.dart';
import 'package:SemplexClientCmn/Utils/Interfaces/ICommunicator.dart';
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

  IoHttpCommunicator cmn = new IoHttpCommunicator();
  RestAdapter rest = new RestAdapter(cmn);

  setUpAll(() async {
    List<Bootstrapper> bootstrappers = [
      new DatabaseBootstrapper(
        driver: driver
      ),
      new Srv.HttpsBootstrapper(
        port: 9090,
        pipeline: pipe(
          LoggerMiddleware, RemoveTrailingSlashMiddleware,
          Route.post('login/', Srv.JwtLoginMiddleware),
          Srv.InputParserMiddleware,
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

  group("user service creation: ", () {

    IoHttpCommunicator cmn = new IoHttpCommunicator();
    RestAdapter rest = new RestAdapter(cmn);

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

    test("create exist user", () async {
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
  });

  group("user service get and auth: ", () {

    setUpAll(() async {
      Map<String, String> args = {
        'username' : 'gardi',
        'password' : 'bno9mjc'
      };
      HttpRequestAdapter req =
        new HttpRequestAdapter.Post("$serverUrl/login", args, null);
      try {
        IResponse resp = await cmn.GetCommunicator().SendRequest(req);
        if (resp.Status == 200) {
          final String authorization = resp.Headers["authorization"];
          rest.GetCommunicator().AddDefaultHeaders("authorization", authorization);
        }
      } catch(e) {
        throw e;
      }
    });

    test("get user", () async {
      Map resp = await rest.Get("$serverUrl/users/1");
      expect(resp, allOf([
        containsPair('id', 1),
        containsPair('email', 'gardi')]));
    });
  });
}
