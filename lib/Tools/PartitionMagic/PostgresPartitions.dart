library tool.Utils.PostgresPartitions;

import 'dart:io';
import 'dart:async';
import 'package:postgresql/postgresql.dart' as postgresql;
import 'package:trestle/src/drivers/drivers.dart';

final String _relativePath =
  "lib/Tools/PartitionMagic/SqlScript/_2gis_partition_magic.sql";

Future<String> loadPartitionMagic() async {
  File file = new File(_relativePath);
  String sqlScript = await file.readAsString();
  return sqlScript;
}

class PsqlPartitions {
  static String createPartitionQuery(String table, String field)
    => "select _2gis_partition_magic('${table}', '${field}');";

  static initpart(var driver, String psqlUrl) async {
    if(driver is PostgresqlDriver) {
      String script = await loadPartitionMagic();
      postgresql.Connection con = await postgresql.connect(psqlUrl);
      int res = await con.execute(script);
      print("Create PartitionMagic: $res");
      con.close();
    } else {
      print("driver is not PostgresqlDriver");
    }
  }
}
