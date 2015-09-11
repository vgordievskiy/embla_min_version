library BMSrv.Models.JsonWrappers.REMetaData;
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/RealEstate/REMetaData.dart';

@Decode()
class REMetaDataWrapper {
  
  static Future<REMetaDataWrapper> Create(List<REMetaData> data) async 
  {
    REMetaDataWrapper ret = new REMetaDataWrapper();
    
    ret.data = new Map();
    
    for(REMetaData item in data) {
      if (!ret.data.containsKey(item.name)) {
        ret.data[item.name] = [item.data];
      } else {
        (ret.data[item.name] as List).add(item.data);
      }
    }
    
    return ret;
  }
  
  static Future<Map<String, dynamic>> CreateAsMap(List<REMetaData> data) async {
    Map<String, dynamic> ret = new Map();
        
    for(REMetaData item in data) {
      ret[item.name] = item.data;
    }
    
    return ret;
  }
  
  @Field()
  Map<String, dynamic> data;
}