import 'dart:async';
import 'package:embla_trestle/gateway.dart';
import 'package:srv_base/Tools/migrations.dart';

final migrations = [
  CreateUsersTableMigration,
  CreateEntitiesTableMigration,
  CreateDealsTableMigration,
  CreatePriceTableMigration
].toSet();

class CreateEntitiesTableMigration extends Migration {

  String table_name = 'entities';

  @override
  Future run(Gateway gateway) async {
    await gateway.create(table_name, (schema) {
      schema.id();
      schema.timestamp('created_at');
      schema.timestamp('updated_at');
      schema.string('type').nullable(false);
      schema.int('pieces').nullable(false);
      schema.boolean('enabled').nullable(false);
      schema.json('data');
      schema.int('busy_part');
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
      schema.timestamp('created_at');
      schema.timestamp('updated_at');
      schema.int('user_id').nullable(false);
      schema.int('entity_id').nullable(false);
      schema.int('count').nullable(false);
      schema.real('item_price').nullable(false);
    });
  }

  @override
  Future rollback(Gateway gateway) async {
    await gateway.drop(table_name);
  }
}

class CreatePriceTableMigration extends Migration {

  String table_name = 'prices';

  @override
  Future run(Gateway gateway) async {
    await gateway.create(table_name, (schema) {
      schema.id();
      schema.timestamp('created_at');
      schema.timestamp('updated_at');
      schema.int('entity_id').nullable(false);
      schema.real('price').nullable(false);
    });
  }

  @override
  Future rollback(Gateway gateway) async {
    await gateway.drop(table_name);
  }
}
