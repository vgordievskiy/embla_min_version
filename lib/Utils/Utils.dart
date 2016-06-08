library tradem_srv.utils;

import 'package:di/di.dart';

class Utils {
  static ModuleInjector _injector;

  static init() {
    List<Module> modules = [new Module()];
    _injector = new ModuleInjector(modules);
  }

  static ModuleInjector get injector => _injector;

}
