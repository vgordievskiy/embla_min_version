import 'dart:mirrors';
import 'dart:io';
import 'package:tradem_srv/Srv.dart' as Srv;
import 'package:embla/http.dart';
import 'package:embla/http_basic_middleware.dart';
import 'package:embla/application.dart';

export 'package:embla/application.dart';
export 'package:embla/bootstrap.dart';

get embla => [
  new HttpBootstrapper(
    port: 9090,
    pipeline: pipe(() => Srv.Msg())
  ),
  new Srv.GeoAnalytics()
];

List<Bootstrapper> debugfindConfig() {
  final library = currentMirrorSystem().libraries[Platform.script];
  if (library == null) {
    throw new Exception('The script entry point is not a library');
  }

  final emblaMethod = library.declarations[#embla];
  if (emblaMethod == null) {
    throw new Exception('Found no [embla] getter in ${Platform.script}');
  }

  return library
      .getField(#embla)
      .reflectee as List<Bootstrapper>;
}

//main(List<String> arguments) async => await Application.boot(debugfindConfig());
