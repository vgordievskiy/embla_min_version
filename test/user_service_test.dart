import 'dart:convert';
import "package:test/test.dart";
import 'package:embla/http.dart';
import "package:embla/application.dart";
import 'package:embla/http_basic_middleware.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:SemplexClientCmn/Utils/HttpCommunicator/IOHttpCommunicator.dart';
import 'package:SemplexClientCmn/Utils/RestAdapter.dart';
import 'package:tradem_srv/Srv.dart' as Srv;
import 'package:srv_base/Srv.dart' as base;
import 'package:tradem_srv/Config/Config.dart';
import 'package:tradem_srv/Services/UserService.dart';

import './test_data/common_test.dart';
import 'package:srv_base/Models/Users.dart';

main() async {
  AppConfig config = new AppConfig()
    ..isEnabledEmail = false;

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
          Route.post('login/', base.JwtLoginMiddleware),
          base.InputParserMiddleware,
          Route.post('test/', (base.Input req) async {
            Map tmp = req.body;
            print(tmp);
            return 'ok';
          }),
          Route.all('users/*', base.JwtAuthMiddleware,
            new base.UserGroupFilter(UserGroup.USER.Str), base.UserIdFilter,
            UserService)
        )
      ),
      new Srv.TrademSrv(config)
    ];
    app = await Application.boot(bootstrappers);
  });
  tearDownAll(() async {
    await app.exit();
  });

  group("user service creation: ", () {

    RestAdapter rest = TestCommon.net;

    test("create user", () async {
      var resp = await rest.Create("$serverUrl/users", TestCommon.userDataCreate);
      resp = JSON.decode(resp);

      expect(resp, allOf([
        containsPair('msg', 'ok'),
        containsPair('userId', 1)
      ]));
    });

    test("create exist user", () async {
      try {
        var resp = await rest.Create("$serverUrl/users",
                                     TestCommon.userDataCreate);
      } catch(err) {
        IoHttpResponseAdapter resp = err;
        expect(resp.Status, /*Conflict*/409);
        expect(resp.Data, 'user exist');
      }
    });
  });

  group("user service get and auth: ", () {

    setUpAll(() async {
      await TestCommon.login();
    });

    test("get user", () async {
      Map resp = await TestCommon.net.Get("$serverUrl/${TestCommon.userUrl}");
      expect(resp, allOf([
        containsPair('id', 1),
        containsPair('email', 'v.gordievskiy@gmail.com')]));
    });

    test("update user", () async {
      Map data = {'user' : 'test'};
      await TestCommon.net.Update("$serverUrl/${TestCommon.userUrl}/data", data);
      Map resp = await TestCommon.net.Get("$serverUrl/${TestCommon.userUrl}/data");
      expect(resp, data);
    });
  });
}
