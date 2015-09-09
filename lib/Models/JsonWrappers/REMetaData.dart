library BMSrv.Models.JsonWrappers.REMetaData;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/RealEstate/REMetaData.dart';

@Decode()
class REMetaDataWrapper {
  
  static Future<REMetaDataWrapper> Create(List<dynamic> data) async 
  {
    REMetaDataWrapper ret = new REMetaDataWrapper();
    
    ret.data = new Map();
    
    for(REMetaData item in data) {
      ret.data[item.name] = item.data;
    }
    
    return ret;
  }

  @Field()
  Map<String, dynamic> data;
}