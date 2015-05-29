library BMSrv.UserService;
import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

import 'package:BMSrv/Events/Event.dart';
import 'package:BMSrv/Utils/DbAdapter.dart';
import 'package:BMSrv/Utils/Encrypter.dart' as Enc;
import 'package:BMSrv/Models/User.dart';

bool _isEmpty(String value) => value == "";

Future<User> _getUser(String name) async {
  ORM.Find find = new ORM.Find(User)..where(new ORM.Equals('userName', name));
  List foundUsers = await find.execute();
  return foundUsers[0];
}

@app.Group("/users")
class UserService {
  DBAdapter _Db;
  Uuid _Generator;
  final log = new Logger("BMSrv.Services.UserService");
  UserService(DBAdapter this._Db)
  {
    _Generator = new Uuid();
  }

  @app.DefaultRoute(methods: const[app.POST])
  create(@app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['username']) ||
        _isEmpty(data['password']) ||
        _isEmpty(data['name']) ||
        _isEmpty(data['email']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }

    User newUser = new User();
    newUser.userName = data['username'];
    newUser.name = data['name'];
    newUser.password = Enc.encryptPassword(data["password"]);
    newUser.email = data['email'];

    var exception = null;

    var saveResult = await newUser.save().catchError((var error){
      exception = error;
    });

    if (exception != null) {
      return exception;
    } else {
      User dbUser = await _getUser(newUser.userName);
      return { "status" : "created" };
    }
  }

  @app.Route("/:id")
  @Encode()
  Future<dynamic> getUserById(String id) async {
    User user = await User.GetUser(id);
    return user.toString();
  }

}