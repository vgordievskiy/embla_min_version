library tradem_srv.models.objects;
import 'package:embla_trestle/embla_trestle.dart';

class EntityType {
  final _value;
  const EntityType._internal(this._value);
  toString() => 'EntityType.$_value';

  static const COMMERCIAL_PLACE =
    const EntityType._internal('COMMERCIAL_PLACE');

  static final List<EntityType> values = [ EntityType.COMMERCIAL_PLACE ];
  static EntityType fromInt(int ind) => values[ind];
  static int toInt(EntityType type) => values.indexOf(type);
}

class Entity extends Model {
  @field int id;
  @field int type;
  @field Map data;
}
