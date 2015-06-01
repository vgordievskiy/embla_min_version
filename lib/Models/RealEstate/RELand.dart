library BMSrv.Models.RealEstate.Land;

import 'dart:async';

import 'package:observe/observe.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:BMSrv/Storage/SemplexStorage.dart';
import 'package:BMSrv/Storage/BMOntology.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:logging/logging.dart';

@ORM.DBTable('real_estate_objects_land')
class RELand extends OntoEntity {
  Logger _log;
  RELand() {
    InitOnto("RealEstateLand");
    initLog();
    loadOntoInfo().then((ind){
      this.changes.listen((List<dynamic> changes){
        for(var change in changes) {
          _log.info(change);
        }
      });
      OntoIndivid.Get(ind);
    });
  }
  
  RELand.Dummy() {
    InitOnto("RealEstateLand");
  }
  
  initLog() async {
    _log = new Logger("BMSrv.RELand_$id");
  }
  
  static Future<RELand> GetObject(String id) {
    ORM.FindOne findOneItem = new ORM.FindOne(RELand)
                                  ..whereEquals('id', id);
    if (findOneItem != null) {
      return findOneItem.execute();
    }
    throw "not found ${id}";
  }
  
  @ORM.DBField()
  @ORM.DBFieldPrimaryKey()
  @ORM.DBFieldType('SERIAL')
  int id;

  @ORM.DBField()
  @ORM.DBFieldType('UNIQUE')
  String objectName;

  String toString(){
    return 'RELand { id: $id, ObjectName: $objectName}';
  }
}