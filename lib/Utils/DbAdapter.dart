library LifeControlSrv.Utils.DbAdapter;

import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:dart_orm_adapter_postgresql/dart_orm_adapter_postgresql.dart';

String _User = 'BMSrvApp';
String _Pass = 'BMSrvAppbno9mjc';
String _DBName = 'investnets';

bool _OrmInit = false;
PostgresqlDBAdapter _dbAdapter = null;

dynamic _InitORM() async {
  if (_OrmInit == false) {
    ORM.AnnotationsParser.initialize();
    _dbAdapter = new PostgresqlDBAdapter('postgres://${_User}:${_Pass}@localhost:5432/${_DBName}');
    await _dbAdapter.connect();
    ORM.Model.ormAdapter = _dbAdapter;
    try {
      var migrationResult = await ORM.Migrator.migrate();
    } catch(e) {
      print(e.toString());
    }
    _OrmInit = true;
  }
}

class DBAdapter {
  DBAdapter() {_InitORM();}
}
