import 'dart:convert';
import "package:test/test.dart";
import 'package:trestle/gateway.dart';
import 'package:embla/http.dart';
import "package:embla/application.dart";
import 'package:embla/http_basic_middleware.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:tradem_srv/Srv.dart' as Srv;
import 'package:tradem_srv/Models/Objects.dart';

import './test_data/common_test.dart';
import 'package:tradem_srv/Models/Users.dart';

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
          Route.all('users/*', Srv.JwtAuthMiddleware,
            new Srv.UserGroupFilter(UserGroup.USER.Str), Srv.UserIdFilter,
            Srv.UserService),
          Route.get('objects/', Srv.ObjectService),
          Route.post('objects/',
            Srv.JwtAuthMiddleware,
            new Srv.UserGroupFilter(UserGroup.USER.Str),
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

  group("object service get: ", () {

    setUpAll(() async {
      await TestCommon.createTestUser();
      await TestCommon.login();
      await TestCommon.initTestData();
    });

    test("create object", () async {
      Map data = {
        'type' : EntityType.COMMERCIAL_PLACES.Str,
        'pieces' : 1000,
        'data': JSON.encode([ {'name' : 'place1'}, {'name' : 'place2'} ])
      };
      var resp = await TestCommon.net.Create("$serverUrl/objects", data);
    });

    test("get objects", () async {
      Repository<Entity> objects = new Repository<Entity>(TestCommon.gateway);
      List resp = await TestCommon.net.Get("$serverUrl/objects");
      List<Entity> origin = await objects.all().toList();
      expect(resp.length, equals(origin.length));
      for(int ind = 0; ind < origin.length; ++ind) {
        expect(resp[ind]['id'], equals(origin[ind].id));
        expect(resp[ind]['data'], contains('objects'));
        expect(resp[ind]['data']['objects'], isList);
      }
    });
  });
}
