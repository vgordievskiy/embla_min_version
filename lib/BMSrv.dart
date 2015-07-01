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

Future Init() async {
  
  var params = new Common.Params(User: "BMSrvApp",
                                 Password: "BMSrvAppbno9mjc",
                                 DBName: "investments",
                                 OntologyName: "investments");
  await Common.Init(params);
}

