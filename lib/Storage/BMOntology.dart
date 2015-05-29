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

  Future<OntoClass> GetClass(String name) async {
    if (BaseOnto == null) await InitBaseOnto();
    return await BaseOnto.GetClass(name);
  }
}

BMOnto _def_Onto = null;

Future IntitOntology() async {
  _def_Onto = new BMOnto();
}

BMOnto GetOntology() {
  return _def_Onto;
}

class BaseOnto {
  static OntoClass OwnerClass = null;
    
  static dynamic InitBaseClass() async {
    if (OwnerClass == null) {
      OwnerClass = await GetOntology().GetClass("User");
    }
    return OwnerClass;
  }
}