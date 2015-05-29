library BMSrv.Storage.BMSrv;

export 'SemplexStorage.dart';
import 'SemplexStorage.dart';

import 'package:logging/logging.dart';

import 'dart:async';

class BMOnto {
  static final String BaseOntoName = "investments";
  static Ontology BaseOnto = null;
  static bool isIntitilizing = false;

  static Future InitBaseOnto() async {
    if (isIntitilizing) return;
    isIntitilizing = true;
    if (BaseOnto == null) {
      SemplexStorage storage = await GetStorage();
      BaseOnto = await storage.GetOntology(BaseOntoName);
      await BaseOnto.LoadMetaInfo();
    }
    isIntitilizing = false;
  }

  Logger _log = new Logger("BMSrv.BMOnto");
  Map<String, OntoClass> _classes = new Map();
  
  BMOnto() {
    InitBaseOnto().then((e) => _initClasses());
  }
  
  _initClasses() {
    BaseOnto.GetClasses().then((List<String> classes) async {
      for(String name in classes) {
        _classes[name] = await BaseOnto.GetClass(name);
        _log.info("Add Ontology Class ${_classes[name].Name}");
      }
    });
  }

  OntoClass GetClass(String name) {
    assert(BaseOnto != null);
    return _classes[name];
  }
}

BMOnto _def_Onto = null;

Future IntitOntology() async {
  _def_Onto = new BMOnto();
}

BMOnto GetOntology() {
  return _def_Onto;
}

class OntoEntity {
  OntoClass OwnerClass = null;
  
  void InitOnto(String className) {
    OwnerClass = GetOntology().GetClass(className);
  }
  
}