library tradem_srv.services.user_service;

import 'dart:async';
import 'dart:convert';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:shelf_auth/shelf_auth.dart';

import '../Utils/Utils.dart';
import '../Utils/Crypto.dart' as crypto;
import '../Models/Users.dart';
import '../Middleware/Auth.dart';
import '../Middleware/input_parser/input_parser.dart';

class UserPrincipal extends Principal {
  int id;
  UserPrincipal(String name, this.id) : super(name);
}

class UserFilter extends UriFilterBase {
  final UserService userSrv;
  UserFilter(this.userSrv);

  @override
  TUrlFilterHandler get filter => _filter;

  Future<bool> _filter(UserPrincipal cred, Uri uri) async {
    try {
      int userId = int.parse(uri.pathSegments[0]);
      return userId == cred.id;
    } catch(e) {
      return false;
    }
  }
}

class UserService extends Controller {
  final Repository<User> users;

  UserService(this.users);

  Future<User> getUserByName(String username) async
    => users.where((user) => user.email == username).first();

  Future<User> getUserById(int id) => users.find(id);

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
          ..password = crypto.encryptPassword(params['password']);
        await users.save(user);
        return {'msg' : 'ok', 'userId' : user.id};
    } else {
      this.abortBadRequest('wrong data');
    }
  }

  @Get('/:id') getUser({String id}) async {
    return getUserById(int.parse(id));
  }

}
