import "package:test/test.dart";
import 'package:trestle/gateway.dart';
import "package:embla/application.dart";
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

  test(".split() splits the string on the delimiter", () {
    expect("foo,bar,baz", allOf([
      contains("foo"),
      isNot(startsWith("bar")),
      endsWith("baz")
    ]));
  });

}
