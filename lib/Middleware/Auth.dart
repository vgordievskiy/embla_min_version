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
typedef Future<String> TWelcomeHandler(Principal cred);

class AuthConfig {
  String issuer;
  String secret;
  Duration idleTimeout = const Duration(days: 7);
  Duration totalSessionTimeout = const Duration(days: 7);
  TLookupByUsername lookupByUserName;
  TValidateUserPass  validateUserPass;
  TWelcomeHandler welcomeHandler;
  TUrlFilterHandler urlFilter;
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

  Future<Response> handle(Request request) async {
    try {
      return await _JwtAuthMiddleware(auth)(request);
    } catch (e) {
      return this.abortForbidden('access denied');
    }
  }

  auth(Request request) {
    final String authContext = 'shelf.auth.context';
    dynamic context = request.context[authContext];
    if(context == null) {
      return this.abortForbidden('access denied');
    }
    return super.handle(request);
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

  Future<Response> handle(Request request) async {
    try {
      return await _JwtLoginMiddleware(auth)(request);
    } catch(e) {
      return this.abortForbidden('access denied');
    }
  }

  auth(Request request) async {
    AuthConfig config = Utils.$(AuthConfig);
    final String authContext = 'shelf.auth.context';
    AuthenticatedContext context = request.context[authContext];
    if(context == null) {
      return this.abortForbidden('access denied');
    }

    String response = '';
    if(config.welcomeHandler != null) {
      response = await config.welcomeHandler(context.principal);
    }
    return ok(response);
  }
}

typedef Future<bool> TUrlFilterHandler(Principal cred, Uri uri);

class UrlFilter extends Middleware implements Authoriser {
  TUrlFilterHandler filter = (_1, _2) => new Future.error('empty filter');

  UrlFilter() {
    AuthConfig config = Utils.$(AuthConfig);
    filter = config.urlFilter;
  }

  Future<Response> handle(Request request) async {
    bool isApproved = await isAuthorised(request);
    if(isApproved) {
      return super.handle(request);
    } else {
      return this.abortForbidden('access denied');
    }
  }
  
  Future<bool> isAuthorised(Request request) async {
    final Option<AuthenticatedContext>
      authContextOpt = getAuthenticatedContext(request);
    if (authContextOpt is None) { return false; }
    final resultRight = authContextOpt.map((context)
      => filter(context.principal, request.url));
    return await resultRight.getOrElse(() => false);
  }
}
