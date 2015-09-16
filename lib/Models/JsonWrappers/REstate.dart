library BMSrv.Models.JsonWrappers.REstate;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/RealEstate/RealEstateGeneric.dart';
import 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';

@Decode()
class REstateWrapper {

  static Future<REstateWrapper> Create(REGeneric object) async 
  {
    REstateWrapper ret = new REstateWrapper();
    ret.id = object.id;
    ret.type = ReUtils.type2Str(object.Type);
    ret.objectName = object.objectName;
    ret.Geo = await object.GetGeometry();
    return ret;
  }

  @Field()
  int id;
  
  @Field()
  String type;

  @Field()
  String objectName;
  
  @Field()
  Map<String, dynamic> Geo;
}