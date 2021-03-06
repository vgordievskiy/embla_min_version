import 'dart:async';
import 'package:embla/application.dart';
import 'package:trestle/gateway.dart';
import 'package:trestle/trestle.dart';

import 'package:srv_base/Tools/migrations.dart' as data;

import 'package:srv_base/Models/Users.dart';

/*workaround for run all tests*/
void main() {}

class InitTestData extends Bootstrapper {

  final Gateway gateway;
  Repository<User> users;

  InitTestData(this.gateway)
  {
    users = new Repository<User>(this.gateway);
  }

  @Hook.init
  Future init() async {
    await gateway.connect();
    await gateway.migrate([data.CreateUsersTableMigration].toSet());
    await initSomeUsers();
    await gateway.disconnect();
  }

  initSomeUsers() async {
    /*{
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
    }*/
  }
}
