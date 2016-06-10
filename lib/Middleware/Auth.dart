library tradem_srv.middleware.auth;

import 'dart:async';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_auth/shelf_auth.dart';
import 'package:embla/http.dart';
import 'package:option/option.dart';
import 'package:shelf_auth/src/session/jwt/jwt_session_auth.dart';

import '../Utils/Utils.dart';

typedef Future<Option<Principal>> TLookupByUsername(String username);
typedef Future<Option<Principal>>
  TValidateUserPass(String username, String password);

class AuthConfig {
  String issuer;
  String secret;
  Duration idleTimeout = const Duration(days: 7);
  Duration totalSessionTimeout = const Duration(days: 7);
  TLookupByUsername lookupByUserName;
  TValidateUserPass  validateUserPass;
}

class JwtAuthMiddleware extends Middleware {

  shelf.Middleware _JwtAuthMiddleware;

  JwtAuthMiddleware() {
    AuthConfig config = Utils.$(AuthConfig);
    _JwtAuthMiddleware =
      authenticate(
        [new JwtSessionAuthenticator(
          config.lookupByUserName,
          config.secret)],
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
    AuthConfig config = Utils.$(AuthConfig);

    _JwtSessionHandler =
      new JwtSessionHandler(config.issuer,
                            config.secret,
                            config.lookupByUserName,
                            idleTimeout: config.idleTimeout,
                            totalSessionTimeout: config.totalSessionTimeout);
    _JwtLoginMiddleware =
      authenticate([new UsernamePasswordAuthenticator(config.validateUserPass)],
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
