library BMSrv.Models.RealEstate.REMetaData;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:SrvCommon/SrvCommon.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';

class REMetaDataUtils {
  static Future<List<REMetaData>> getForObject(RealEstateBase obj) async {
    ORM.Find find = new ORM.Find(REMetaData);
    ORM.Condition condition = new ORM.Equals('ownerType', ReUtils.type2Int(obj.Type));
    condition.and(new ORM.Equals('ownerId', obj.id));
    find.where(condition);
    return await find.execute();
  }
}

@ORM.DBTable('real_estate_objects_meta_data')
class REMetaData extends ORM.Model with Observable {
 
  static Map _converter(String value) {
    value = value.replaceAll(new RegExp("'"), '"');
    Map<String, dynamic> obj = JSON.decode(value);
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
  LinkedHashMap<String, dynamic> data;
}