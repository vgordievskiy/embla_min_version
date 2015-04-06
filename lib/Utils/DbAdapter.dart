library LifeControlSrv.Utils.DbAdapter;

import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:dart_orm_adapter_mysql/dart_orm_adapter_mysql.dart';

String _User = 'LfApp';
String _Pass = 'LfApp1089';
String _DBName = 'LifeControl';

bool _OrmInit = false;
MySQLDBAdapter _dbAdapter = null;

dynamic _InitORM() async {
  if (_OrmInit == false) {
    ORM.AnnotationsParser.initialize();
    _dbAdapter = new MySQLDBAdapter('mysql://${_User}:${_Pass}@127.0.0.1:3306/${_DBName}');
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
