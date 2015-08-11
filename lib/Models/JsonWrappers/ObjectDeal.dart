library BMSrv.Models.JsonWrappers.ObjectDeal;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';
import 'package:BMSrv/Models/JsonWrappers/REstate.dart';

export 'package:BMSrv/Models/ObjectDeal.dart';

@Decode()
class ObjectDealWrapper {

  static Future<ObjectDealWrapper> Create(ObjectDeal deal) async 
  {
    ObjectDealWrapper ret = new ObjectDealWrapper();
    ret.id = deal.id;
    ret.type = deal.TypeName;
    ret.object = await REstateWrapper.Create(await deal.GetObject());
    ret.isPending = deal.isPending;
    ret.part = deal.part;
    return ret;
  }

  @Field()
  int id;
  
  @Field()
  String type;
  
  @Field()
  REstateWrapper object;
  
  @Field()
  bool isPending;
  
  @Field()
  double part;
}