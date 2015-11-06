library BMSrv.Events.SystemEvents;

import 'package:SrvCommon/SrvCommon.dart';

class SysEvt extends DomainEvent {
  final String type;
  final dynamic data;
  SysEvt(this.type, [this.data]);
}