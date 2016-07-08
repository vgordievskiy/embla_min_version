library tool.Utils.PostgresPartitions;

import 'dart:io';
import 'dart:async';

final String _relativePath =
  "packages/srv_base/Tools/PartitionMagic/SqlScript/_2gis_partition_magic.sql";

Future<String> loadPartitionMagic() async {
  File file = new File(_relativePath);
  String sqlScript = await file.readAsString();
  return sqlScript;
}
