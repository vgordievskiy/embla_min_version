library BMSrv.Models.RealEstate.Commercial;

import 'dart:async';

import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Storage/BMOntology.dart';
import 'package:BMSrv/Storage/SemplexStorage.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';

@ORM.DBTable('real_estate_objects_commercial')
class RECommercial extends OntoEntity with RealEstateBase {
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

  static Future<RECommercial> Get(String id) {
    ORM.FindOne findOneItem = new ORM.FindOne(RECommercial)
                                  ..whereEquals('id', id);
    if (findOneItem != null) {
      return findOneItem.execute();
    }
    throw "not found ${id}";
  }
}