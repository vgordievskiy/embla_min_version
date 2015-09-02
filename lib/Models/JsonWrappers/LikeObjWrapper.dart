library BMSrv.Models.JsonWrappers.LikeObjWrapper;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/Utils/LikeObject.dart';

import 'User.dart';
import 'RERoom.dart';

@Decode()
class LikeObjWrapper {

  static Future<LikeObjWrapper> Create(LikeObject obj) async 
  {
    LikeObjWrapper ret = new LikeObjWrapper();
    ret.room = await RERoomWrapper.Create(await obj.room);
    ret.user = await UserWrapper.Create(await obj.user);
    return ret;
  }

  @Field()
  RERoomWrapper room;

  @Field()
  UserWrapper user;
}