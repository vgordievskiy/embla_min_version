library BMSrv.Models.RealEstate.REMetaData;

import 'dart:async';
import 'dart:collection';

import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:SrvCommon/SrvCommon.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:observe/observe.dart';

class REMetaDataUtils {
  
}

@ORM.DBTable('real_estate_objects_meta_data')
class REMetaData extends ORM.Model with Observable {
  
  @ORM.DBField()
  @ORM.DBFieldPrimaryKey()
  @ORM.DBFieldType('SERIAL')
  int id;
  
  @ORM.DBField()
  String name;
  
  @ORM.DBField()
  String metaName;
  
  @ORM.DBField()
  int ownerType;
  
  @ORM.DBField()
  int ownerId;
  
  @ORM.DBField()
  LinkedHashMap<String, dynamic> data;
}