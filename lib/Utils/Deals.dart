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

  static Future<Deal> createFromId(int user_id, int entity_id) async {
    try {
      User user = await users().find(user_id);
      Entity obj = await entities().find(entity_id);
      Deal deal = new Deal()
        ..user_id = user_id
        ..entity_id = entity_id;
      return deal;
    } catch (err) {
      throw new ArgumentError('userd id or entity id wrong');
    }
  }

}
