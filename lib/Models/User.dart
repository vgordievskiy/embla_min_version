library BMSrv.Models.User;

import 'package:dart_orm/dart_orm.dart' as ORM;

@ORM.DBTable('users')
class User extends ORM.Model {
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
