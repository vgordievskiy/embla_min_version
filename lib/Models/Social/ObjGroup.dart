library BMSrv.Models.Social.ObjGroup;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:SrvCommon/SrvCommon.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';

import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/User.dart';

class ObjGroupUtils {
  
  static Future<ObjGroup> getForObject(RealEstateBase obj) async {
    ORM.FindOne find = new ORM.FindOne(ObjGroup);
    ORM.Condition cond = new ORM.Equals('objectType', ReUtils.type2Int(obj.Type));
    cond.and(new ORM.Equals('objId', obj.id));
    return find.execute();
  }
  
  static Future<ObjGroup> addUserToGroup(RealEstateBase obj, User user) async {
    ObjGroup grp = await getForObject(obj);
    if (grp == null) {
      grp = await createGroup(obj);
    }
    return  grp.addUser(user.id);
  }
  
  static Future<ObjGroup> createGroup(RealEstateBase obj) async {
    ObjGroup grp = new ObjGroup.Dummy();
    grp.objectType = ReUtils.type2Int(obj.Type);
    grp.objId = obj.id;
    bool res = await grp.save();
    return res == true ? getForObject(obj) : null;
  }
}

@ORM.DBTable('users_social_group_by_object')
class ObjGroup extends ORM.Model with Observable  {
  static List<int> _converter(Map<String, dynamic> value) {
    assert(value.containsKey('users'));
    return value['users']; 
  }
  
  ObjGroup(): super() {
    
  }
  
  ObjGroup.Dummy(): super() {
    _data = { "users" : [] };
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
  set Users(List<int> value) {
    _data = { "users" : value };
  }
  
  Future<bool> addUser(int userId) async {
    if (Users == null) _data = [];
    List<int> value = Users;
    if (!value.contains(userId)){
      value.add(userId);
      Users = value;
      return save();
    }
    return true;
  }
  
  Future<bool> removeUser(int userId) async {
    List<int> value = Users;
    value.remove(userId);
    Users = value;
    return save();
  }
  
}