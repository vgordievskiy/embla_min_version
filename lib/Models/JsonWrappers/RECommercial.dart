library BMSrv.Models.JsonWrappers.REPrivate;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/RealEstate/RECommercial.dart';

@Decode()
class REPCommercialWrapper {

  static Future<REPCommercialWrapper> Create(RECommercial object) async 
  {
    REPCommercialWrapper ret = new REPCommercialWrapper();
    ret.id = object.id;
    ret.ojectName = object.objectName;
    return ret;
  }

  @Field()
  int id;

  @Field()
  String ojectName;
}