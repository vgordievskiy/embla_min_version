library tradem_srv;

import 'dart:async';
import 'package:di/di.dart';
import 'package:embla/application.dart';

import 'Utils/Utils.dart';
import 'Middleware/Auth.dart';
import 'package:option/option.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'package:http_exception/http_exception.dart';
import 'package:trestle/gateway.dart';
import 'Models/Users.dart';
import 'package:trestle/trestle.dart';

export 'Geo/PostgisPsqlDriver.dart';
export 'Utils/HttpsBootstrapper.dart';
export 'Services/UserService.dart';
export 'Services/UserCreator.dart';
export 'Middleware/Auth.dart';
export 'Middleware/CORS.dart';
export 'Middleware/input_parser/InputParserMiddleware.dart';
export 'Middleware/input_parser/input_parser.dart';

import 'Services/UserService.dart';

class TrademSrv extends Bootstrapper {
  ModuleInjector _injector;
  AuthConfig authConfig = new AuthConfig();
  UserService userService;

  @Hook.init
  init() {
    _injector = new ModuleInjector([ new Module()
      ..bind(AuthConfig, toFactory: () => authConfig)
    ]);
    Utils.setInjector(_injector);

    authConfig
    ..issuer = 'Semplex'
    ..secret = 'bno9mjc'
    ..lookupByUserName = this.lookupByUsername
    ..validateUserPass = this.validateUserPass
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

    if(user.password == password) {
        return new Some(new UserPrincipal(username, user.id));
    }
    throw new UnauthorizedException();
  }

  Future<Option<UserPrincipal>> lookupByUsername(String username) async
  {
    User user = await _getUserByName(username);
    if(user != null) {
      return new Some(new UserPrincipal(username, user.id));
    }
    return const None();
  }

  Future<String> welcomeHandler(UserPrincipal cred) async {
    return "users/${cred.id}";
  }
}
