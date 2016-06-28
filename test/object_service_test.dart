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
          Route.all('objects/*', Srv.ObjectService)
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
      await TestCommon.login();
      await TestCommon.initTestData();
    });

    test("get objects", () async {
      Repository<Entity> entities = new Repository<Entity>(TestCommon.gateway);
      List resp = await TestCommon.net.Get("$serverUrl/objects");
      List<Entity> origin = await entities.all().toList();
      expect(resp.length, equals(origin.length));
    });
  });
}
