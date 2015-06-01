library BMSrv.Models.ObjectDeal;

import 'dart:async';

import 'package:observe/observe.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:BMSrv/Storage/SemplexStorage.dart';
import 'package:BMSrv/Storage/BMOntology.dart';
import 'package:logging/logging.dart';

@ORM.DBTable('user_object_deal')
class ObjectDeal extends OntoEntity {
  Logger _log;
  RealEstate() {
    InitOnto("ObjectDeal");
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
  
  ObjectDeal.Dummy() {
    InitOnto("ObjectDeal");
  }
  
  initLog() async {
    _log = new Logger("BMSrv.ObjectDeal_$id");
  }
  
  static Future<ObjectDeal> GetObject(String id) {
    ORM.FindOne findOneItem = new ORM.FindOne(ObjectDeal)
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
  int objectId;
  
  @ORM.DBField()
  List<int> users;

  String toString(){
    return 'ObjectDeal { id: $id, objectId: $objectId}';
  }
}
