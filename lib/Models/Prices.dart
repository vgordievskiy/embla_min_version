library tradem_srv.models.prices;
import 'package:embla_trestle/embla_trestle.dart';

class Price extends Model {
  @field int id;
  @field int entity_id;
  @field double price;

  Map toJson() {
    return {
      'id' : id,
      'created_at' : createdAt,
      'updated_at' : updatedAt,
      'entity_id'  : entity_id,
      'price'      : price
    };
  }
}
