library BMSrv.Interceptors;
import 'dart:io';
import 'dart:async';
import 'package:redstone/server.dart' as app;
import "package:shelf/shelf.dart" as shelf;

shelf.Request _CopyRequest_OnlyHeadersContains(app.Request appReq) {
  shelf.Request req = new shelf.Request(appReq.method,
                                        appReq.requestedUri,
                                        headers: appReq.headers);
  return req;
}

@app.Interceptor(r'/.*', chainIdx: 0)
handleResponseHeader() {
  shelf.Request reqCopy = _CopyRequest_OnlyHeadersContains(app.request);
  if (app.request.method == "OPTIONS") {
    //overwrite the current response and interrupt the chain.
    app.response = new shelf.Response.ok(null, headers: _createCorsHeader(reqCopy));
    app.chain.interrupt();
  } else {
    //process the chain and wrap the response
    app.chain.next(() => app.response.change(headers: _createCorsHeader(reqCopy)));
  }
}

_createCorsHeader(shelf.Request request) {
  final String origin = request.headers['origin'];
  return {
    "Access-Control-Allow-Origin": "${origin}",
    "Access-Control-Allow-Credentials" : "true",
    "Access-Control-Expose-Headers" : "authorization",
    "Access-Control-Allow-Headers" : "authorization",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE"
  };
}