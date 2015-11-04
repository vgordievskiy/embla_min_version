library BMSrv.Models.User;

import 'dart:async';

import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';
import 'package:logging/logging.dart';

class UserUtils {
  static Future<List<User>> GetAll() {
    ORM.Find find = new ORM.Find(User);
    return find.execute();
  }
}

@ORM.DBTable('users')
class User extends ORM.Model {
  Logger _log;
  User() {
    initLog();
  }
  
  User.Dummy();
  
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
  
  @ORM.DBField()
  String profileImage;
  
  Future<List<ObjectDeal>> GetDeals() async {
    ORM.Find find = new ORM.Find(ObjectDeal)..whereEquals('userId', id);
    return find.execute(); 
  }

  String toString(){
    return 'User { id: $id, , name: $name, email: $email }';
  }
}
