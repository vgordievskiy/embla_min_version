import 'dart:async';
import 'package:embla/application.dart';
import 'package:trestle/gateway.dart';
import 'package:trestle/trestle.dart';

import '../../tool/migrations.dart' as data;

import 'package:tradem_srv/Models/Users.dart';
import 'package:tradem_srv/Models/Objects.dart';

class InitTestData extends Bootstrapper {

  final Gateway gateway;
  Repository<User> users;
  Repository<Entity> entities;

  InitTestData(this.gateway)
  {
    users = new Repository<User>(this.gateway);
    entities = new Repository<Entity>(this.gateway);
  }

  @Hook.init
  Future init() async {
    await gateway.connect();
    await gateway.migrate(data.migrations);
    await initSomeUsers();
    await initSomeObjects();
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

  initSomeObjects() async {
    {
      Entity obj = new Entity();
      obj.type = EntityType.toInt(EntityType.COMMERCIAL_PLACES);
      obj.data = {
        'objects' : [{'name':'shop'}]
      };
      await entities.save(obj);
    }
    {
      Entity obj = new Entity();
      obj.type = EntityType.toInt(EntityType.LANDS);
      obj.data = {
        'objects' : [ {'name':'land'} ]
      };
      await entities.save(obj);
    }
  }

}
