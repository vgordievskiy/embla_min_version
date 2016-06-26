library tradem_srv.geo.postgis_psql_driver;

import 'dart:async';
import 'package:trestle/src/drivers/drivers.dart';
import 'package:trestle/gateway.dart';

class PostgisPsqlDriver extends PostgresqlDriver {
  PostgisPsqlDriver(
    {String host: 'localhost', String username: 'root', int port: 5432,
     String password: 'password', String database: 'database', bool ssl: false}
  ) : super(host: host, username: username, password: password, port: port,
            database: database, ssl: ssl);

  @override
  Stream<Map<String, dynamic>> get(Query query, Iterable<String> fields) {
    return super.get(query, fields);
  }

  @override
  Future connect() => super.connect();
  @override
  Future disconnect() => super.disconnect();
}
