library BMSrv.Models.RealEstate.Rooms.Room;
import 'dart:async';

export 'package:BMSrv/Models/RealEstate/RealEstateGeneric.dart';

import 'package:logging/logging.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:postgresql/postgresql.dart' as psql;

import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';

class RERoomUtils {
  static _setFindParams(ORM.Find find, int count, int page) {
    if(count != null) find.setLimit(count);
    if(count != null && page != null && page > 0) {
      int offset = count * (page - 1);
      //find.setOffset(offset);
      find.offset = offset;
    }
  }
  
  static Future<List<RERoom>> getForOwner(RealEstateBase obj, {int count: null, int page: null}) async {
    ORM.Find find = new ORM.Find(RERoom)..whereEquals('ownerObjectId', obj.id);
    _setFindParams(find, count, page);
    return find.execute();
  }
  
  static Future<RERoom> getById(int id) async {
    ORM.FindOne find = new ORM.FindOne(RERoom)..whereEquals('id', id);
    return find.execute();
  }

  static Future<RERoom> getRooms({int count: null, int page: null}) async {
    ORM.Find find = new ORM.Find(RERoom);
    _setFindParams(find, count, page);
    return find.execute();
  }
  
  static Future<int> createPartition() async {
    ORM.Find find = new ORM.Find(RERoom);
    ORM.Field field = find.table.fields.firstWhere((ORM.Field f){
      return f.propertyName == 'ownerObjectId'; 
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

@ORM.DBTable('realEstateObjectsRooms')
class RERoom  extends OntoEntity with RealEstateBase {  
  static Future<RERoom> Get(int id, [int ownerId]) {
    ORM.FindOne find = new ORM.FindOne(RERoom);
    
    ORM.Condition cond = new ORM.Equals('id', id);
    if (ownerId != null) cond.and(new ORM.Equals('ownerObjectId', ownerId));
    find.where(cond);
    
    return (find.execute() as Future<RERoom>);
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
       /*this.changes.listen((List<dynamic> changes){
         for(var change in changes) {
           _log.info(change);
         }
       });
       OntoIndivid.Get(ind);*/
     });
   }
   
   RERoom.Dummy(ReType type, RealEstateBase ownerObject) {
     InitOnto("RealEstateRoom");
     initData(ownerObject.id, type);
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
   
   @override
   ReType get Type => ReType.ROOM;
   
   Future<RealEstateBase> GetOwner() async {
     return REGeneric.Get(OwnerType, ownerObjectId);
   }
   
   ReType get OwnerType => ReUtils.int2Type(ownerObjectType);
   
   String toString(){
     return 'RERoom { id: $id, ObjectName: $objectName}';
   }
}
