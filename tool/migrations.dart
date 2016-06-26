import 'dart:async';
import 'package:embla_trestle/gateway.dart';

final migrations = [
  CreateUsersTableMigration,
  CreateEntitiesTableMigration,
  CreateDealsTableMigration
].toSet();

class CreateUsersTableMigration extends Migration {

  String table_name = 'users';

  @override
  Future run(Gateway gateway) async {
    await gateway.create(table_name, (schema) {
      schema.id();
      schema.timestamp('created_at').nullable(false);
      schema.timestamp('updated_at').nullable(false);
      schema.string('email').unique();
      schema.string('password');
      schema.json('data'); /*some personal configs*/
    });
  }

  @override
  Future rollback(Gateway gateway) async {
    await gateway.drop(table_name);
  }
}

class CreateEntitiesTableMigration extends Migration {

  String table_name = 'entities';

  @override
  Future run(Gateway gateway) async {
    await gateway.create(table_name, (schema) {
      schema.id();
      schema.timestamp('created_at').nullable(false);
      schema.timestamp('updated_at').nullable(false);
      schema.int('type');
      schema.json('data');
    });
  }

  @override
  Future rollback(Gateway gateway) async {
    await gateway.drop(table_name);
  }
}

class CreateDealsTableMigration extends Migration {

  String table_name = 'deals';

  @override
  Future run(Gateway gateway) async {
    await gateway.create(table_name, (schema) {
      schema.id();
      schema.timestamp('created_at').nullable(false);
      schema.timestamp('updated_at').nullable(false);
      schema.int('user_id');
      schema.int('entity_id');
    });
  }

  @override
  Future rollback(Gateway gateway) async {
    await gateway.drop(table_name);
  }
}
