library BMSrv.Models.ObjectDeal;

import 'dart:async';

import 'package:observe/observe.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:BMSrv/Storage/SemplexStorage.dart';
import 'package:BMSrv/Storage/BMOntology.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/RealEstate/REPrivate.dart';

@ORM.DBTable('user_object_deal')
class ObjectDeal extends OntoEntity {
  
  static const int Private = 0;
  static const int Commercial = 1;
  static const int Land = 2;
  
  Logger _log;
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
  
  ObjectDeal.DummyPrivate(User user, REPrivate object) {
    InitOnto("ObjectDeal");
    userId = user.id;
    objectId = object.id;
    initData(userId, object.id, Private);
  }
  
  ObjectDeal.DummyCommercial(User user, RECommercial object) {
    InitOnto("ObjectDeal");
    userId = user.id;
    objectId = object.id;
    initData(userId, object.id, Commercial);
  }
  
  ObjectDeal.DummyLand(User user, RELand object) {
    InitOnto("ObjectDeal");
    userId = user.id;
    objectId = object.id;
    initData(userId, object.id, Land);
  }
  
  initData(int UserId, int REId, int typeId) {
    userId = UserId;
    objectId = REId;
    type = typeId;
  }
  
  initLog() async {
    _log = new Logger("BMSrv.ObjectDeal_$id");
  }
  
  static Future<ObjectDeal> Get(String id) {
    ORM.FindOne findOneItem = new ORM.FindOne(ObjectDeal)
                                  ..whereEquals('id', id);
    if (findOneItem != null) {
      return findOneItem.execute();
    }
    throw "not found ${id}";
  }
  
  @ORM.DBField()
  @ORM.DBFieldType('UNIQUE')
  String ontoId;
  
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
  
  Future<User> GetUser() {
    ORM.FindOne find = new ORM.FindOne(User)..whereEquals('id', userId);
    return find.execute();
  }
  
  Future<dynamic> GetObject() {
    ORM.FindOne find;
    switch(type) {
      case Private :
        find = new ORM.FindOne(REPrivate)..whereEquals('id', objectId);
        break;
      case Commercial :
        find = new ORM.FindOne(RECommercial)..whereEquals('id', objectId);
        break;
      case Land :
        find = new ORM.FindOne(RELand)..whereEquals('id', objectId);
        break;
    }
    assert(find!=null);
    return find.execute();
  }

  String toString(){
    return 'ObjectDeal { id: $id, objectId: $objectId userId: $userId, type: $type}';
  }
}
