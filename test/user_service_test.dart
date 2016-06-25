import "package:test/test.dart";
import 'package:trestle/gateway.dart';
import 'package:embla/http.dart';
import "package:embla/application.dart";
import 'package:embla/http_basic_middleware.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:SemplexClientCmn/Utils/HttpCommunicator/IOHttpCommunicator.dart';
import 'package:SemplexClientCmn/Utils/RestAdapter.dart';
import 'package:tradem_srv/Srv.dart' as Srv;

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
          Route.post('login/', Srv.JwtLoginMiddleware),
          Route.post('test/', Srv.InputParserMiddleware, (Srv.Input req) async {
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

  group("int", () {

    IoHttpCommunicator cmn = new IoHttpCommunicator();
    RestAdapter rest = new RestAdapter(cmn);

    setUp(() async {
      print("!!!");
    });
    tearDown(() async {
      print("222");
    });

    test("create user", () async {
      var tmp = await rest.Create("$serverUrl/users");
      print(tmp);
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
