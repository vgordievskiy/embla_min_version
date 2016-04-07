library BMSrv.MailService;
import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Events/UserEvent.dart';
import 'package:BMSrv/Models/User.dart';

@app.Group("/messages")
class MailService {
  final log = new Logger("BMSrv.Services.MailService");
  MailService();
}
