library srv_base.middleware.cors;
import 'dart:async';
import 'package:embla/http.dart';
import 'package:embla/src/http/response_maker.dart';

class CORSMiddleware extends Middleware {

  final ResponseMaker _responseMaker = new ResponseMaker();

  Future<Response> handle(Request request) async {
    final String origin = request.headers['origin'];
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
      return super.handle(request).then((resp)
        => resp.change(headers: new Map.from(resp.headers)..addAll(headers)));
    }
  }

}
