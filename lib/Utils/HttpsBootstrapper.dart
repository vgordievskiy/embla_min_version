library srv_base.utils.https_bootstrapper;
import 'dart:async';
import 'dart:io';
import 'package:embla/application.dart';
import 'package:embla/http.dart';

class HttpsBootstrapper extends HttpBootstrapper {

  SecurityContext securityContext;
  InternetAddress internetAddress;

  static Future<HttpServer> empty(dynamic host, int port, {bool shared}) {
    return new Future.error('');
  }

  factory HttpsBootstrapper({String host: 'localhost', int port: 1337,
    PipelineFactory pipeline, SecurityContext securityContext,
    InternetAddress ipAddress})
      => new HttpsBootstrapper.init(host, port, pipeline,
                                    securityContext, ipAddress);

  HttpsBootstrapper.init(String host, int port, PipelineFactory pipeline,
                        SecurityContext securityContext, InternetAddress ipAddress)
    : super.internal(empty, host, port, pipeline),
      this.securityContext = securityContext,
      this.internetAddress = ipAddress;


  @Hook.bindings
  bindings() async {
    return container
      .bind(HttpServer, to: await initSecureSrv(this.host, this.port));
  }

  Future<HttpServer> initSecureSrv(dynamic host, int port) {
    if(securityContext == null) {
      return HttpServer.bind(internetAddress ?? host, port);
    } else {
      return HttpServer.bindSecure(internetAddress ?? host,
                                   port, securityContext);
    }
  }

}
