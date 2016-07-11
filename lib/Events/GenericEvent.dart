library tradem_srv.events.generic_event;

class GenericEvent<T> {
  Type get internalType => T;
  final dynamic data;

  GenericEvent([this.data = null]);
}
