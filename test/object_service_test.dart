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

import './test_data/common_test.dart';

main() async {
  Application app;
  final String serverUrl = TestCommon.srvUrl;

  IoHttpCommunicator cmn = new IoHttpCommunicator();
  RestAdapter rest = new RestAdapter(cmn);

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
      Map<String, String> args = TestCommon.userData;
      HttpRequestAdapter req =
        new HttpRequestAdapter.Post("$serverUrl/login", args, null);
      try {
        IResponse resp = await cmn.SendRequest(req);
        if (resp.Status == 200) {
          final String authorization = resp.Headers["authorization"];
          cmn.AddDefaultHeaders("authorization", authorization);
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
