library BMSrv.Models.RealEstate;

import 'dart:async';

import 'package:observe/observe.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:BMSrv/Storage/SemplexStorage.dart';
import 'package:BMSrv/Storage/BMOntology.dart';
import 'package:logging/logging.dart';

@ORM.DBTable('real_state_objects')
class RealEstate extends OntoEntity {
  Logger _log;
  RealEstate() {
    InitOnto("RealEstate");
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
  
  RealEstate.Dummy() {
    InitOnto("RealEstate");
  }
  
  initLog() async {
    _log = new Logger("BMSrv.RealEstate_$id");
  }
  
  static Future<RealEstate> GetObject(String id) {
    ORM.FindOne findOneItem = new ORM.FindOne(RealEstate)
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
    return 'RealEstate { id: $id, ObjectName: $objectName}';
  }
}
