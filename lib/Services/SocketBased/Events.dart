library BMSrv.SocketBased.Events;

import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:uuid/uuid.dart';
import 'package:redstone_web_socket/redstone_web_socket.dart';
import 'package:SrvCommon/SrvCommon.dart' as Common;
import 'package:logging/logging.dart';

import 'package:BMSrv/Events/SystemEvents.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';

@WebSocketHandler("events")
class EventService {
  final log = new Logger("BMSrv.Services.SocketBased.Events");
  
  Common.LoginService login;
  
  EventService() {
    login = new Common.LoginService();
    login.addToOpenResource('events');
    initEvtSystem();
  }
  
  initEvtSystem() {
    Common.EventSys.asyncMessageBus.subscribe(SysEvt, onSysEvtHandler);
  }
  
  onSysEvtHandler(SysEvt evt) {
    log.info("${evt.type}");
    switch(evt.type) {
      case 'add-deal' : 
      {
        ObjectDeal deal = evt.data;
        log.info("deal part: ${deal.part}");
      }
      break;
    }
  }
  
  @OnOpen()
  void onOpen(WebSocketSession session) {
    log.info("connection established");
  }

  @OnMessage()
  onMessage(String message, WebSocketSession session) async {
    log.info("message received: $message");
    if (!session.attributes.containsKey('user')) {
      try {
        Common.Principal res = await login.authenticateToken(message);
        session.connection.add("success");
        session.attributes['user'] = res;
      } catch(error) {
        session.connection.add("access denied");
        session.connection.close();
      }
    }
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