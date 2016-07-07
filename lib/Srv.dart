library tradem_srv;

import 'dart:async';
import 'package:di/di.dart';
import 'package:embla/application.dart';
import 'package:option/option.dart';
import 'package:http_exception/http_exception.dart';

import 'package:srv_base/Srv.dart';
import 'package:srv_base/Utils/Crypto.dart' as crypto;
import 'package:srv_base/Models/Users.dart';

export 'package:srv_base/Srv.dart';
export 'Services/ObjectService.dart';
export 'Services/Management/ObjectManService.dart';

import 'Services/UserService.dart' as srv;

class TrademSrv extends Bootstrapper {
  ModuleInjector _injector;
  AuthConfig authConfig = new AuthConfig();
  srv.UserService userService;

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
    ..excludeHandler = this.excludeUrlForAuth
    ..welcomeHandler = this.welcomeHandler;
  }

  @Hook.interaction
  initUserSrv(srv.UserService userSrv) {
    this.userService = userSrv;
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
