library tradem_srv.models.prices;
import 'package:embla_trestle/embla_trestle.dart';

class Price extends Model {
  @field int id;
  @field DateTime created_at;
  @field DateTime updated_at;
  @field int entity_id;
  @field double price;

  Map toJson() {
    return {
      'id' : id,
      'created_at' : created_at,
      'updated_at' : updated_at,
      'entity_id'  : entity_id,
      'price'      : price
    };
  }
}
