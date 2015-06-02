library BMSrv.Models.RealEstate.Commercial;

import 'dart:async';

import 'package:observe/observe.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:BMSrv/Storage/SemplexStorage.dart';
import 'package:BMSrv/Storage/BMOntology.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:logging/logging.dart';

@ORM.DBTable('real_estate_objects_commercial')
class RECommercial extends OntoEntity {
  Logger _log;
  RECommercial() {
    InitOnto("RealEstateCommercial");
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
  
  RECommercial.Dummy() {
    InitOnto("RealEstateCommercial");
  }
  
  initLog() async {
    _log = new Logger("BMSrv.RECommercial_$id");
  }
  
  static Future<RECommercial> Get(String id) {
    ORM.FindOne findOneItem = new ORM.FindOne(RECommercial)
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
  String ontoId;

  @ORM.DBField()
  @ORM.DBFieldType('UNIQUE')
  String objectName;
  
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

  String toString(){
    return 'RECommercial { id: $id, ObjectName: $objectName}';
  }
}