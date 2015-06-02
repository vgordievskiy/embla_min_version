library BMSrv.Models.JsonWrappers.RECommercial;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/RealEstate/RECommercial.dart';

@Decode()
class RECommercialWrapper {

  static Future<RECommercialWrapper> Create(RECommercial object) async 
  {
    RECommercialWrapper ret = new RECommercialWrapper();
    ret.id = object.id;
    ret.ojectName = object.objectName;
    return ret;
  }

  @Field()
  int id;
  
  @Field()
  final String type = "commercial";

  @Field()
  String ojectName;
}