library BMSrv.Models.RealEstate.REMetaData;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:SrvCommon/SrvCommon.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';

class FindSql extends CustomFindObjects {
  FindSql(Type modelType, String sql) : super(modelType) {
    this.sqlQuery = sql;
  }
}

Future<List<REMetaData>> testCustom() async {
  final String sql = "select * from real__estate__objects__meta__data where _data -> 'value' > '10' and name = 'electroPower';";
  FindSql find = new FindSql(REMetaData, sql);
  try {
    List<dynamic> res = await find.execute();
    return res;
  } catch(error) {
    var tmp = error;
  }
  return [];
}

class REMetaDataUtils {
  static List<String> metaNames = [
    'electroPower',
    'targetUsage',
    'description',
    'pricePerMeter',
    'mainImageUrl',
    'objectData'
];
  
  static bool checkMetaName(String name) {
    return metaNames.contains(name);
  }
  
  static Future<List<REMetaData>> getForObject(RealEstateBase obj, {String fieldName: null}) async {
    ORM.Find find = new ORM.Find(REMetaData);
    ORM.Condition condition = new ORM.Equals('ownerType', ReUtils.type2Int(obj.Type));
    condition.and(new ORM.Equals('ownerId', obj.id));
    if (fieldName != null) {
      condition.and(new ORM.Equals('name', fieldName));
    }
    
    find.where(condition);
    return await find.execute();
  }
  
  static Future<bool> addForObject(RealEstateBase obj, String name, String metaName, dynamic data) async {
    REMetaData newItem = new REMetaData();
    newItem.name = name;
    newItem.metaName = metaName;
    newItem.ownerType = ReUtils.type2Int(obj.Type);
    newItem.ownerId = obj.id;
    newItem.Data = data;
    return newItem.save();
  }
}

@ORM.DBTable('realEstateObjectsMetaData')
class REMetaData extends ORM.Model with Observable {
 
  static Map _converter(Map<String, dynamic> value) {
    assert(value.containsKey('value'));
    return value['value']; 
  }
  
  @ORM.DBField()
  @ORM.DBFieldPrimaryKey()
  @ORM.DBFieldType('SERIAL')
  int id;
  
  @ORM.DBField()
  String name;
  
  @ORM.DBField()
  String metaName;
  
  @ORM.DBField()
  int ownerType;
  
  @ORM.DBField()
  int ownerId;
  
  @ORM.DBField()
  @ORM.DBFieldConverter(_converter)
  dynamic _data;
  
  dynamic get Data => _data;
  set Data(var obj) => _data = { "value" : obj };
}