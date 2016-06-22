library tradem_srv.services.user_creator;

import 'dart:async';
import 'dart:convert';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';

import '../Models/Users.dart';
import './UserService.dart';

class UserCreator extends Middleware {
  final UserService users;

  UserCreator(this.users);

  @Post() create() {
    return {'msg' : 'ok'};
  }

  Future<Response> handle(Request request) async {
    return ok(create());
  }
}
