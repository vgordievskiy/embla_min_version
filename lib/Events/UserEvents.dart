library tradem_srv.events.logic_events.types;

import 'package:di/type_literal.dart';
import 'Generic/GenericEvent.dart';
export 'Generic/GenericEvent.dart';

import 'package:srv_base/Models/Users.dart';


class CreateUser extends GenericEvent<User> {
  static Type type() => new TypeLiteral<CreateUser>().type;
  static create(User user) => new CreateUser(user);

  User get user => this.data;
  CreateUser(User user): super(user);
}

class GetUserData extends GenericEvent<User> {
  static Type type() => new TypeLiteral<GetUserData>().type;
  static create(User user) => new GetUserData(user);

  User get user => this.data;
  GetUserData(User user): super(user);
}
