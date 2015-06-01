library BMSrv.Models.RealEstate.Private;

import 'dart:async';

import 'package:observe/observe.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:BMSrv/Storage/SemplexStorage.dart';
import 'package:BMSrv/Storage/BMOntology.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:logging/logging.dart';

@ORM.DBTable('real_estate_objects_private')
class REPrivate extends OntoEntity {
  Logger _log;
  REPrivate() {
    InitOnto("RealEstatePrivate");
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
  
  REPrivate.Dummy() {
    InitOnto("RealEstatePrivate");
  }
  
  initLog() async {
    _log = new Logger("BMSrv.REPrivate_$id");
  }
  
  static Future<REPrivate> GetObject(String id) {
    ORM.FindOne findOneItem = new ORM.FindOne(REPrivate)
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
    return 'REPrivate { id: $id, ObjectName: $objectName}';
  }
}
