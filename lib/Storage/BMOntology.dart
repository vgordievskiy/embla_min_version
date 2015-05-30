library BMSrv.Storage.BMSrv;

export 'SemplexStorage.dart';
import 'SemplexStorage.dart';

import 'package:dart_orm/dart_orm.dart' as ORM;
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
    InitBaseOnto().then((e) => initClasses());
  }
  
  initClasses() async {
    await BaseOnto.GetClasses().then((List<String> classes) async {
      if (!_classes.isEmpty) return;
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
  await BMOnto.InitBaseOnto();
  _def_Onto = new BMOnto();
  await _def_Onto.initClasses();
}

BMOnto GetOntology() {
  return _def_Onto;
}

abstract class OntoEntity extends ORM.Model {
  OntoClass OwnerClass = null;
  OntoIndivid ind = null;
  
  int id;
  
  void InitOnto(String className) {
    OwnerClass = GetOntology().GetClass(className);
  }
  
  Future createInd(String name) async {
    assert(OwnerClass!=null);
    ind = await OwnerClass.CreateIndivid(name);
  }
  
  @override
  Future<bool> save() async {
    try {
      bool res = await super.save();
      if (res == true) {
        await this.createInd("${this.id}");
      }
    } catch(error) { throw error; }
  }
  
}