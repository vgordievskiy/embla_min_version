library tradem_srv.geo.postgis_psql_driver;

import 'package:trestle/src/drivers/drivers.dart';

class PostgisPsqlDriver extends PostgresqlDriver {
  PostgisPsqlDriver({String host: 'localhost',
                     String username: 'root',
                     String password: 'password',
                     int port: 5432,
                     String database: 'database',
                     bool ssl: false}
  ) : super(host: host, username: username, password: password, port: port,
            database: database, ssl: ssl);
}
