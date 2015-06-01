library BMSrv;

import 'dart:async';
/*----For corrent initialize RedstoneDart--------*/
import 'package:BMSrv/Services/Cors_Auth.dart';
import 'package:BMSrv/Services/LoginService.dart';
import 'package:BMSrv/Services/UserService.dart';
import 'package:BMSrv/Services/RealEstateService.dart';
/*----------------------------------------------*/

import 'package:BMSrv/Storage/BMOntology.dart' as Ontology;
import 'package:BMSrv/Storage/SemplexStorage.dart';

Future Init() async {
  await Ontology.IntitOntology();
}

