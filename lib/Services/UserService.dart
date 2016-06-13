library tradem_srv.services.user_service;

import 'dart:async';
import 'dart:convert';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:shelf_auth/shelf_auth.dart';

import '../Models/Users.dart';
import '../Middleware/Auth.dart';

class UserFilter extends UriFilterBase {
  final UserService userSrv;
  UserFilter(this.userSrv);

  @override
  TUrlFilterHandler get filter => _filter;

  Future<bool> _filter(Principal cred, Uri uri) async {
    try {
      User user = await userSrv.getUserByName(cred.name);
      int userId = int.parse(uri.pathSegments[0]);
      return userId == user.id;
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

  Future<User> getUserById(int id) async
    => users.find(id);

  @Get('/') action() {
    return 'Response';
  }

  @Get('/:id') getUser({String id}) async {
    return getUserById(int.parse(id));
  }

}
