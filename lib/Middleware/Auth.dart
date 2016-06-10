library tradem_srv.middleware.auth;

import 'dart:async';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_auth/shelf_auth.dart';
import 'package:option/option.dart';
import 'package:embla/http.dart';
import 'package:uuid/uuid.dart';

String secret = "bno9mjc";

String _getIssuer() => "Semplex";
String _getSecret() => "bno9mjc";

class JwtAuthMiddleware extends Middleware {
  Future<Response> handle(Request request) {
    return _JwtAuthMiddleware(test)(request);
  }

  test(Request request) {
    final String authContext = 'shelf.auth.context';
    dynamic context = request.context[authContext];
    print("!!! $context");
    return ok('anything');
  }
}

JwtSessionHandler _JwtSessionHandler =
  new JwtSessionHandler('SemplexServer',
                        new Uuid().v4(),
                        lookupByUsername,
                        idleTimeout: const Duration(days: 7),
                        totalSessionTimeout: const Duration(days: 7));

UsernamePasswordAuthenticator passChecker =
  new UsernamePasswordAuthenticator(validateUserPass);

shelf.Middleware _JwtAuthMiddleware =
  authenticate([],
               sessionHandler: _JwtSessionHandler,
               allowHttp: true,
               allowAnonymousAccess: false);

Future<Option<Principal>>
  validateUserPass(String username, String password) async
{
  return new Some(new Principal(username));
}

Future<Option<Principal>> lookupByUsername(String username) async
{
  return new Some(new Principal(username));
}
