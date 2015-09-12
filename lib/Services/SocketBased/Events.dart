library BMSrv.SocketBased.Events;

import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:redstone_web_socket/redstone_web_socket.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';
import 'package:SrvCommon/SrvCommon.dart';

@WebSocketHandler("/events")
class EventService {
  final log = new Logger("BMSrv.Services.SocketBased.Events");
  
  @OnOpen()
  void onOpen(WebSocketSession session) {
    log.info("connection established");
  }

  @OnMessage()
  void onMessage(String message, WebSocketSession session) {
    log.info("message received: $message");
    session.connection.add("pong");
  }

  @OnError()
  void onError(error, WebSocketSession session) {
    log.warning("error: $error");
  }

  @OnClose()
  void onClose(WebSocketSession session) {
    log.info("connection closed");
  }
}