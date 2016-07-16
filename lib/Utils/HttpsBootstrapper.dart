library srv_base.utils.https_bootstrapper;
import 'dart:async';
import 'dart:io';
import 'package:embla/application.dart';
import 'package:embla/http.dart';

class HttpsBootstrapper extends HttpBootstrapper {

  SecurityContext securityContext;

  static Future<HttpServer> empty(dynamic host, int port) {
    return new Future.error('');
  }

  factory HttpsBootstrapper({String host: 'localhost', int port: 1337,
    PipelineFactory pipeline, SecurityContext securityContext})
      => new HttpsBootstrapper.init(host, port, pipeline);

  HttpsBootstrapper.init(String host, int port, PipelineFactory pipeline)
    : super.internal(empty, host, port, pipeline);


  @Hook.bindings
  bindings() async {
    return container
      .bind(HttpServer, to: await initSecureSrv(this.host, this.port));
  }

  Future<HttpServer> initSecureSrv(dynamic host, int port) {
    if(securityContext == null) {
      return HttpServer.bind(host, port);
    } else {
      return HttpServer.bindSecure(host, port, securityContext);
    }
  }

}
