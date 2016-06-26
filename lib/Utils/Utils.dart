library tradem_srv.utils.utils;

export 'package:di/di.dart';
import 'package:di/di.dart';

class Utils {
  static Injector _injector;
  static setInjector(Injector injector) {
    _injector = injector;
  }

  static Injector get injector => _injector;
  static $(Type type) => _injector.get(type);
}

bool expect(Map obj, String key) {
  return obj.containsKey(key) && obj[key] != null;
}
