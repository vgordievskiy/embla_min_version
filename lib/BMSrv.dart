library BMSrv;

import 'dart:async';
/*----For corrent initialize RedstoneDart--------*/
import 'package:BMSrv/Services/UserService.dart';
import 'package:BMSrv/Services/AdminService.dart';
import 'package:BMSrv/Services/RealEstateService.dart';
import 'package:BMSrv/Services/ObjectDealService.dart';
import 'package:BMSrv/Services/SocketBased/Events.dart';
import 'package:BMSrv/Services/SocketBased/Messages.dart';
import 'package:BMSrv/Services/BasedOnGoogle/ImageService.dart';
import 'package:BMSrv/Services/MailService.dart';
/*------Public api------------------------------*/
import 'package:BMSrv/Services/public/REstPublicService.dart';
/*------end Public------------------------------*/

export 'package:SrvCommon/SrvCommon.dart' show Params;
import 'package:SrvCommon/SrvCommon.dart' as Common;

import 'package:postgresql/postgresql.dart' as PG;
import 'package:dart_orm/dart_orm.dart' as ORM;

_postGisInit() async {
  PG.Connection conn = await PG.connect(Common.DBAdapter.GetDbPath());
  List<String> tables = ['real_estate_objects_generic', 'real_estate_objects_rooms'];

  for(String table in tables) {
    try {
      await conn.execute("SELECT AddGeometryColumn( '$table', 'obj_geom', -1, 'GEOMETRY', 2)");
    } catch(err) {
      print(err);
    }
    try {
      await conn.execute("CREATE INDEX ${table}_geom_indx ON $table USING GIST ( obj_geom )");
    } catch(err) {
      print(err);
    }
  }
}

Future Init(Common.Params params) async {
  await Common.Init(params);
  await _postGisInit();
}
