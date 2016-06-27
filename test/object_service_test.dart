import 'dart:convert';
import "package:test/test.dart";
import 'package:trestle/gateway.dart';
import 'package:embla/http.dart';
import "package:embla/application.dart";
import 'package:embla/http_basic_middleware.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:tradem_srv/Srv.dart' as Srv;

import './test_data/common_test.dart';

main() async {
  Application app;

  final String serverUrl = TestCommon.srvUrl;

  setUpAll(() async {
    List<Bootstrapper> bootstrappers = [
      new DatabaseBootstrapper(
        driver: TestCommon.driver
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

  group("user service get and auth: ", () {

    setUpAll(() async {
      await TestCommon.login();
    });

    test("get user", () async {
      Map resp = await TestCommon.net.Get("$serverUrl/${TestCommon.userUrl}");
      expect(resp, allOf([
        containsPair('id', 1),
        containsPair('email', 'gardi')]));
    });

    test("update user", () async {
      Map data = {'user' : 'test'};
      await TestCommon.net.Update("$serverUrl/${TestCommon.userUrl}/data", data);
      Map resp = await TestCommon.net.Get("$serverUrl/${TestCommon.userUrl}/data");
      expect(resp, data);
    });
  });
}
