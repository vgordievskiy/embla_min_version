library tradem_srv;

import 'dart:async';
import 'package:di/di.dart';
import 'package:di/type_literal.dart';
import 'package:embla/application.dart';
import 'package:option/option.dart';
import 'package:http_exception/http_exception.dart';
import 'package:harvest/harvest.dart';

import 'package:srv_base/Srv.dart';
import 'package:srv_base/Utils/Crypto.dart' as crypto;
import 'package:srv_base/Models/Users.dart';
import 'package:trestle/trestle.dart';

export 'package:srv_base/Srv.dart';
export 'Services/ObjectService.dart';
export 'Services/Management/ObjectManService.dart';

import 'Services/UserService.dart' as srv;
import 'Models/Objects.dart';
import 'Models/Deals.dart';
import 'Models/Prices.dart';

class TrademSrv extends Bootstrapper {
  ModuleInjector _injector;
  AuthConfig authConfig = new AuthConfig();

  MessageBus _bus = new MessageBus.async();

  /*Services */
    srv.UserService userService;
  /*----*/
  /*Repositories*/
    Repository<User> _users;
    Repository<Entity> _entities;
    Repository<Deal> _deals;
    Repository<Price> _prices;
  /*------------*/
  @Hook.init
  init() {
    _injector = new ModuleInjector([ new Module()
      ..bind(AuthConfig, toFactory: () => authConfig)
      ..bind(MessageBus, toFactory: () => _bus)
      ..bind(new TypeLiteral<Repository<User>>().type,  toFactory: () => _users)
      ..bind(new TypeLiteral<Repository<Deal>>().type,  toFactory: () => _deals)
      ..bind(new TypeLiteral<Repository<Price>>().type, toFactory: () => _prices)
      ..bind(new TypeLiteral<Repository<Entity>>().type,
          toFactory: () => _entities)
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

  @Hook.interaction
  initUsers(Repository<User> users) {
    this._users = users;
  }

  @Hook.interaction
  initEntities(Repository<Entity> entities) {
    this._entities = entities;
  }

  @Hook.interaction
  initDeals(Repository<Deal> deals) {
    this._deals = deals;
  }

  @Hook.interaction
  initPrices(Repository<Price> prices) {
    this._prices = prices;
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
