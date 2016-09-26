library srv_base.middleware.cors;
import 'dart:async';
import 'package:embla/http.dart';
import 'package:embla/src/http/response_maker.dart';

class CORSMiddleware extends Middleware {

  final ResponseMaker _responseMaker = new ResponseMaker();

  Future<Response> handle(Request request) async {
    final Uri uri = request.requestedUri;
    final String origin = "${uri.scheme}://${uri.host}:${uri.port}";
    Map headers = {
      "Access-Control-Allow-Origin": "${origin}",
      "Access-Control-Allow-Credentials" : "true",
      "Access-Control-Expose-Headers" : "authorization",
      "Access-Control-Allow-Headers" : "authorization",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE",
      "Cache-Control": "no-cache, no-store, must-revalidate",
      "Pragma": "no-cache",
      "Expires": "0"
    };

    if(request.method == 'OPTIONS') {
      return new Response.ok(null, headers: headers);;
    } else {
      return super.handle(request)
      .then((resp)
        => resp.change(headers: new Map.from(resp.headers)..addAll(headers)))
      .catchError((resp) {
        int stCode = 500;
        dynamic body = 'error';
        try {stCode = resp.statusCode;} catch (err) {}
        try {body = resp.body;} catch (err) {}
        return new Response(stCode, body: body, headers: headers);
      });
    }
  }

}
