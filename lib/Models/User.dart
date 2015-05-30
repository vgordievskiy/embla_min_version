library BMSrv.Models.User;

import 'dart:async';

import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:BMSrv/Storage/SemplexStorage.dart';
import 'package:BMSrv/Storage/BMOntology.dart';
import 'package:logging/logging.dart';

@ORM.DBTable('users')
class User extends OntoEntity {
  Logger _log;
  User() {
    InitOnto("User");
    initLog();
    loadOntoInfo().then((ind){
      OntoIndivid.Get(ind);
    });
  }
  
  User.Dummy() {
    InitOnto("User");
  }
  
  initLog() async {
    _log = new Logger("BMSrv.User_$id");
  }
  
  static Future<User> GetUser(String id) {
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
  String userName;

  @ORM.DBField()
  String name;

  @ORM.DBField()
  String email;

  @ORM.DBField()
  String password;

  String toString(){
    return 'User { id: $id, userName: $userName, name: $name, email: $email, passowrd: $password }';
  }
}
