library BMSrv.Controllers.UserManager;

export 'package:BMSrv/Models/OntoUser.dart';

import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import 'package:BMSrv/Models/OntoUser.dart';
import 'package:BMSrv/Models/UserPeper/UserPaper.dart';
import 'package:BMSrv/Events/Event.dart';
import 'package:BMSrv/Models/User.dart' as Db;

class UserManager {
  EventBus _Evt = EventSys.GetEventBus();
  Uuid _Generator = new Uuid();
  final _log = new Logger("BMSrv.Services.UserManager");

  UserManager() {
    OntoUser.InitBaseClass();
    UserPaper.InitBaseClass();
    PaperItem.InitBaseClass();
    _InitEvents();
  }

  Map<int, OntoUser> Users = new Map();

  void _InitEvents() {
    _Evt.on(UserLogged).listen((UserLogged event) async {
      if (!Users.containsKey(event.Id)) {
        Users[event.Id] = new OntoUser("${event.Id}");
      }

      dynamic repr = await Users[event.Id].GetRepresentation();
      Users[event.Id].Repr = repr;

      event.Done(Users[event.Id]);
    });

    _Evt.on(CreateUser).listen((CreateUser event) async {
      await DoCreateUser(event.Id, event.user);
    });
  }

  dynamic DoCreateUser(int id, Db.User user) async {
    Map<String, dynamic> params = new Map();
    params["name"] = user.name;
    params["email"] = user.email;
    params["id"] = user.id;
    OntoUser newUser = await OntoUser.Create("${id}", params);
  }

  OntoUser GetUser(int id) {
    if (Users.containsKey(id)) {
      return Users[id];
    }
    return null;
  }
}