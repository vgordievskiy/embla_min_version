library tradem_srv.models.objects;
import 'package:embla_trestle/embla_trestle.dart';

class EntityType {
  final _value;
  const EntityType._internal(this._value);
  String get Str => _value;
  toString() => 'EntityType.$_value';

  static const COMMERCIAL_PLACES = const EntityType._internal('COMMERCIAL_PLACES');
  static const LANDS = const EntityType._internal('LANDS');
  static EntityType fromInt(int ind) => values[ind];
  static EntityType fromStr(String val)
    => values.firstWhere((EntityType el) => el._value == val);
  static int toInt(EntityType type) => values.indexOf(type);

  static final List<EntityType> values = [
    EntityType.COMMERCIAL_PLACES,
    EntityType.LANDS
  ];
}

class Entity extends Model {
  @field int id;
  @field String type;
  @field int pieces;
  @field bool enabled;
  @field Map data;
  @field int busy_part;

  int get free_part => pieces - busy_part;

  Map toJson() {
    return {
      'id' : id,
      'type' : type,
      'pieces' : pieces,
      'data' : data
    };
  }
}
