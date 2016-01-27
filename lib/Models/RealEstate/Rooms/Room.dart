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

  static Future<List<RERoom>> getForOwner(RealEstateBase obj,
                                          {int count: null,
                                           int page: null})
  async {
    ORM.Find find = new ORM.Find(RERoom)..whereEquals('ownerObjectId', obj.id);
    _setFindParams(find, count, page);
    return find.execute();
  }

  static Future<RERoom> getById(int id, [bool inclDisabled = false]) async {
    ORM.FindOne find = new ORM.FindOne(RERoom)..whereEquals('id', id);

    !inclDisabled ? find.whereEquals('isDisabled', false) : null;

    return find.execute();
  }

  static Future<RERoom> getRooms({int count: null,
                                  int page: null,
                                  bool inclDisabled: false})
  async {
    ORM.Find find = new ORM.Find(RERoom);
    !inclDisabled ? find.whereEquals('isDisabled', false) : null;
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
class RERoom  extends ORM.Model with RealEstateBase {
  static Future<RERoom> Get(int id, [int ownerId]) {
    ORM.FindOne find = new ORM.FindOne(RERoom);

    //!inclDisabled ? find.whereEquals('isDisabled', false) : null;

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

   @ORM.DBField()
   bool isDisable;

   RERoom() {
     initLog();
   }

   RERoom.Dummy(ReType type, RealEstateBase ownerObject) {
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
   ReType get Type => ReType.ROOM;

   Future<RealEstateBase> GetOwner() async {
     return REGeneric.Get(OwnerType, ownerObjectId);
   }

   ReType get OwnerType => ReUtils.int2Type(ownerObjectType);

   Future<double> get Price async {
     List<REMetaData> data = await REMetaDataUtils
       .getForObject(this, fieldName: 'pricePerMeter');
     if(data.isEmpty) return 0.0;
     assert(data.length == 1);
     return data[0].Data;
   }

   String toString(){
     return 'RERoom { id: $id, ObjectName: $objectName}';
   }
}
