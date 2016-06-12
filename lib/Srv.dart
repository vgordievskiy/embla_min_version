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
import 'package:embla/http.dart';
import 'dart:io';

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
    ..validateUserPass = this.validateUserPass;
  }

  Future<Option<Principal>>
    validateUserPass(String username, String password) async
  {
    return new Some(new Principal(username));
  }

  Future<Option<Principal>> lookupByUsername(String username) async
  {
    return new Some(new Principal(username));
  }
}

class HttpsBootstrapper extends HttpBootstrapper {
  static Future<HttpServer> empty(dynamic host, int port) {
    return new Future.error('');
  }

  factory HttpsBootstrapper({String host: 'localhost', int port: 1337,
    PipelineFactory pipeline})
      => new HttpsBootstrapper.init(host, port, pipeline);

  HttpsBootstrapper.init(String host, int port, PipelineFactory pipeline)
    : super.internal(empty, host, port, pipeline);


  @Hook.bindings
  bindings() async {
    return container
      .bind(HttpServer, to: await initSecureSrv(this.host, this.port));
  }

  Future<HttpServer> initSecureSrv(dynamic host, int port) {
    return HttpServer.bind(host, port);
  }
}
