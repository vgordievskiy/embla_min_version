library BMSrv.Models.RealEstate.Land;

import 'dart:async';

import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:SrvCommon/SrvCommon.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';

@ORM.DBTable('real_estate_objects_land')
class RELand extends OntoEntity with RealEstateBase {
  Logger _log;
  @ORM.DBField()
  @ORM.DBFieldPrimaryKey()
  @ORM.DBFieldType('SERIAL')
  int id;
  
  @ORM.DBField()
  @ORM.DBFieldType('UNIQUE')
  String ontoId;
  
  @ORM.DBField()
  @ORM.DBFieldType('UNIQUE')
  String objectName;
  
  RELand() {
    InitOnto("RealEstateLand");
    initLog();
    loadOntoInfo().then((ind){
      /*this.changes.listen((List<dynamic> changes){
        for(var change in changes) {
          _log.info(change);
        }
      });*/
      OntoIndivid.Get(ind);
    });
  }
  
  RELand.Dummy() {
    InitOnto("RealEstateLand");
  }
  
  initLog() async {
    _log = new Logger("BMSrv.RELand_$id");
  }

  @override
  Future<bool> save() async {
    if (this.id == null) {
      try {
        bool res = await super.save();
        if (res == true) {
          this.ontoId = $.EntityName;
          return super.save();
        }
        return res;
      } catch(error) { throw error; }
    } else {
      return super.save();
    }
  }
  
  @override
  ReType get Type => ReType.LAND;
  
  String toString(){
    return 'RELand { id: $id, ObjectName: $objectName}';
  }

  static Future<RELand> Get(String id) {
    ORM.FindOne findOneItem = new ORM.FindOne(RELand)
                                  ..whereEquals('id', id);
    if (findOneItem != null) {
      return (findOneItem.execute() as Future<RELand>);
    }
    throw "not found ${id}";
  }
}