import 'package:embla/application.dart';
import 'package:trestle/gateway.dart';

import '../tools/migrations.dart' as data;

class InitTestData extends Bootstrapper {

  final Gateway gateway;

  InitTestData(this.gateway);

  @Hook.init
  init() async {
    await gateway.connect();
    await gateway.migrate(data.migrations);
    await gateway.disconnect();
  }

}
