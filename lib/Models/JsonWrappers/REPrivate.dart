library BMSrv.Models.JsonWrappers.REPrivate;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/RealEstate/REPrivate.dart';

@Decode()
class REPrivateWrapper {

  static Future<REPrivateWrapper> Create(REPrivate object) async 
  {
    REPrivateWrapper ret = new REPrivateWrapper();
    ret.id = object.id;
    ret.ojectName = object.objectName;
    return ret;
  }

  @Field()
  int id;
  
  @Field()
  final String type = "private";

  @Field()
  String ojectName;
}