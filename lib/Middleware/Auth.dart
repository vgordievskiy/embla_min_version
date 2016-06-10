library tradem_srv.middleware.auth;

import 'dart:async';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_auth/shelf_auth.dart';
import 'package:option/option.dart';
import 'package:embla/http.dart';
import 'package:uuid/uuid.dart';
import 'package:shelf_auth/src/session/jwt/jwt_session_auth.dart';

String secret = "bno9mjc";

String _getIssuer() => "Semplex";
String _getSecret() => "bno9mjc";

class JwtAuthMiddleware extends Middleware {

  shelf.Middleware _JwtAuthMiddleware =
    authenticate([new JwtSessionAuthenticator(lookupByUsername, _getSecret())],
                 allowHttp: true);

  JwtAuthMiddleware() {
    _JwtAuthMiddleware =
      authenticate([new JwtSessionAuthenticator(lookupByUsername, _getSecret())],
                   allowHttp: true);
  }

  Future<Response> handle(Request request) {
    return _JwtAuthMiddleware(auth)(request);
  }

  auth(Request request) {
    final String authContext = 'shelf.auth.context';
    dynamic context = request.context[authContext];
    if(context == null) {
      return this.abortForbidden('access denied');
    }
    return ok('anything');
  }
}

class JwtLoginMiddleware extends Middleware {

  JwtSessionHandler _JwtSessionHandler;
  shelf.Middleware _JwtLoginMiddleware;

  JwtLoginMiddleware() {
    _JwtSessionHandler =
      new JwtSessionHandler(_getIssuer(),
                            _getSecret(),
                            lookupByUsername,
                            idleTimeout: const Duration(days: 7),
                            totalSessionTimeout: const Duration(days: 7));
    _JwtLoginMiddleware =
      authenticate([new UsernamePasswordAuthenticator(validateUserPass)],
                   sessionHandler: _JwtSessionHandler,
                   allowHttp: true);
  }

  Future<Response> handle(Request request) {
    return _JwtLoginMiddleware(auth)(request);
  }

  auth(Request request) {
    final String authContext = 'shelf.auth.context';
    dynamic context = request.context[authContext];
    if(context == null) {
      return this.abortForbidden('access denied');
    }
    return ok('anything');
  }
}


Future<Option<Principal>>
  validateUserPass(String username, String password) async
{
  return new Some(new Principal(username));
}

Future<Option<Principal>> lookupByUsername(String username) async
{
  return new Some(new Principal(username));
}
