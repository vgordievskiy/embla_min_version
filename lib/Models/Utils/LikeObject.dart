library BMSrv.Models.Utils.LikeObject;

import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';
import 'package:BMSrv/Models/User.dart';

class LikeObjectsUtils {
  static Future<List<LikeObject>> GetForRoom(RERoom room) async {
    ORM.Find find = new ORM.Find(LikeObject)..whereEquals('roomId', room.id);
    return find.execute();
  }
  
  static Future<List<LikeObject>> GetForUser(User user) async {
    ORM.Find find = new ORM.Find(LikeObject)..whereEquals('userId', user.id);
    return find.execute();
  }
  
  static Future<bool> HaveLike(RERoom room,User user) async {
    ORM.Find find = new ORM.Find(LikeObject);
    ORM.Condition condition = new ORM.Equals('userId', user.id);
    condition.and(new ORM.Equals('roomId', room.id));
    find.where(condition);
    List<ORM.Model> result = await find.execute();
    return result.isEmpty == true ? false : true;
  }
  
  static Future<bool> CreateLike(RERoom room, User user)
  {
    LikeObject newLike = new LikeObject.Dummy(room, user);
    return newLike.save();
  }
}

@ORM.DBTable('like_for_objects')
class LikeObject extends ORM.Model {
  @ORM.DBField()
  @ORM.DBFieldPrimaryKey()
  @ORM.DBFieldType('SERIAL')
  int id;

  LikeObject();
  
  LikeObject.Dummy(RERoom room, User user)
  {
    objType = room.ownerObjectType;
    objId = room.ownerObjectId;
    roomId = room.id;
    userId = user.id;
  }
  
  @ORM.DBField()
  int objType;

  @ORM.DBField()
  int objId;
  
  @ORM.DBField()
  int roomId;
  
  @ORM.DBField()
  int userId;
  
  Future<RERoom> get room => RERoomUtils.getById(roomId);
  Future<User> get user => User.GetUser("$userId");
}
