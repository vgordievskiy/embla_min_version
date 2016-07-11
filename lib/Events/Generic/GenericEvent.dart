library tradem_srv.events.generic.generic_event;
import 'package:harvest/harvest.dart';

class GenericEvent<T> extends DomainEvent {
  Type get internalType => T;
  final T data;

  GenericEvent([this.data = null]);
}
