import "package:test/test.dart";
import 'package:trestle/gateway.dart';
import "package:embla/application.dart";
import 'package:SemplexClientCmn/Utils/HttpCommunicator/IOHttpCommunicator.dart';
import 'package:SemplexClientCmn/Utils/RestAdapter.dart';
import 'package:tradem_srv/Services/UserService.dart';

import '../bin/server.dart' as Srv;

main() async {
  Application app;
  Srv.driver = new InMemoryDriver();

  setUp(() async {
    List<Bootstrapper> bootstrappers = Srv.embla;
    app = await Application.boot(bootstrappers);
  });
  tearDown(() async {
    await app.exit();
  });

  group("int", () {

    //IoHttpCommunicator cmn = new IoHttpCommunicator();
    //RestAdapter rest;

    setUp(() async {
      print("!!!");
    });
    tearDown(() async {
      print("222");
    });

    test(".split() splits the string on the delimiter", () {
      expect("foo,bar,baz", allOf([
        contains("foo"),
        isNot(startsWith("bar")),
        endsWith("baz")
      ]));
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
