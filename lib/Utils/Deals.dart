library tradem_srv.utils.deals;

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

}
