library BMSrv.Models.ObjectDeal;

import 'dart:async';

import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:SrvCommon/SrvCommon.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';


@ORM.DBTable('userObjectDeal')
class ObjectDeal extends OntoEntity {
  
  Logger _log;
  @ORM.DBField()
  @ORM.DBFieldType('UNIQUE')
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
  
  ObjectDeal() {
    InitOnto("ObjectDeal");
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
  
  ObjectDeal.DummyRoom(User user, RERoom object, double _part) {
    InitOnto("ObjectDeal");
    userId = user.id;
    objectId = object.id;
    isPending = true;
    part = _part;
    initData(userId, object.id, ReUtils.type2Int(ReType.ROOM));
  }
  
  String get TypeName {
    return ReUtils.type2Str(ReUtils.int2Type(type));
  }
  
  Future<dynamic> GetObject() {
    ORM.FindOne find;
    switch(ReUtils.int2Type(type)) {
      case ReType.PRIVATE :
        find = new ORM.FindOne(REPrivate)..whereEquals('id', objectId);
        break;
      case ReType.COMMERCIAL :
        find = new ORM.FindOne(RECommercial)..whereEquals('id', objectId);
        break;
      case ReType.LAND :
        find = new ORM.FindOne(RELand)..whereEquals('id', objectId);
        break;
      case ReType.ROOM:
        find = new ORM.FindOne(RERoom)..whereEquals('id', objectId);
        break;
    }
    assert(find!=null);
    return find.execute();
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
