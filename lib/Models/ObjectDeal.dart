library BMSrv.Models.ObjectDeal;

import 'dart:async';

import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:SrvCommon/SrvCommon.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';

@ORM.DBTable('userObjectDeal')
class ObjectDeal extends ORM.Model {
  
  Logger _log;
  @ORM.DBField()
  String ontoId;
  
  @ORM.DBField()
  @ORM.DBFieldPrimaryKey()
  @ORM.DBFieldType('SERIAL')
  int id;
  
  @ORM.DBField()
  int objectId;
  
  @ORM.DBField()
  int userId;
  
  @ORM.DBField()
  int type;
  
  @ORM.DBField()
  bool isPending;
  
  @ORM.DBField()
  double part;
  
  @ORM.DBField()
  double price;
  
  @ORM.DBField()
  DateTime createTime;
  
  @ORM.DBField()
  DateTime approveTime;
  
  ObjectDeal() {
    initLog();
  }
  
  ObjectDeal.DummyRoom(User user, RERoom object, double _part, double price) {
    userId = user.id;
    objectId = object.id;
    isPending = true;
    part = _part;
    this.price = price;
    createTime = new DateTime.now();
    initData(userId, object.id, ReUtils.type2Int(ReType.ROOM));
  }
  
  String get TypeName {
    return ReUtils.type2Str(ReUtils.int2Type(type));
  }
  
  Future<dynamic> GetObject() {
    ReType intType = ReUtils.int2Type(type);
    if (intType != ReType.ROOM) {
      return REGeneric.Get(intType, id);
    } else {
      return RERoom.Get(id);
    }
  }
  
  Future<User> GetUser() {
    ORM.FindOne find = new ORM.FindOne(User)..whereEquals('id', userId);
    return (find.execute() as Future<User>);
  }
  
  initData(int UserId, int REId, int typeId) {
    userId = UserId;
    objectId = REId;
    type = typeId;
  }
  
  initLog() async {
    _log = new Logger("BMSrv.ObjectDeal_$id");
  }
  
  String toString(){
    return 'ObjectDeal { id: $id, objectId: $objectId userId: $userId, type: $type}';
  }

  static Future<ObjectDeal> Get(String id) {
    ORM.FindOne findOneItem = new ORM.FindOne(ObjectDeal)
                                  ..whereEquals('id', id);
    if (findOneItem != null) {
      return (findOneItem.execute() as Future<ObjectDeal>);
    }
    throw "not found ${id}";
  }
}
