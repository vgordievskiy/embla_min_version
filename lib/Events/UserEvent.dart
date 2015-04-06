library BMSrv.Events.UserEvents;

import 'package:BMSrv/Events/EventBus.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/OntoUser.dart';

class UserLogged extends EventCompleterBase<OntoUser>{
  final int Id;
  UserLogged(this.Id);

  @override
  void Done(OntoUser user) {
    UpdateUser event = new UpdateUser(user);
    EventSys.GetEventBus().fire(event);
    event.Result.then((OntoUser user){
      this.IntCompleter.complete(user);
    });
  }
}

class CreateUser {
  final int Id;
  final User user;
  CreateUser(this.Id, this.user);
}

class UpdateUser extends EventCompleterBase<OntoUser> {
  OntoUser user;
  UpdateUser(this.user);

  @override
  void Done(OntoUser user) {
    /*UpdateUserGoals eventGoals = new UpdateUserGoals(user);
    UpdateUserTasks eventTasks = new UpdateUserTasks(user);

    EventSys.GetEventBus().fire(eventGoals);
    EventSys.GetEventBus().fire(eventTasks);

    Future.wait([eventTasks.Result, eventGoals.Result]).then((List results){
      this.IntCompleter.complete(user);
    });*/
  }
}

