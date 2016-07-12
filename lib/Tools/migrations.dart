import 'dart:async';
import 'package:embla_trestle/gateway.dart';

class CreateUsersTableMigration extends Migration {

  String table_name = 'users';

  @override
  Future run(Gateway gateway) async {
    await gateway.create(table_name, (schema) {
      schema.id();
      schema.timestamp('created_at');
      schema.timestamp('updated_at');
      schema.string('email').unique();
      schema.string('password').nullable(false);
      schema.boolean('enabled').nullable(false);
      schema.string('group').nullable(false);
      schema.json('data'); /*some personal configs*/
    });
  }

  @override
  Future rollback(Gateway gateway) async {
    await gateway.drop(table_name);
  }
}
