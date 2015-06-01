library BMSrv.LoginService;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:BMSrv/Utils/Encrypter.dart' as Enc;
import 'package:BMSrv/Models/User.dart';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/src/middleware.dart';
import 'package:shelf/src/handler.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'package:option/option.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

import 'package:BMSrv/Events/Event.dart';

Logger _log = new Logger("LoginService");
Map<String, User> _userCache = new Map();
EventBus _evt = EventSys.GetEventBus();

String _getUserIdPathSegment(app.Request req) {
  Uri uri = req.url;
  if (uri.pathSegments[0] == "users" &&
      uri.pathSegments.length >= 2)
  {
    return uri.pathSegments[1];
  }
  return null;
}

bool _IsUserPost(app.Request req) {
  Uri uri = req.url;
  if (uri.pathSegments[0] == "users" && req.method == "POST")
  {
    return true;
  }
  return false;
}

Future<User> GetUser(String login) async {
  _log.info("check user: ${login}");

  if (_userCache.containsKey(login)) {
    return _userCache[login];
  }

  ORM.FindOne findOneItem = new ORM.FindOne(User)
                                ..whereEquals('userName', login);
  if (findOneItem != null) {
    User user = await findOneItem.execute();
    return user;
  }
  final String message = login + " is not exist";
  throw new app.ErrorResponse(403, {"error": message});
}

Future<Option<Principal>>
    validateUserPass(String username, String password) async
{
  bool validUser = false;

  var exception = null;

  User user = await GetUser(username).catchError((var error) {
    exception = error;
    _log.info("user: ${username} not valid - ${error}");
  });

  if (user != null) {
    final String passHash = Enc.encryptPassword(password);
    if (user.password == passHash) {
      validUser = true;
      _log.info("user: ${username} is valid");
      _userCache[username] = user;
      _log.info("add user to cache: ${username}");
    }
  }

  final principalOpt = validUser ? new Some(new Principal(username)) :
                                   const None();
  return new Future.value(principalOpt);
}

Future<Option<Principal>> lookupByUsername(String username) async {
  bool validUser = false;

  var exception = null;

  User user = await GetUser(username).catchError((var error) {
    exception = error;
  });

  if (user != null) validUser = true;

  final principalOpt = validUser ? new Some(new Principal(username)) :
                                   const None();
  return new Future.value(principalOpt);
}

var sessionHandler = new JwtSessionHandler('LifeControl',
                                            new Uuid().v4(),
                                            lookupByUsername,
                                            idleTimeout: const Duration(days: 7),
                                            totalSessionTimeout: const Duration(days: 7));

UsernamePasswordAuthenticator _userPassChecker =
  new UsernamePasswordAuthenticator(validateUserPass);

@app.Interceptor(r'/login')
checkUserPass() async {
  Option<AuthenticatedContext> result = await _userPassChecker.
        authenticate(app.request.shelfRequest).catchError((var error){});

  if (result != null && !result.isEmpty()) {
    AuthenticatedContext context = result.get();
    Principal userPrincipal = context.principal;
    final userName = userPrincipal.name;

    User dbUser = await GetUser(userName);

   // UserLogged event = new UserLogged(dbUser.id);

   // EventSys.GetEventBus().fire(event);

   // var userTmp = await event.Result;

    final String userPath = "/users/${dbUser.id}";
    shelf.Response response = new shelf.Response.ok(userPath);
    app.response = sessionHandler.handle(context,
                                         app.request.shelfRequest,
                                         response);
  } else {
    app.response = new shelf.Response.forbidden("access denied");
  }
  app.chain.interrupt();
}

Middleware defaultAuthMiddleware = authenticate([],
                                          sessionHandler: sessionHandler,
                                          allowHttp: true,
                                          allowAnonymousAccess: false);

shelf.Request _CopyRequest_OnlyHeadersContains(app.Request appReq) {
  shelf.Request req = new shelf.Request(appReq.method,
                                        appReq.requestedUri,
                                        headers: appReq.headers,
                                        url: appReq.url,
                                        scriptName: "");
  return req;
}

List<String> openResources = [];//['realestate'];

bool isOpenResources(List<String> path) {
  bool ret = false;
  openResources.firstWhere((String el)
  {
    if(path[0] == el) {
      ret = true;
      return true;
    } else { return false;}
  }, orElse: () {
    ret = false;
    return "";
  });
  return ret;
}

@app.Interceptor(r'/.*', chainIdx: 1)
authenticationFilter() async
{
  shelf.Response resp = null;
  shelf.Request req = _CopyRequest_OnlyHeadersContains(app.request);

  if (req.url.pathSegments.length == 0) {
    app.response = new shelf.Response.forbidden("access denied");
    app.chain.interrupt();
    return;
  }
  var tmp = req.url.pathSegments;
  bool isValid = false;

  await defaultAuthMiddleware((shelf.Request request){
    isValid = true;
    final String authContext = 'shelf.auth.context';
    dynamic context = request.context[authContext];
    app.request.session["username"] = context.principal.name;
    return new shelf.Response.ok(null);
  })(req).catchError((var error){
    isValid = false;
  });

  if (_IsUserPost(app.request)) isValid = true;
  
  if(isOpenResources(req.url.pathSegments)) isValid = true;

  if (isValid) {
    app.response = new shelf.Response.ok(null);
    app.chain.next();
  } else {
    app.response = new shelf.Response.forbidden("access denied");
    app.chain.interrupt();
  }
}

@app.Interceptor(r'/users/.*', chainIdx: 2)
authUserFilter() async
{
  String id = _getUserIdPathSegment(app.request);
  final String userName = app.request.session["username"];

  User dbUser = await GetUser(userName);

  if (id == null)
  {
    app.chain.next();
  }
  else if ("${dbUser.id}" != id) {
    app.response = new shelf.Response.forbidden("access denied");
    app.chain.interrupt();
  } else {
    app.chain.next();
  }
}
