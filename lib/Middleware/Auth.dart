library tradem_srv.middleware.auth;

import 'dart:async';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_auth/shelf_auth.dart';
import 'package:option/option.dart';
import 'package:embla/http.dart';

String secret = "bno9mjc";

String _getIssuer() => "Semplex";
String _getSecret() => "bno9mjc";

class AuthMiddleware extends Middleware {
  Future<Response> handle(Request request) {
    return authMiddleware(test)(request);
  }

  test(Request request) {
    final String authContext = 'shelf.auth.context';
    dynamic contextn = request.context[authContext];
    print("!!! $context");
    return ok('anything');
  }
}

shelf.Middleware authMiddleware = (builder()
    .basic(validateUserPass,
           sessionCreationAllowed: true)
    .jwtSession(_getIssuer(), _getSecret(), lookupByUsername)
    ..allowHttp=true)
    .build();

Future<Option<Principal>>
  validateUserPass(String username, String password) async
{
  return new Some(new Principal(username));
}

Future<Option<Principal>> lookupByUsername(String username) async
{
  return new Some(new Principal(username));
}
