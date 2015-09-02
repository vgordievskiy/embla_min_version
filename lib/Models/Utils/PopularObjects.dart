library BMSrv.Models.Utils.PopularObjects;

import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';

class PopularObjectsUtils {
  static Future<PopularObjects> GetForRoom(RERoom room) async {
    ORM.FindOne find = new ORM.FindOne(PopularObjects)..whereEquals('roomId', room.id);
    return find.execute();
  }
}

@ORM.DBTable('popular_objects')
class PopularObjects extends ORM.Model {
  @ORM.DBField()
  @ORM.DBFieldPrimaryKey()
  @ORM.DBFieldType('SERIAL')
  int id;

  PopularObjects.Dummy(RERoom room)
  {
    objType = room.ownerObjectType;
    objId = room.ownerObjectId;
    roomId = room.id;
    count  = 0;
  }
  
  @ORM.DBField()
  int objType;

  @ORM.DBField()
  int objId;
  
  @ORM.DBField()
  int roomId;
  
  @ORM.DBField()
  int count;
  
  Future Inc() {
    ++count;
    return update();
  }
  
}
