library BMSrv.Models.RealEstate.Rooms.Room;
import 'dart:async';

export 'package:BMSrv/Models/RealEstate/REPrivate.dart';
export 'package:BMSrv/Models/RealEstate/RECommercial.dart';

import 'package:logging/logging.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;

import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';

@ORM.DBTable('real_estate_objects_rooms')
class RERoom  extends OntoEntity with RealEstateBase {
   
  static Future<RERoom> Get(String id) {
    ORM.FindOne findOneItem = new ORM.FindOne(RERoom)
                                  ..whereEquals('id', id);
    if (findOneItem != null) {
      return (findOneItem.execute() as Future<RERoom>);
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
   int ownerObjectId;
   
   @ORM.DBField()
   int ownerObjectType;
   
   @ORM.DBField()
   @ORM.DBFieldType('UNIQUE')
   String objectName;
   
   @ORM.DBField()
   double square;
   
   RERoom() {
     InitOnto("RealEstateRoom");
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
   
   RERoom.DummyCommercial(RECommercial ownerObject, double square) {
     InitOnto("RealEstateRoom");
     initData(ownerObject.id, ReType.COMMERCIAL);
     
     this.square = square;
   }
   
   RERoom.DummyPrivate(REPrivate ownerObject, double square) {
     InitOnto("RealEstateRoom");
     initData(ownerObject.id, ReType.PRIVATE);
     
     this.square = square;
   }
   
   initData(int ownerId, ReType ownerType) {
     this.ownerObjectId = ownerId;
     this.ownerObjectType = ReUtils.type2Int(ownerType);
   }
   
   initLog() async {
     _log = new Logger("BMSrv.RERoom_$id");
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
     return 'RERoom { id: $id, ObjectName: $objectName}';
   }
}
