library tradem_srv.services.user_service;

import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';
import '../Models/Users.dart';

class UserService extends Controller {
  final Repository<User> users;

  UserService(this.users);

  @Get('/') action() {
    return 'Response';
  }

  @Get('/:id') action2({String id}) {
    return 'Response $id';
  }

}
