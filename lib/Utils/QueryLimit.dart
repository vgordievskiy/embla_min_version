library tradem_srv.utils.query_limit;
import 'package:trestle/trestle.dart';

class QueryLimit
{
  RepositoryQuery limit(RepositoryQuery query, int count, [int page = null]) {
    query = query.limit(count);
    if(page != null) {
      final int offset = count * page;
      query = query.offset(offset);
    }
    return query;
  }
}
