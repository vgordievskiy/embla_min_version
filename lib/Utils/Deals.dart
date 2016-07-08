library tradem_srv.utils.deals;

import 'dart:async';
import 'package:di/type_literal.dart';
import 'package:trestle/trestle.dart';
import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Models/Users.dart';
import '../Models/Deals.dart';
import '../Models/Objects.dart';
import '../Models/Prices.dart';
import '../Utils/Prices.dart';

export '../Models/Deals.dart';

class DealsUtils {
  static Repository<User> users() {
    return Utils.$(new TypeLiteral<Repository<User>>().type);
  }

  static Repository<Entity> entities() {
    return Utils.$(new TypeLiteral<Repository<Entity>>().type);
  }

  static Repository<Deal> deals() {
    return Utils.$(new TypeLiteral<Repository<Deal>>().type);
  }

  static Future<Deal> create(User user, Entity obj, int count, double price) async
  {
    if(obj.free_part < count) {
      throw 'request part for buy are big';
    }
    if(!obj.enabled) {
      throw 'object is disabled';
    }
    Deal deal = new Deal()
      ..user_id = user.id
      ..entity_id = obj.id
      ..count = count
      ..item_price = price;
    {
      obj.busy_part += count;
      await entities().save(obj);
    }
    return deal;
  }

  static Future<Deal> createFromId(int user_id,
                                   int entity_id,
                                   int count) async {
    try {
      User user = await users().find(user_id);
      Entity obj = await entities().find(entity_id);
      Price price = await PricesUtils.getPrice(obj);
      return create(user, obj, count, price.price);
    } catch (err) {
      if(err is String) {
          throw new ArgumentError(err);
      }
      throw new ArgumentError('wrong data');
    }
  }

  static Stream<Deal> getDeals(User user) {
    return deals().where((deal) => deal.user_id == user.id).get();
  }

}
