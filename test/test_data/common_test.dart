import 'package:SemplexClientCmn/Utils/HttpCommunicator/IOHttpCommunicator.dart';
import 'package:SemplexClientCmn/Utils/Interfaces/ICommunicator.dart';
import 'package:SemplexClientCmn/Utils/RestAdapter.dart';
import 'package:tradem_srv/Srv.dart' as Srv;
import 'package:trestle/gateway.dart';


class TestCommon {
  static String srvUrl = "http://localhost:9090";

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
}
