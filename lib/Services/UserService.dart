library tradem_srv.services.user_service;

import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';

class UserService extends Controller {

  @Get('/') action() {
    return 'Response';
  }

  @Get('/:id') action2({String id}) {
    return 'Response $id';
  }

}
