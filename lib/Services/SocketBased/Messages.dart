library BMSrv.SocketBased.Chat;

import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:redstone_web_socket/redstone_web_socket.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';
import 'package:SrvCommon/SrvCommon.dart' as Common;

import 'package:BMSrv/Models/Social/Message.dart';

@WebSocketHandler("messages")
class MessageService {
  final log = new Logger("BMSrv.Services.SocketBased.Messages");
  
  Common.LoginService login;
  
  Map<String, WebSocketSession> _sessions = new Map();
  
  MessageService() {
    login = new Common.LoginService();
    login.addToOpenResource('messages');
    MessageUtils.createPartition();
  }
  
  bool _isAuthentificated(WebSocketSession session) {
    return session.attributes.containsKey('user');
  }
  
  Future _sendAll(String message) async {
    for(WebSocketSession session in _sessions.values) {
      try {
        session.connection.add(message);
      } catch(err) {
        log.warning(err);
      }
    }
  }
  
  Future<bool> _authConncetion(WebSocketSession session, String token) async {
    if (!_isAuthentificated(session)) {
      try {
        Common.Principal res = await login.authenticateToken(token);
        {
          _sessions[res.name] = session;
        }
        session.connection.add("success");
        session.attributes['user'] = res;
      } catch(error) {
        session.connection.add("access denied");
        session.connection.close();
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
    if(!_isAuthentificated(session)) {
      bool res = await _authConncetion(session, message);
      return;
    }
    _sendAll("${session.attributes['user'].name} : $message");
  }

  @OnError()
  void onError(error, WebSocketSession session) {
    log.warning("error: $error");
  }

  @OnClose()
  void onClose(WebSocketSession session) {
    log.info("connection closed");
    {
      _sessions.remove(session.attributes['user']);
    }
  }
}