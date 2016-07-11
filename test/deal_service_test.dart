import 'dart:convert';
import "package:test/test.dart";
import 'package:embla/http.dart';
import "package:embla/application.dart";
import 'package:embla/http_basic_middleware.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:tradem_srv/Srv.dart' as Srv;
import 'package:srv_base/Srv.dart' as base;
import 'package:tradem_srv/Services/UserService.dart';

import 'package:srv_base/Models/Users.dart';
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
          Route.post('login/', base.JwtLoginMiddleware),
          base.InputParserMiddleware,
          Route.all('users/*', base.JwtAuthMiddleware,
            new base.UserGroupFilter(UserGroup.USER.Str), base.UserIdFilter,
            UserService),
          Route.get('objects/*', Srv.ObjectService),
          Route.match(const ['POST', 'PUT', 'DELETE'], 'objects/*',
            base.JwtAuthMiddleware,
            new base.UserGroupFilter(UserGroup.USER.Str),
            Srv.ObjectManService)
        )
      ),
      new Srv.TrademSrv()
    ];
    app = await Application.boot(bootstrappers);
  });
  tearDownAll(() async {
    await app.exit();
  });

  group("deals service get: ", () {

    setUpAll(() async {
      await TestCommon.createTestUser();
      await TestCommon.login();
      await TestCommon.initTestData();
    });

    test("create deal", () async {
      Map data = {
        'object_id' : 1,
        'count' : 500
      };
      var resp = await TestCommon.net
        .Create("$serverUrl/${TestCommon.userUrl}/deals", data);
      expect(JSON.decode(resp), containsPair('msg', 'ok'));
    });

    test("get deal", () async {
      List resp = await TestCommon.net
        .Get("$serverUrl/${TestCommon.userUrl}/deals");
      expect(resp.length, equals(1));
    });

    test("check add price", () async {
      double price = 1234.5;
      {
        var resp = await TestCommon.net
          .Create("$serverUrl/objects/1/price", {'value' : price});
        expect(JSON.decode(resp), containsPair('msg', 'ok'));
      }
      {
        Map data = {
          'object_id' : 1,
          'count' : 100
        };
        var resp = await TestCommon.net
          .Create("$serverUrl/${TestCommon.userUrl}/deals", data);
        expect(JSON.decode(resp), containsPair('msg', 'ok'));
      }
      {
        List resp = await TestCommon.net
          .Get("$serverUrl/${TestCommon.userUrl}/deals");
        expect(resp, allOf([
          contains(containsPair('id', 2)),
          contains(containsPair('item_price', price))
        ]));
      }
    });

  });
}
