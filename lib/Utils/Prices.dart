library tradem_srv.utils.prices;

import 'dart:async';
import 'package:di/type_literal.dart';
import 'package:trestle/trestle.dart';
import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Models/Users.dart';
import '../Models/Objects.dart';
import '../Models/Prices.dart';

export '../Models/Prices.dart';


class PricesUtils {
  static Repository<Price> prices() {
    return Utils.$(new TypeLiteral<Repository<Price>>().type);
  }

  static Future<Price> getPrice(Entity obj) {
    return prices().where((item) => item.entity_id == obj.id).get().last;
  }
}
