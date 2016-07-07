library tradem_srv.models.deals;
import 'package:embla_trestle/embla_trestle.dart';

class Deal extends Model {
  @field int id;
  @field int user_id;
  @field int entity_id;
  @field int count;
  @field double item_price;

  Map toJson() {
    return {
      'id' : id,
      'user_id' : user_id,
      'entity_id' : entity_id,
      'count' : count,
      'item_price' : item_price
    };
  }
}
