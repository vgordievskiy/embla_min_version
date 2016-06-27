import 'package:SemplexClientCmn/Utils/HttpCommunicator/IOHttpCommunicator.dart';
import 'package:SemplexClientCmn/Utils/Interfaces/ICommunicator.dart';
import 'package:SemplexClientCmn/Utils/RestAdapter.dart';
import 'package:tradem_srv/Srv.dart' as Srv;
import 'package:trestle/gateway.dart';
import 'dart:async';

import 'init_data.dart';

class TestCommon {
  static String srvUrl = "http://localhost:9090";
  static String userUrl;

  static final Map config = {
    'username': 'postgres',
    'password': 'bno9mjc',
    'database': 'tradem'
  };

  static final Map<String, String> userData = {
    'username' : 'gardi',
    'password' : 'testPass'
  };

  static final Map<String, String> userDataCreate = {
    'email' : userData['username'],
    'password' : userData['password']
  };

  static var driver = new InMemoryDriver();

  static IoHttpCommunicator cmn = new IoHttpCommunicator();
  static RestAdapter net = new RestAdapter(cmn);

  static initPsqldriver() {
    driver = new Srv.PostgisPsqlDriver(username: config['username'],
                                       password: config['password'],
                                       database: config['database']);
  }

  static Future<String> login() async {
    HttpRequestAdapter req =
      new HttpRequestAdapter.Post("$srvUrl/login", TestCommon.userData, null);
    try {
      IResponse resp = await cmn.SendRequest(req);
      if (resp.Status == 200) {
        final String authorization = resp.Headers["authorization"];
        cmn.AddDefaultHeaders("authorization", authorization);
        TestCommon.userUrl = resp.Data;
        return TestCommon.userUrl;
      }
    } catch(e) {
      throw e;
    }
    return null;
  }

  static Future initTestData() async {

  }
}
