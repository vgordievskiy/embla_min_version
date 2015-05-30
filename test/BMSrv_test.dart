// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library BMSrv_test;

import 'dart:async';

import 'package:BMSrv/BMSrv.dart';
import 'package:BMSrv/Events/EventBus.dart';
import 'package:BMSrv/Utils/DbAdapter.dart';
import 'package:di/di.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:unittest/unittest.dart';
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:sync_socket/sync_socket.dart';

import 'package:redstone/server.dart' as app;
import 'package:redstone/mocks.dart';

import 'package:BMSrv/Services/UserService.dart';


void setupConsoleLog([Level level = Level.INFO]) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((LogRecord rec) {
    if (rec.level >= Level.SEVERE) {
      var stack = rec.stackTrace != null ? "\n${Trace.format(rec.stackTrace)}" : "";
      print('[${rec.loggerName}] - ${rec.level.name}: ${rec.time}: ${rec.message} - ${rec.error}${stack}');
    } else {
      print('[${rec.loggerName}] - ${rec.level.name}: ${rec.time}: ${rec.message}');
    }
  });
}

Logger _log = new Logger("BMSrv.Test");

main() async {
  setupConsoleLog();
  await defineTests();
  return;
}

initServices() {
  _log.info("load handlers in 'services' library");
  app.addPlugin(getMapperPlugin());
  app.addModule(new Module()..bind(DBAdapter));
  app.addModule(new Module()..bind(EventSys));
  app.setUp([#BMSrv.Interceptors]);
  app.setUp([#BMSrv.LoginService]);
  app.setUp([#BMSrv.UserService]);
}

Future defineTests() async {
  await Init();
  await InitORM();
  initServices();
  
  String authorization = null;
  String userUrl = null;
  String sessionId = "1";
  
  String userName = "t3";
  String userpass = "1";

  test("create user", () {
    Map<String, String> data = new Map();
    data['username'] = userName;
    data['password'] = userpass;
    data['name'] = "test";
    data['email'] = "test@mail.com";
    var req = new MockRequest("/users",
                              method: app.POST,
                              bodyType: app.FORM,
                              body: data);
    return app.dispatch(req).then((resp) {
      expect(resp.statusCode, equals(200));
    });
  });
  
  test("login user", () {
    Map<String, String> data = new Map();
    data["username"] = userName;
    data["password"] = userpass;
    data["submit"] = "fromDartTest";
    
    var req = new MockRequest("/login",
                              method: app.POST,
                              bodyType: app.FORM,
                              body: data);
    return app.dispatch(req).then((resp) {
      expect(resp.statusCode, equals(200));
      authorization = resp.headers.value("authorization");
      userUrl = resp.mockContent;
      _log.info("${resp.mockContent} - auth: ${authorization}");
    });
  });

  test("Get user", (){
    var req = new MockRequest(userUrl,
                              method: app.GET,
                              headers: {'authorization' : authorization},
                              session: new MockHttpSession(sessionId));
    return app.dispatch(req).then((resp){
      expect(resp.statusCode, equals(200));
      _log.info("${resp.mockContent}");
    });
  });
  
}