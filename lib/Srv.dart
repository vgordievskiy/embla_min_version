library srv_base;

import 'dart:async';
import 'package:di/di.dart';
import 'package:embla/application.dart';
import 'package:option/option.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'package:http_exception/http_exception.dart';
import 'package:trestle/gateway.dart';
import 'package:trestle/trestle.dart';

import 'Utils/Utils.dart';
import 'Middleware/Auth.dart';
import 'Middleware/AuthPrincipal.dart';
import 'Models/Users.dart';
import './Utils/Crypto.dart' as crypto;

export 'Geo/PostgisPsqlDriver.dart';
export 'Utils/Utils.dart';
export 'Utils/HttpsBootstrapper.dart';
export 'Services/UserService.dart';
export 'Middleware/Auth.dart';
export 'Middleware/AuthPrincipal.dart';
export 'Middleware/UserFilters/UserByIdFilter.dart';
export 'Middleware/UserFilters/UserGroupFilter.dart';
export 'Middleware/CORS.dart';
export 'Middleware/input_parser/InputParserMiddleware.dart';
export 'Middleware/input_parser/input_parser.dart';

import 'Services/UserService.dart';

class SrvBase extends Bootstrapper {
  ModuleInjector _injector;
  AuthConfig authConfig = new AuthConfig();
  UserService userService;

  final String issuer;
  final String secret;
  SrvBase(this.issuer, this.secret);

  @Hook.init
  init() {
    _injector = new ModuleInjector([ new Module()
      ..bind(AuthConfig, toFactory: () => authConfig)
    ]);
    Utils.setInjector(_injector);

    authConfig
    ..issuer = issuer
    ..secret = secret
    ..lookupByUserName = this.lookupByUsername
    ..validateUserPass = this.validateUserPass
    ..excludeHandler = this.excludeUrlForAuth
    ..welcomeHandler = this.welcomeHandler;
  }

  @Hook.interaction
  initUserSrv(UserService srv) {
    this.userService = srv;
  }

  Future<User> _getUserByName(String username)
    => userService.getUserByName(username);

  Future<Option<UserPrincipal>>
    validateUserPass(String username, String password) async
  {
    User user = await _getUserByName(username);

    if(user.password == crypto.encryptPassword(password)) {
        return new Some(new UserPrincipal(username, user.id, user.group));
    }
    throw new UnauthorizedException();
  }

  Future<Option<UserPrincipal>> lookupByUsername(String username) async
  {
    User user = await _getUserByName(username);
    if(user != null) {
      return new Some(new UserPrincipal(username, user.id, user.group));
    }
    return const None();
  }

  Future<bool> excludeUrlForAuth(Uri uri, String method) async {
    bool ret = false;
    if(uri.path == "/users" && method == "POST") {
      ret = true;
    }
    return ret;
  }

  Future<String> welcomeHandler(UserPrincipal cred) async {
    return "users/${cred.id}";
  }
}
