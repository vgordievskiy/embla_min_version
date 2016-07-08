library tradem_srv.utils.prices;

import 'dart:async';
import 'package:di/type_literal.dart';
import 'package:trestle/trestle.dart';
import 'package:srv_base/Utils/Utils.dart';
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

  static Future<Price> addPrice(Entity obj, double priceValue) async {
    Price price = new Price()
      ..entity_id = obj.id
      ..price = priceValue;
    await prices().save(price);
    return price;
  }
}
