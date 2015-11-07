library BMSrv.Events.SystemEvents;

import 'package:SrvCommon/SrvCommon.dart';

enum TSysEvt {
  ADD_DEAL,
  ADD_USER,
  ADD_OBJ,
  ADD_ROOM
}

class SysEvt extends DomainEvent {
  final TSysEvt type;
  final dynamic data;
  SysEvt(this.type, [this.data]);
}