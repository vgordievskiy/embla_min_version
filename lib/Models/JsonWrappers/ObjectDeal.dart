library BMSrv.Models.JsonWrappers.ObjectDeal;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';
import 'package:BMSrv/Models/JsonWrappers/RERoom.dart';

export 'package:BMSrv/Models/ObjectDeal.dart';

@Decode()
class ObjectDealWrapper {

  static Future<ObjectDealWrapper> Create(ObjectDeal deal,
                                          {bool withPrice: false}) async
  {
    ObjectDealWrapper ret = new ObjectDealWrapper();
    ret.id = deal.id;
    ret.type = deal.TypeName;
    {
      var obj = await deal.GetObject();
      if(obj != null) {
        ret.object = await RERoomWrapper.Create(obj);
      } else {
        ret.object = new RERoomWrapper();
      }
    }
    ret.isPending = deal.isPending;
    ret.part = deal.part;
    ret.createTime = deal.createTime;
    ret.approveTime = deal.approveTime;
    if(withPrice) ret.price = deal.price;
    return ret;
  }

  @Field()
  int id;

  @Field()
  String type;

  @Field()
  RERoomWrapper object;

  @Field()
  bool isPending;

  @Field()
  double part;

  @Field()
  double price;

  @Field()
  DateTime createTime;

  @Field()
  DateTime approveTime;
}
