library BMSrv.Models.JsonWrappers.RELand;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/RealEstate/RELand.dart';

@Decode()
class RELandWrapper {

  static Future<RELandWrapper> Create(RELand object) async 
  {
    RELandWrapper ret = new RELandWrapper();
    ret.id = object.id;
    ret.objectName = object.objectName;
    return ret;
  }

  @Field()
  int id;
  
  @Field()
  final String type = "land";

  @Field()
  String objectName;
}