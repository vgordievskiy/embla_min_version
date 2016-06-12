library tradem_srv.models.users;
import 'package:embla_trestle/embla_trestle.dart';

class User extends Model {
  @field int id;
  @field String email;
  @field String password;
}
