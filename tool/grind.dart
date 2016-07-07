
import 'package:grinder/grinder.dart';
import 'package:embla_trestle/gateway.dart';
import 'package:postgresql/postgresql.dart' as postgresql;
import 'package:srv_base/Tools/PartitionMagic/PostgresPartitions.dart';

import '../bin/server.dart';
import 'migrations.dart';
import '../test/test_data/init_data.dart';

main(args) => grind(args);

final gateway = new Gateway(driver);

String getPostgresUri() {
  final String username = config['username'];
  final String password = config['password'];
  final String database = config['database'];
  final String host = 'localhost';
  final int port = 5432;
  return'postgres://$username:$password@$host:$port/$database';
}

@DefaultTask()
migrate() async {
  await gateway.connect();
  await gateway.migrate(migrations);
  await gateway.disconnect();
}

@Task()
rollback() async {
  await gateway.connect();
  await gateway.rollback(migrations);
  await gateway.disconnect();
}

@Task()
initpart() async {
  if(driver is PostgresqlDriver) {
    String script = await loadPartitionMagic();
    postgresql.Connection con = await postgresql.connect(getPostgresUri());
    int res = await con.execute(script);
    print("Create PartitionMagic: $res");
    con.close();
  } else {
    print("driver is not PostgresqlDriver");
  }
}

@Task()
initpostgis() async {
  if(driver is PostgresqlDriver) {
    postgresql.Connection con = await postgresql.connect(getPostgresUri());
    List<String> tables = [];
    for(String table in tables) {
      try {
        await con.execute("SELECT AddGeometryColumn( '$table', 'obj_geom', -1, 'GEOMETRY', 2)");
      } catch(err) {
        print(err);
      }
      try {
        await con.execute("CREATE INDEX ${table}_geom_indx ON $table USING GIST ( obj_geom )");
      } catch(err) {
        print(err);
      }
    }
    con.close();
  } else {
    print("driver is not PostgresqlDriver");
  }
}

@Task()
initdata() async {
  await gateway.connect();
  {
    InitTestData data = new InitTestData(gateway);
    await data.initSomeUsers();
    await data.initSomeObjects();
  }
  await gateway.disconnect();
}
