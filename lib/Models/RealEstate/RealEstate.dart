library BMSrv.Models.RealEstate;

import 'dart:async';

export 'package:BMSrv/Models/RealEstate/REPrivate.dart';
export 'package:BMSrv/Models/RealEstate/RECommercial.dart';
export 'package:BMSrv/Models/RealEstate/RELand.dart';

import 'package:observe/observe.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:BMSrv/Storage/SemplexStorage.dart';
import 'package:BMSrv/Storage/BMOntology.dart';
import 'package:logging/logging.dart';

class RealEstate extends OntoEntity {
  Logger _log;
  RealEstate() {
    InitOnto("RealEstate");
    initLog();
    loadOntoInfo().then((ind){
      OntoIndivid.Get(ind);
    });
  }
  
  RealEstate.Dummy() {
    InitOnto("RealEstate");
  }
  
  initLog() async {
    _log = new Logger("BMSrv.RealEstate_$id");
  }
  
  String objectName;
}
