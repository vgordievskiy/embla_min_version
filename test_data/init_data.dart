import 'package:embla/application.dart';
import 'package:trestle/gateway.dart';
import 'package:trestle/trestle.dart';

import '../tools/migrations.dart' as data;

import 'package:tradem_srv/Models/Users.dart';

class InitTestData extends Bootstrapper {

  final Gateway gateway;
  Repository<User> users;

  InitTestData(this.gateway)
  {
    users = new Repository<User>(this.gateway);
  }

  @Hook.init
  init() async {
    await gateway.connect();
    await gateway.migrate(data.migrations);
    await initSomeUsers();
    await gateway.disconnect();
  }

  initSomeUsers() async {
    {
      User user = new User()
        ..email = 'gardi'
        ..password = '1';
      await users.save(user);
    }
    {
      User user = new User()
        ..email = 'gardi2'
        ..password = '2';
      await users.save(user);
    }
  }

}
