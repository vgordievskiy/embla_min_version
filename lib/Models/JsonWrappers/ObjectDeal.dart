library BMSrv.Models.JsonWrappers.ObjectDeal;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';

@Decode()
class ObjectDealWrapper {

  static Future<ObjectDealWrapper> Create(ObjectDeal deal) async 
  {
    ObjectDealWrapper ret = new ObjectDealWrapper();
    ret.id = deal.id;
    ret.type = deal.TypeName;
    ret.objectId = deal.objectId;
    return ret;
  }

  @Field()
  int id;
  
  @Field()
  String type;
  
  @Field()
  int objectId;
}