library tradem_srv;

import 'dart:async';
import 'package:di/di.dart';
import 'package:embla/application.dart';

import 'package:SemplexClientCmn/Utils/HttpCommunicator/IOHttpCommunicator.dart';
import 'package:SemplexClientCmn/Utils/RestAdapter.dart';

import 'Utils/Utils.dart';

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

  AppMan._internal() {
    _rest = new RestAdapter(_cmn);
    _injector = new ModuleInjector([

    ]);
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
  }
}
