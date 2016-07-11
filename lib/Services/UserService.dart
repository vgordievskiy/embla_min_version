library tradem_srv.services.user_service;

import 'dart:async';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:harvest/harvest.dart';
import '../Events/LogicEventTypes.dart';

import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Utils/Crypto.dart' as crypto;
import 'package:srv_base/Middleware/input_parser/input_parser.dart';
import 'package:srv_base/Models/Users.dart';
import '../Utils/Deals.dart';
import '../Utils/Prices.dart';

export 'package:srv_base/Models/Users.dart';

class UserService extends Controller {
  final Repository<User> users;
  final Repository<Deal> deals;
  MessageBus _bus;

  UserService(this.users, this.deals)
  {
    _bus = Utils.$(MessageBus);
    _bus.subscribe(CreateUser.type(),(GenericEvent<CreateUser> event){
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!! ${event.data.user.email}");
    });
  }

  Future<User> getUserByName(String username)
    => users.where((user) => user.email == username).first();

  Future<User> getUserById(int id) => users.find(id);

  _returnOk(String key, var value) => {'msg':'ok', key : value};

  bool _filterData(Map data) {
    return true;
  }

  @Post('/') create(Input args) async {
    Map params = args.body;
    if(expect(params, 'email') &&
       expect(params, 'password')) {
        try {
           //check exist user
           User user = await getUserByName(params['email']);
           this.abortConflict('user exist');
        } catch (err){
          if (err is HttpException) rethrow;
        }

        User user = new User()
          ..email = params['email']
          ..password = crypto.encryptPassword(params['password'])
          ..enabled = true
          ..group = UserGroup.toStr(UserGroup.USER);
        await users.save(user);
        {
          _bus.publish(CreateUser.create(user));
        }
        return {'msg' : 'ok', 'userId' : user.id};
    } else {
      this.abortBadRequest('wrong data');
    }
  }

  @Get('/:id') getUser({String id}) => getUserById(int.parse(id));

  @Get('/:id/data') getUsetData({String id}) async {
    User user = await getUserById(int.parse(id));
    return user.data;
  }

  @Put('/:id/data') updateUser(Input args, {String id}) async {
    User user =  await getUserById(int.parse(id));
    Map params = args.body;
    if(_filterData(params)) {
      user.data = params;
      await users.save(user);
    }
    return this.ok('');
  }

  @Get('/:id/deals') getUserDeals({String id}) async {
    User user =  await getUserById(int.parse(id));
    return await DealsUtils.getDeals(user).toList();
  }

  @Post('/:id/deals') addUserDeals(Input args, {String id}) async {
    Map params = args.body;
    if(expect(params, 'object_id') &&
       expect(params, 'count')) {
      try {
        Deal deal = await DealsUtils
          .createFromId(int.parse(id),
                        int.parse(params['object_id']),
                        int.parse(params['count']));
        await deals.save(deal);
        return _returnOk('id', deal.id);
      } catch (err) {
        if(err is ArgumentError) {
          this.abortBadRequest('wrong data: ${err.message}');
        } else {
          this.abortBadRequest('wrong data');
        }
      }
    } else {
      this.abortBadRequest('wrong data');
    }
  }
}
