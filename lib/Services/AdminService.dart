library BMSrv.AdminService;
import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';
import 'package:BMSrv/Models/Utils/LikeObject.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';

import 'package:BMSrv/Models/JsonWrappers/User.dart';
import 'package:BMSrv/Models/JsonWrappers/ObjectDeal.dart';
import 'package:BMSrv/Models/JsonWrappers/RERoom.dart';

bool _isEmpty(String value) => value == "";

Future<User> _getUser(String email) async {
  ORM.Find find = new ORM.Find(User)..where(new ORM.Equals('email', email));
  List foundUsers = await find.execute();
  return foundUsers[0];
}

Future<dynamic> _getObject(ReType type, String id) {
  switch (type) {
    case ReType.PRIVATE : return REPrivate.Get(id);
    case ReType.COMMERCIAL : return RECommercial.Get(id);
    case ReType.LAND : return RELand.Get(id);
    case ReType.ROOM : return RERoom.Get(id);
  }
}

@app.Group("/admin")
class AdminService {
  DBAdapter _Db;
  Uuid _Generator;
  final log = new Logger("BMSrv.Services.AdminService");
  AdminService(DBAdapter this._Db)
  {
    _Generator = new Uuid();
  }

  @app.DefaultRoute(methods: const[app.POST])
  create(@app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['password']) ||
        _isEmpty(data['name']) ||
        _isEmpty(data['email']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }

    User newUser = new User.Dummy();
    newUser.name = data['name'];
    newUser.email = data['email'];

    var exception = null;

    var saveResult = await newUser.save().catchError((var error){
      exception = error;
    });
    
    await UserPass.CreateAdminPass(data['email'], data["password"], newUser.id);
    
    if (exception != null) {
      return exception;
    } else {
      
      await newUser.$.AddData("hasUserName", newUser.name);
      await newUser.$.AddData("hasEmail", newUser.email);
      await newUser.$.AddData("hasUserId", newUser.id);
      
      User dbUser = await _getUser(newUser.email);
      return { "status" : "created" };
    }
  }

  @app.Route("/:id")
  @Encode()
  Future<UserWrapper> getAdminById(String id) async {
    return UserWrapper.Create(await User.GetUser(id));
  }
}