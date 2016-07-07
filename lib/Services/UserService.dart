library tradem_srv.services.user_service;

import 'dart:async';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';

import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Utils/Crypto.dart' as crypto;
import 'package:srv_base/Middleware/input_parser/input_parser.dart';
import 'package:srv_base/Models/Users.dart';

export 'package:srv_base/Models/Users.dart';

class UserService extends Controller {
  final Repository<User> users;

  UserService(this.users);

  Future<User> getUserByName(String username)
    => users.where((user) => user.email == username).first();

  Future<User> getUserById(int id) => users.find(id);

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
    return {'empty' : 'empty'};
  }

}
