library LifeControlSrv.Utils.DbAdapter;

import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:dart_orm_adapter_postgresql/dart_orm_adapter_postgresql.dart';
import 'package:logging/logging.dart';

String _User = 'BMSrvApp';
String _Pass = 'BMSrvAppbno9mjc';
String _DBName = 'investments';

bool _OrmInit = false;
PostgresqlDBAdapter _dbAdapter = null;

Logger _log = new Logger("BMSrv.DBAdapter");

dynamic InitORM() async {
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
    _log.info("initialized");
    _OrmInit = true;
  }
}

class DBAdapter {
  DBAdapter() {InitORM();}
}
