library BMSrv;

import 'dart:async';

import 'package:BMSrv/Storage/BMOntology.dart' as Ontology;
import 'package:BMSrv/Storage/SemplexStorage.dart';

Future Init() async {
  await Ontology.IntitOntology();
}

