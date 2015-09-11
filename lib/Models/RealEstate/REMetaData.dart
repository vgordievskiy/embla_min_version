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
  final String sql = 'select * from real__estate__objects__meta__data where data ->> \'value\' > \'14.5\';';
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
  static List<String> metaNames = ['electoPower', 'targetUsage', 'description'];
  
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
    newItem.data = data;
    return newItem.save();
  }
}

@ORM.DBTable('real_estate_objects_meta_data')
class REMetaData extends ORM.Model with Observable {
 
  static Map _converter(String value) {
    value = value.replaceAll(new RegExp("'"), '"');
    var obj = JSON.decode(value);
    return obj; 
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
  dynamic data;
}