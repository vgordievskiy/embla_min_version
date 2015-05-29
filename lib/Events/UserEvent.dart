library BMSrv.Events.UserEvents;

import 'package:BMSrv/Events/EventBus.dart';
import 'package:BMSrv/Models/User.dart';

class UserLogged extends EventCompleterBase<User>{
  final int Id;
  UserLogged(this.Id);
}

