library srv_base.middleware.user_filters.user_group_filter;
import 'dart:async';
import 'package:srv_base/Middleware/Auth.dart';
import 'package:srv_base/Middleware/AuthPrincipal.dart';

class UserGroupFilter extends UriFilterBase {
  final String group;
  UserGroupFilter(this.group);

  @override
  TUrlFilterHandler get filter => _filter;

  Future<bool> _filter(UserPrincipal cred, Uri uri) async {
    return cred.group == this.group;
  }
}
