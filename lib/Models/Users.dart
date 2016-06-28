library tradem_srv.models.users;
import 'package:embla_trestle/embla_trestle.dart';

class User extends Model {
  @field int id;
  @field String email;
  @field String password;
  @field bool enabled;
  @field String group;
  @field Map data;

  Map toJson() {
    return {
      'id' : id,
      'email' : email,
      'data' : data
    };
  }
}
