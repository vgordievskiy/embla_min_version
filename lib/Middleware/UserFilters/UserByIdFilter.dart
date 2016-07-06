library tradem_srv.middleware.user_filters.user_by_id_filter;
import 'dart:async';
import 'package:tradem_srv/Middleware/Auth.dart';
import 'package:tradem_srv/Middleware/AuthPrincipal.dart';

class UserIdFilter extends UriFilterBase {

  @override
  TUrlFilterHandler get filter => _filter;

  Future<bool> _filter(UserPrincipal cred, Uri uri) async {
    try {
      int userId = int.parse(uri.pathSegments[0]);
      return userId == cred.id;
    } catch(e) {
      return false;
    }
  }
}
