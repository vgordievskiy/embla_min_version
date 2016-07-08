library tradem_srv.utils.deals;

import 'dart:async';
import 'package:di/type_literal.dart';
import 'package:trestle/trestle.dart';
import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Models/Users.dart';
import '../Models/Deals.dart';
import '../Models/Objects.dart';

export '../Models/Deals.dart';

class DealsUtils {
  static Repository<User> users() {
    return Utils.$(new TypeLiteral<Repository<User>>().type);
  }

  static Repository<Entity> entities() {
    return Utils.$(new TypeLiteral<Repository<Entity>>().type);
  }

  static Future<Deal> createFromId(int user_id,
                                   int entity_id,
                                   int count,
                                   double price) async {
    try {
      User user = await users().find(user_id);
      Entity obj = await entities().find(entity_id);
      if(obj.busy_part >= count) {
        throw 'request part for buy are big';
      }
      Deal deal = new Deal()
        ..user_id = user_id
        ..entity_id = entity_id
        ..count = count
        ..item_price = price;
      return deal;
    } catch (err) {
      if(err is String) {
          throw new ArgumentError(err);
      }
      throw new ArgumentError('wrong data');
    }
  }

}
