import 'dart:async';
import 'package:embla_trestle/gateway.dart';

final migrations = [
  CreateUsersTableMigration
].toSet();

class CreateUsersTableMigration extends Migration {

  String table_name = 'users';

  @override
  Future run(Gateway gateway) async {
    await gateway.create(table_name, (schema) {
      schema.id();
      schema.string('email').unique();
      schema.string('password');
    });
  }

  @override
  Future rollback(Gateway gateway) async {
    await gateway.drop(table_name);
  }
}
