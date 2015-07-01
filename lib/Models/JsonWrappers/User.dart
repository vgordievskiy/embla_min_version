library BMSrv.Models.JsonWrappers.User;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/User.dart';

@Decode()
class UserWrapper {

  static Future<UserWrapper> Create(User user) async 
  {
      UserWrapper ret = new UserWrapper();
      ret.name = user.name;
      ret.email = user.email;
      return ret;
  }

  @Field()
  String name;

  @Field()
  String email;
}