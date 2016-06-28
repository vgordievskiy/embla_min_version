library tradem_srv.models.objects;
import 'package:embla_trestle/embla_trestle.dart';

class EntityType {
  final _value;
  const EntityType._internal(this._value);
  toString() => 'EntityType.$_value';

  static const COMMERCIAL_PLACES =
    const EntityType._internal('COMMERCIAL_PLACES');
  static EntityType fromInt(int ind) => values[ind];
  static EntityType fromStr(String val)
    => values.firstWhere((EntityType el) => el._value == val);
  static int toInt(EntityType type) => values.indexOf(type);

  static final List<EntityType> values = [
    EntityType.COMMERCIAL_PLACES
  ];
}

class Entity extends Model {
  @field int id;
  @field int type;
  @field Map data;

  Map toJson() {
    return {
      'id' : id,
      'type' : EntityType.fromInt(type).toString(),
      'data' : data
    };
  }
}
