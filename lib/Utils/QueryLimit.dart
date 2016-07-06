library tradem_srv.utils.query_limit;
import 'package:trestle/trestle.dart';

class QueryLimit
{
  RepositoryQuery limit(RepositoryQuery query, int count, [int page = null]) {
    if(page != null) {
      final int offset = count * page;
      query = query.offset(offset);
    }
    query = query.limit(count);
    return query;
  }
}
