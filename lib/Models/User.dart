library BMSrv.Models.User;

import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:BMSrv/Storage/SemplexStorage.dart';
import 'package:BMSrv/Storage/BMOntology.dart';

@ORM.DBTable('users')
class User extends ORM.Model {

  static OntoClass OwnerClass = null;
      
  static dynamic InitBaseClass() async {
    if (OwnerClass == null) {
      OwnerClass = await GetOntology().GetClass("User");
    }
    return OwnerClass;
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
