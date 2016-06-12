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

export 'Utils/HttpsBootstrapper.dart';
export 'Services/UserService.dart';
export 'Middleware/Auth.dart';
export 'Middleware/CORS.dart';

class TrademSrv extends Bootstrapper {
  ModuleInjector _injector;
  AuthConfig authConfig = new AuthConfig();
  Gateway gateway;
  Repository<User> users;

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
  initGateway(Gateway gateway) {
    this.gateway = gateway;
    users = new Repository<User>(this.gateway);
  }

  Future<Option<Principal>>
    validateUserPass(String username, String password) async
  {
    try {
      User user = await
        users.where((User user) => user.email == username).first();
    } catch (e) {
      var ee = e;
    }
    if(user.password == password) {
        return new Some(new Principal(username));
    }
    throw new UnauthorizedException();
  }

  Future<Option<Principal>> lookupByUsername(String username) async
  {
    if(users.containsKey(username)) {
      return new Some(new Principal(username));
    }
    return const None();
  }

  Future<String> welcomeHandler(Principal cred) async {
      return "users/1";
  }
}
