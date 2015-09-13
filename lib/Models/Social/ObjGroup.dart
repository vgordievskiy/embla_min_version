library BMSrv.Models.Social.ObjGroup;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:SrvCommon/SrvCommon.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';

@ORM.DBTable('users_social_group_by_object')
class ObjGroup extends ORM.Model with Observable  {
  static List<int> _converter(Map<String, dynamic> value) {
    assert(value.containsKey('users'));
    return value['users']; 
  }
  
  @ORM.DBField()
  @ORM.DBFieldPrimaryKey()
  @ORM.DBFieldType('SERIAL')
  int id;
  
  @ORM.DBField()
  int objectType;
  
  @ORM.DBField()
  int objId;
  
  @ORM.DBField()
  @ORM.DBFieldConverter(_converter)
  dynamic _data;
    
  List<int> get Users => (_data as List<int>);
  
  Future addUser(int userId) async {
    if (Users == null) _data = [];
    List<int> value = Users;
    value.add(userId);
    _data = value;
    return save();
  }
  
  Future removeUser(int userId) async {
    List<int> value = Users;
    value.remove(userId);
    _data = value;
    return save();
  }
  
}