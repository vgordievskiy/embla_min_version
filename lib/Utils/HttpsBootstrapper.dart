library srv_base.utils.https_bootstrapper;
import 'dart:async';
import 'dart:io';
import 'package:embla/application.dart';
import 'package:embla/http.dart';

class HttpsBootstrapper extends HttpBootstrapper {

  final dynamic host;

  SecurityContext securityContext;

  static Future<HttpServer> empty(dynamic host, int port) {
    return new Future.error('');
  }

  factory HttpsBootstrapper({dynamic host: 'localhost', int port: 1337,
    PipelineFactory pipeline, SecurityContext securityContext})
      => new HttpsBootstrapper.init(host, port, pipeline, securityContext);

  HttpsBootstrapper.init(dynamic host, int port, PipelineFactory pipeline,
                         this.securityContext)
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
