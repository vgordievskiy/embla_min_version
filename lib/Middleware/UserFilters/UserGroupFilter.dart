library tradem_srv.middleware.user_filters.user_group_filter;
import 'dart:async';
import 'package:tradem_srv/Middleware/Auth.dart';
import 'package:tradem_srv/Middleware/AuthPrincipal.dart';

class UserGroupFilter extends UriFilterBase {
  final String group;
  UserGroupFilter(this.group);

  @override
  TUrlFilterHandler get filter => _filter;

  Future<bool> _filter(UserPrincipal cred, Uri uri) async {
    return cred.group == this.group;
  }
}
