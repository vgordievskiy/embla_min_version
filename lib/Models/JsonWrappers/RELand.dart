library BMSrv.Models.JsonWrappers.REPrivate;
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
    ret.ojectName = object.objectName;
    return ret;
  }

  @Field()
  int id;

  @Field()
  String ojectName;
}