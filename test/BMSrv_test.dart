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
import "package:threading/threading.dart";
import 'package:sync_socket/sync_socket.dart';

import 'package:redstone/server.dart' as app;
import 'package:redstone/mocks.dart';

import 'package:BMSrv/BMSrv.dart';


List<String> filter = ["LoginService"]; 

void setupConsoleLog([Level level = Level.INFO]) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((LogRecord rec) {
    
    if (filter.contains(rec.loggerName)) return;
    
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
  app.setUp([#BMSrv.RealEstateService]);
  app.setUp([#BMSrv.ObjectDealService]);
}

String authorization = null;
String userUrl = null;
String sessionId = "1";

String userName = "t1";
String userpass = "1";

Future<dynamic> createUser() {
  {
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
  }
}

Future<dynamic> loginUser() {
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
}

Future<dynamic> getUserInfo() {
  var req = new MockRequest(userUrl,
                            method: app.GET,
                            headers: {'authorization' : authorization},
                            session: new MockHttpSession(sessionId));
  return app.dispatch(req).then((resp){
    expect(resp.statusCode, equals(200));
    _log.info("${resp.mockContent}");
  });
}

/*type should be are private, commercial and land*/
Future<dynamic> createRealEstateObject(String type) {
  Map<String, String> data = new Map();
  data['objectName'] = "flat#1";
  var req = new MockRequest("/realestate/$type",
                            method: app.POST,
                            bodyType: app.FORM,
                            body: data,
                            headers: {'authorization' : authorization},
                            session: new MockHttpSession(sessionId));
  return app.dispatch(req).then((resp) {
    expect(resp.statusCode, equals(200));
    _log.info("${resp.mockContent}");
  });
}

/*type should be are private, commercial and land*/
Future<dynamic> assignRealEstateObject(String type, String id) {
  assert(userUrl!=null);
  Map<String, String> data = new Map();
  data['part'] = "10.0";
  var req = new MockRequest("$userUrl/set_deal/$type/$id",
                             method: app.PUT,
                             bodyType: app.FORM,
                             body: data,
                             headers: {'authorization' : authorization},
                             session: new MockHttpSession(sessionId));
   return app.dispatch(req).then((resp){
     expect(resp.statusCode, equals(200));
     _log.info("${resp.mockContent}");
   });
}

Future defineTests() async {
  await Init();
  await InitORM();
  initServices();
  
  skip_test("create user", createUser);
  test("login user", loginUser);
  test("Get user", getUserInfo);
  
  skip_test("create realEstate private object", () {
    return createRealEstateObject("private");
  });
  
  skip_test("realestate_assign_private", () async {
    return assignRealEstateObject("private", "1");
  });
  
  test("get user deals", () async {
    assert(userUrl!=null);
    var req = new MockRequest("$userUrl/deals",
                              method: app.GET,
                              headers: {'authorization' : authorization},
                              session: new MockHttpSession(sessionId));
    return app.dispatch(req).then((resp){
      expect(resp.statusCode, equals(200));
      _log.info("${resp.mockContent}");
    });
  });
  
  test("get all objects", () async {
    assert(userUrl!=null);
    var req = new MockRequest("/realestate",
                              method: app.GET,
                              headers: {'authorization' : authorization},
                              session: new MockHttpSession(sessionId));
    return app.dispatch(req).then((resp){
      expect(resp.statusCode, equals(200));
      _log.info("${resp.mockContent}");
    });
  });
  
  skip_test("thread", () async {
    var thread = new Thread(() async {
      for(int i=0; i<10; ++i )
      print("Threaded $i");
    });
   
    await thread.start();
  });
  
}
