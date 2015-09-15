library BMSrv.Models.RealEstate.Private;
export 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';

import 'dart:async';

import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';
import 'package:SrvCommon/SrvCommon.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';

@ORM.DBTable('realEstateObjectsPrivate')
class REPrivate extends OntoEntity with RealEstateBase {
  static Future<REPrivate> Get(String id) {
    ORM.FindOne findOneItem = new ORM.FindOne(REPrivate)
                                  ..whereEquals('id', id);
    if (findOneItem != null) {
      return (findOneItem.execute() as Future<REPrivate>);
    }
    throw "not found ${id}";
  }
  
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
  
  REPrivate() {
    InitOnto("RealEstatePrivate");
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
  
  REPrivate.Dummy() {
    InitOnto("RealEstatePrivate");
  }
  
  initLog() async {
    _log = new Logger("BMSrv.REPrivate_$id");
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
  ReType get Type => ReType.PRIVATE;
    
  String toString(){
    return 'REPrivate { id: $id, ObjectName: $objectName}';
  }
}
