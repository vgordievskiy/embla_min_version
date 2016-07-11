library tradem_srv.events.logic_events.types;

import 'package:di/type_literal.dart';
import 'Generic/GenericEvent.dart';
export 'Generic/GenericEvent.dart';

import 'package:srv_base/Models/Users.dart';

class CreateUser {
  static Type type() => new TypeLiteral<GenericEvent<CreateUser>>().type;
  static create(User user)
    => new GenericEvent<CreateUser>(new CreateUser(user));

  User user;
  CreateUser(this.user);
}
