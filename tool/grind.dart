
import 'package:grinder/grinder.dart';
import 'package:embla_trestle/gateway.dart';
import '../bin/server.dart';
import 'migrations.dart';
import './PartitionMagic/PostgresPartitions.dart';

import '../test/test_data/init_data.dart';

main(args) => grind(args);

final gateway = new Gateway(driver);

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
    (driver as PostgresqlDriver).execute(script, []);
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
