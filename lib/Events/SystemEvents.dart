library BMSrv.Events.SystemEvents;

import 'package:SrvCommon/SrvCommon.dart';

class SysEvt extends DomainEvent {
  final String type;
  final Object data;
  SysEvt(this.type, [this.data]);
}