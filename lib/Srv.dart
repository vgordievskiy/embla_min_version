library tradem_srv;

import 'dart:async';
import 'package:di/di.dart';
import 'package:embla/application.dart';

import 'package:SemplexClientCmn/Utils/HttpCommunicator/IOHttpCommunicator.dart';
import 'package:SemplexClientCmn/Utils/RestAdapter.dart';

import 'Utils/Utils.dart';
import 'Middleware/Auth.dart';
import 'package:option/option.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'package:http_exception/http_exception.dart';

export 'Utils/HttpsBootstrapper.dart';
export 'Services/UserService.dart';
export 'Middleware/Auth.dart';

class AppMan implements Injector {
  static AppMan _man;
  static Init() {
    assert(_man == null);
    _man = new AppMan._internal();
  }

  factory AppMan() {
    assert(_man != null);
    return _man;
  }

  IoHttpCommunicator _cmn = new IoHttpCommunicator();
  RestAdapter _rest;
  ModuleInjector _injector;

  AuthConfig authConfig;

  AppMan._internal() {
    initConfigs();
    _rest = new RestAdapter(_cmn);
    _injector = new ModuleInjector([ new Module()
      ..bind(AuthConfig, toFactory: () => authConfig)
    ]);
  }

  initConfigs() {
    authConfig = new AuthConfig();
  }

  RestAdapter get Net => _rest;

  @override
  get(Type type, [Type annotation]) => _injector.get(type, annotation);

  @override
  getByKey(Key key) => _injector.getByKey(key);

  @override
  Injector get parent => _injector.parent;

  @override
  Injector createChild(List<Module> modules) => _injector.createChild(modules);
}

class TrademSrv extends Bootstrapper {
  AppMan man;
  @Hook.init
  init() {
    AppMan.Init();
    man = new AppMan();
    Utils.setInjector(man);

    man.authConfig
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
