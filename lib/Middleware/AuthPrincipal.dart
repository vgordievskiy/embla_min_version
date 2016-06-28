library tradem_srv.middleware.auth_principal;
import 'package:shelf_auth/shelf_auth.dart';

class UserPrincipal extends Principal {
  int id;
  String group;
  UserPrincipal(String name, this.id) : super(name);
}
