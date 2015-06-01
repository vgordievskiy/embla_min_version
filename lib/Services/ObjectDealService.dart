library BMSrv.ObjectDealService;
import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

import 'package:BMSrv/Events/Event.dart';
import 'package:BMSrv/Utils/DbAdapter.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';

bool _isEmpty(String value) => value == "";

Future<User> _getUser(String name) async {
  ORM.Find find = new ORM.Find(User)..where(new ORM.Equals('userName', name));
  List foundUsers = await find.execute();
  return foundUsers[0];
}

@app.Group("/object_deals")
class ObjectDealService {
  DBAdapter _Db;
  Uuid _Generator;
  final log = new Logger("BMSrv.Services.ObjectDealService");
  ObjectDealService(DBAdapter this._Db)
  {
    _Generator = new Uuid();
  }
}