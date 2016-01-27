library BMSrv.Models.RealEstate.Generic;
export 'package:BMSrv/Models/RealEstate/RealEstate.dart';
export 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';

import 'dart:async';

import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';
import 'package:SrvCommon/SrvCommon.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:postgresql/postgresql.dart' as psql;
import 'package:logging/logging.dart';

class REGenericUtils {
  static String type2Onto(ReType type) {
    switch(type) {
      case ReType.COMMERCIAL:
        return "RealEstateCommercial";
      case ReType.LAND:
        return "RealEstateLand";
      case ReType.PRIVATE:
        return "RealEstatePrivate";
      default:
        null;
    }
    return null;
  }

  static Future<List<REGeneric>> GetAllByType(ReType type) {
    ORM.Find find = new ORM.Find(REGeneric);

    ORM.Condition cond = new ORM.Equals('type', ReUtils.type2Int(type));
    find.where(cond);

    return (find.execute() as Future<List<REGeneric>>);
  }

  static Future<int> createPartition() async {
    ORM.Find find = new ORM.Find(REGeneric);
    ORM.Field field = find.table.fields.firstWhere((ORM.Field f){
      return f.propertyName == 'type';
    });
    String filedName = ORM.SQL.camelCaseToUnderscore(field.propertyName);
    final String sql = "select _2gis_partition_magic('${find.table.tableName}', '${filedName}');";
    try {
      int res = await (ORM.Model.ormAdapter.connection as psql.Connection).execute(sql);
      return res;
    } catch (error) {

    }
    return 0;
  }
}

@ORM.DBTable('realEstateObjectsGeneric')
class REGeneric extends ORM.Model with RealEstateBase {
  static Future<REGeneric> Get(ReType type, int id) {
    ORM.FindOne find = new ORM.FindOne(REGeneric);

    ORM.Condition cond = new ORM.Equals('type', ReUtils.type2Int(type));
    cond.and(new ORM.Equals('id', id));
    find.where(cond);

    return (find.execute() as Future<REGeneric>);
  }

  Logger _log;

  @ORM.DBField()
  @ORM.DBFieldPrimaryKey()
  @ORM.DBFieldType('SERIAL')
  int id;

  @ORM.DBField()
  String ontoId;

  @ORM.DBField()
  int type;

  @ORM.DBField()
  @ORM.DBFieldType('UNIQUE')
  String objectName;

  @ORM.DBField()
  bool isDisable;

  REGeneric() {
    _init();
  }

  REGeneric.Dummy(ReType type) {
    this.type = ReUtils.type2Int(type);
    _init();
  }

  _init() {
    if (type != null) {
      initLog();
    }
  }

  initLog() async {
    _log = new Logger('''
      BMSrv.${REGenericUtils.type2Onto(Type)}
      _$id''');
  }

  @override
  ReType get Type => ReUtils.int2Type(type);

  String toString(){
    return '${REGenericUtils.type2Onto(ReUtils.int2Type(type))} { id: $id, ObjectName: $objectName}';
  }
}
