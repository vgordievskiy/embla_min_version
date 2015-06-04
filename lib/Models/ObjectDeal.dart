library BMSrv.Models.ObjectDeal;

import 'dart:async';

import 'package:BMSrv/Models/RealEstate/REPrivate.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Storage/BMOntology.dart';
import 'package:BMSrv/Storage/SemplexStorage.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';

@ORM.DBTable('user_object_deal')
class ObjectDeal extends OntoEntity {
  
  static const int Private = 0;
  static const int Commercial = 1;
  static const int Land = 2;
  
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
  
  ObjectDeal.DummyCommercial(User user, RECommercial object, double _part) {
    InitOnto("ObjectDeal");
    userId = user.id;
    objectId = object.id;
    isPending = true;
    part = _part;
    initData(userId, object.id, Commercial);
  }
  
  ObjectDeal.DummyLand(User user, RELand object, double _part) {
    InitOnto("ObjectDeal");
    userId = user.id;
    objectId = object.id;
    isPending = true;
    part = _part;
    initData(userId, object.id, Land);
  }

  ObjectDeal.DummyPrivate(User user, REPrivate object, double _part) {
    InitOnto("ObjectDeal");
    userId = user.id;
    objectId = object.id;
    isPending = true;
    part = _part;
    initData(userId, object.id, Private);
  }
  
  String get TypeName {
    switch(type) {
      case Private :
        return "private";
      case Commercial :
        return "commercial";
      case Land :
        return "land";
    }
    assert(false);
    return "";
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
