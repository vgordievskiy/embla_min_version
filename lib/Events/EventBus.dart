library BMSrv.Events.EventSys;

export 'dart:async';
export 'package:event_bus/event_bus.dart';
import 'package:event_bus/event_bus.dart';

import 'dart:async';

class EventSys {
  static bool IsSync = true;
  static EventBus _Bus = new EventBus(sync: IsSync);
  static EventBus GetEventBus() {
    return _Bus;
  }
}

class EventCompleterBase<T> {
  Completer<T> _Comleter = new Completer();
  
  Future<T> get Result => _Comleter.future;
  
  Completer<T> get IntCompleter => _Comleter;
  
  void Done(T value) => _Comleter.complete(value);
}