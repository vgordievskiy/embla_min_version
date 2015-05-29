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

main() async {
  setupConsoleLog();
  return defineTests();
}

Future defineTests() async {
  await Init();
  //load handlers in 'services' library
  setUp(() async {
    app.addPlugin(getMapperPlugin());
    app.addModule(new Module()..bind(DBAdapter));
    app.addModule(new Module()..bind(EventSys));
    //app.setUp([#BMSrv.Interceptors]);
    //app.setUp([#BMSrv.LoginService]);
    app.setUp([#BMSrv.UserService]);
  });
  
  //remove all loaded handlers
  tearDown(() => app.tearDown());
  
  test("create user", () {
    Map<String, String> data = new Map();
    data['username'] = "t1";
    data['password'] = "1";
    data['name'] = "test";
    data['email'] = "test@mail.com";
    var req = new MockRequest("/users", method: app.POST, body: data, isMultipart: true, bodyType: app.FORM, contentType: "multipart/form-data");
    return app.dispatch(req).then((resp) {
      //verify the response
      expect(resp.statusCode, equals(200));
      //expect(resp.mockContent, equals("hello, luiz"));
    });
  });
  
  /*test("hello service", () {
    //create a mock request
    var req = new MockRequest("/users/1");
    //dispatch the request
    return app.dispatch(req).then((resp) {
      //verify the response
      expect(resp.statusCode, equals(200));
      //expect(resp.mockContent, equals("hello, luiz"));
    });
  });*/

  return;
}