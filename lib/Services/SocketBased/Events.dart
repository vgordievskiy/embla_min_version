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
  Map<int, WebSocketSession> _sessions = new Map();
  Map<TSysEvt, Function> handlers = new Map();

  EventService() {
    login = new Common.LoginService();
    login.addToOpenResource('events');
    initEvtSystem();
  }

  onSysEvtHandler(SysEvt evt) {
    if(handlers.containsKey(evt.type)) {
      handlers[evt.type](evt.data);
    }
  }
  
  initEvtSystem() {
    Common.EventSys.asyncMessageBus.subscribe(SysEvt, onSysEvtHandler);
    {
      handlers[TSysEvt.ADD_DEAL] = (ObjectDeal deal){ 
        log.info("deal part: ${deal.part}");
        _sendAll('new-data-ready');
      };
    }
  }

  Future _sendAll(String message) async {
    for (WebSocketSession session in _sessions.values) {
      try {
        session.connection.add(message);
      } catch (err) {
        log.warning(err);
      }
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
        {
          _sessions[session.hashCode] = session;
        }
      } catch (error) {
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
    _sessions.remove(session.hashCode);
  }
}
