library tradem_srv.models.objects;
import 'package:embla_trestle/embla_trestle.dart';

class EntityType {
  static final List<EntityType> values = [ EntityType.ROOM ];
  static EntityType fromInt(int ind) => values[ind];
  
  final _value;
  final int _intValue;
  const EntityType._internal(this._value, this._intValue);
  toString() => 'EntityType.$_value';

  static const ROOM = const EntityType._internal('ROOM', 0);
}

class Entity extends Model {
  @field int id;
  @field int type;
  @field Map data;
}
