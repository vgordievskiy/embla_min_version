library BMSrv.Models.User;

import 'dart:async';

import 'package:observe/observe.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';
import 'package:logging/logging.dart';

@ORM.DBTable('users')
class User extends OntoEntity {
  Logger _log;
  User() {
    InitOnto("User");
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
  
  User.Dummy() {
    InitOnto("User");
  }
  
  initLog() async {
    _log = new Logger("BMSrv.User_$id");
  }
  
  static Future<User> GetUser(String id) async {
    ORM.FindOne findOneItem = new ORM.FindOne(User)
                                  ..whereEquals('id', id);
    if (findOneItem != null) {
      return findOneItem.execute();
    }
    throw "not found ${id}";
  }
  
  @ORM.DBField()
  @ORM.DBFieldPrimaryKey()
  @ORM.DBFieldType('SERIAL')
  int id;

  @ORM.DBField()
  @ORM.DBFieldType('UNIQUE')
  String email;

  @ORM.DBField()
  String name;
  
  Future<List<ObjectDeal>> GetDeals() async {
    ORM.Find find = new ORM.Find(ObjectDeal)..whereEquals('userId', id);
    return find.execute(); 
  }

  String toString(){
    return 'User { id: $id, , name: $name, email: $email }';
  }
}
