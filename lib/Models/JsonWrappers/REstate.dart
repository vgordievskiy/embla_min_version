library BMSrv.Models.JsonWrappers.REstate;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/RealEstate/RECommercial.dart';
import 'package:BMSrv/Models/RealEstate/REPrivate.dart';
import 'package:BMSrv/Models/RealEstate/RELand.dart';
import 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';

Map<Type, String> _converter = {
  RECommercial : "commercial",
  REPrivate : "private",
  RELand : "land",
  RERoom: "room"
};

@Decode()
class REstateWrapper {

  static Future<REstateWrapper> Create(var object) async 
  {
    REstateWrapper ret = new REstateWrapper();
    ret.id = object.id;
    ret.type = _converter[object.runtimeType];
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