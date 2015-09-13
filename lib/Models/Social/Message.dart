library BMSrv.Models.Social.Message;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:SrvCommon/SrvCommon.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';

import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/User.dart';

enum MessageType {
  USER,
  GROUP
}

class MessageUtils {
  static type2int(MessageType type) {
    switch(type) {
      case MessageType.USER:
        return 0;
      case MessageType.GROUP:
        return 1;
    }
  }
  static int2type(int type) {
    switch(type){
      case 0:
        return MessageType.USER;
      case 1:
        return MessageType.GROUP;
    }
  }
}

@ORM.DBTable('user_social_messages')
class Message extends ORM.Model with Observable  {
  static List<int> _converter(Map<String, dynamic> value) {
    assert(value.containsKey('users'));
    return value['users']; 
  }
  
  static List<int> _convMessage(Map<String, dynamic> value) {
    assert(value.containsKey('message'));
    return value['message']; 
  }
  
  Message(): super() {}
  
  Message.Dummy(): super() {
    _usersReaded = { "users" : [] };
    _message = { "data" : "" };
  }
  
  @ORM.DBField()
  @ORM.DBFieldPrimaryKey()
  @ORM.DBFieldType('SERIAL')
  int id;
  
  @ORM.DBField()
  int messageType;
  
  @ORM.DBField()
  int targetId;
  
  @ORM.DBField()
  int sourceId;
  
  @ORM.DBField()
  DateTime timeStamp;
  
  @ORM.DBField()
  @ORM.DBFieldConverter(_convMessage)
  dynamic _message;
  
  @ORM.DBField()
  @ORM.DBFieldConverter(_converter)
  dynamic _usersReaded;
    
  List<int> get Users => (_usersReaded as List<int>);
  set Users(List<int> value) {
    _usersReaded = { "users" : value };
  }
  
}