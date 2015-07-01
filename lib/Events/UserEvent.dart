library BMSrv.Events.UserEvents;

import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Models/User.dart';

class UserLogged extends EventCompleterBase<User>{
  final int Id;
  UserLogged(this.Id);
}

