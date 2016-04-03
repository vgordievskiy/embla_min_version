library BMSrv.Models.User;

import 'dart:async';

import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:uuid/uuid.dart';
import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';
import 'package:logging/logging.dart';

class UserUtils {
  static Future<List<User>> GetAll() {
    ORM.Find find = new ORM.Find(User);
    return find.execute();
  }

  static Future<User> GetUserByUniqueId(String id) async {
     ORM.FindOne findOneItem = new ORM.FindOne(User)
                                   ..whereEquals('uniqueID', id);
     return findOneItem.execute();
  }

  static Future<User> GetUserByEmail(String email) async {
     ORM.FindOne findOneItem = new ORM.FindOne(User)
                                   ..whereEquals('email', email);
     return findOneItem.execute();
  }
}

@ORM.DBTable('users')
class User extends ORM.Model {
  static Uuid UniqId = new Uuid();

  Logger _log;
  User() {
    initLog();
  }

  User.Dummy()
  {
    registerTime = new DateTime.now();
    uniqueID = UniqId.v4();
    enabled = false;
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

  @ORM.DBField()
  String profileImage;

  @ORM.DBField()
  DateTime registerTime;

  @ORM.DBField()
  @ORM.DBFieldType('UNIQUE')
  String uniqueID;

  @ORM.DBField()
  bool enabled;

  @ORM.DBField()
  String phone;

  Future<List<ObjectDeal>> GetDeals() async {
    ORM.Find find = new ORM.Find(ObjectDeal)..whereEquals('userId', id);
    return find.execute();
  }

  Future Activate() {
    enabled = true;
    return this.save();
  }

  String toString(){
    return 'User { id: $id, , name: $name, email: $email }';
  }
}
