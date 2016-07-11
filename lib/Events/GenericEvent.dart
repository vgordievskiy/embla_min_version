library tradem_srv.events.generic_event;
import 'package:harvest/harvest.dart';

class GenericEvent<T> extends DomainEvent {
  Type get internalType => T;
  final dynamic data;

  GenericEvent([this.data = null]);
}
