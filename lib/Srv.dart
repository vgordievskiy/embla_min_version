library tradem_srv;

import 'dart:async';
import 'package:di/di.dart';
import 'package:embla/application.dart';

import 'Utils/Utils.dart';
import 'Middleware/Auth.dart';
import 'package:option/option.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'package:http_exception/http_exception.dart';

export 'Utils/HttpsBootstrapper.dart';
export 'Services/UserService.dart';
export 'Middleware/Auth.dart';
export 'Middleware/CORS.dart';

class TrademSrv extends Bootstrapper {
  ModuleInjector _injector;
  AuthConfig authConfig = new AuthConfig();

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

  Map<String, String> users = {
    'gardi' : '1'
  };

  Future<Option<Principal>>
    validateUserPass(String username, String password) async
  {
    if(users.containsKey(username) && users[username] == password) {
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
