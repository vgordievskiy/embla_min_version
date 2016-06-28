library tradem_srv.models.users;
import 'dart:async';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:tradem_srv/Middleware/Auth.dart';
import 'package:shelf_auth/shelf_auth.dart';

class UserGroup {
  final String _value;
  const UserGroup._internal(this._value);
  toString() => 'UserGroup.$_value';

  static const USER =
    const UserGroup._internal('USER');
  static const MANAGER =
      const UserGroup._internal('MANAGER');
  static const ADMIN =
      const UserGroup._internal('ADMIN');

  static final List<UserGroup> values =
    [ UserGroup.USER, UserGroup.MANAGER, UserGroup.ADMIN ];
  static UserGroup fromInt(int ind) => values[ind];
  static int toInt(UserGroup group) => values.indexOf(group);
  static String toStr(UserGroup group) => group._value;
}

class User extends Model {
  @field int id;
  @field String email;
  @field String password;
  @field bool enabled;
  @field String group;
  @field Map data;

  Map toJson() {
    return {
      'id' : id,
      'email' : email,
      'data' : data
    };
  }
}
