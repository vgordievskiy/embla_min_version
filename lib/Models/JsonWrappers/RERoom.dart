library BMSrv.Models.JsonWrappers.RERoom;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';
import 'package:BMSrv/Models/JsonWrappers/REstate.dart';
import 'package:BMSrv/Models/JsonWrappers/REMetaData.dart';

@Decode()
class RERoomWrapper {

  static final Type OriginType = RERoom;

  static Future<RERoomWrapper> Create(RERoom object) async
  {
    RERoomWrapper ret = new RERoomWrapper();
    ret.id = object.id;
    ret.ownerObject = await REstateWrapper.Create(await object.GetOwner());
    REMetaDataWrapper metaData = await REMetaDataWrapper
      .Create(await object.GetMetaData());
    ret.data = metaData.data;
    ret.objectName = object.objectName;
    ret.square = object.square;
    ret.price = await object.Price;
    return ret;
  }

  @Field()
  int id;

  @Field()
  Map<String, dynamic> data;

  @Field()
  REstateWrapper ownerObject;

  @Field()
  String objectName;

  @Field()
  double square;

  @Field()
  double price;
}
