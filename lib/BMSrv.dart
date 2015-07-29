library BMSrv;

import 'dart:async';
/*----For corrent initialize RedstoneDart--------*/
import 'package:BMSrv/Services/UserService.dart';
import 'package:BMSrv/Services/RealEstateService.dart';
import 'package:BMSrv/Services/ObjectDealService.dart';
/*------Public api------------------------------*/
import 'package:BMSrv/Services/public/REstPublicService.dart';
/*------end Public------------------------------*/

import 'package:SrvCommon/SrvCommon.dart' as Common;

import 'package:postgresql/postgresql.dart' as PG;
import 'package:dart_orm/dart_orm.dart' as ORM;

var uri = 'postgres://BMSrvApp:BMSrvAppbno9mjc@localhost:5432/investments';

_postGisInit() async {
  PG.Connection conn = await PG.connect(uri);
  List<String> tables = ['real__estate__objects__commercial', 'real__estate__objects__private', 'real__estate__objects__land'];
  
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

Future Init() async {
  
  var params = new Common.Params(User: "BMSrvApp",
                                 Password: "BMSrvAppbno9mjc",
                                 DBName: "investments",
                                 OntologyName: "investments");
  await Common.Init(params);
  await _postGisInit();
}

