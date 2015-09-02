library BMSrv.Models.Utils.PopularObjects;

import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;

@ORM.DBTable('popular_objects')
class PopularObjects extends ORM.Model {
  @ORM.DBField()
  @ORM.DBFieldPrimaryKey()
  @ORM.DBFieldType('SERIAL')
  int id;

  @ORM.DBField()
  int objType;

  @ORM.DBField()
  int objId;
  
  @ORM.DBField()
  int roomId;
  
  @ORM.DBField()
  int count;
}
