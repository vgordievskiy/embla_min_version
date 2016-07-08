import 'dart:async';
import 'package:embla/application.dart';
import 'package:trestle/gateway.dart';
import 'package:trestle/trestle.dart';

import '../../tool/migrations.dart' as data;

import 'package:srv_base/Models/Users.dart';
import 'package:tradem_srv/Models/Objects.dart';
import 'package:tradem_srv/Models/Prices.dart';

/*workaround for run all tests*/
void main() {}

class InitTestData extends Bootstrapper {

  final Gateway gateway;
  Repository<User> users;
  Repository<Entity> entities;
  Repository<Price> prices;

  InitTestData(this.gateway)
  {
    users = new Repository<User>(this.gateway);
    entities = new Repository<Entity>(this.gateway);
    prices = new Repository<Price>(this.gateway);
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

  Future _addPrice(Entity obj, double price) async {
    Price item = new Price()
      ..price = price
      ..entity_id = obj.id;
   return prices.save(item);
  }

  initSomeObjects() async {
    {
      Entity obj = new Entity();
      obj.type = EntityType.COMMERCIAL_PLACES.Str;
      obj.enabled = true;
      obj.pieces = 1000;
      obj.busy_part = 0;
      obj.data = {
        'value' : [{'name':'shop'}]
      };
      await entities.save(obj);
      await _addPrice(obj, 1000.0);
    }
    {
      Entity obj = new Entity();
      obj.type = EntityType.LANDS.Str;
      obj.enabled = true;
      obj.pieces = 1000;
      obj.busy_part = 0;
      obj.data = {
        'value' : [ {'name':'land'} ]
      };
      await entities.save(obj);
      await _addPrice(obj, 900.0);
    }
  }

}
