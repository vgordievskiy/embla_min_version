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
      ret.userUrl = "/users/${user.id}";
      ret.name = user.name;
      ret.email = user.email;
      ret.avatar = user.profileImage;
      return ret;
  }
  
  @Field()
  String userUrl;

  @Field()
  String name;

  @Field()
  String email;
  
  @Field()
  String avatar;
}