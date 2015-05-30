library BMSrv.Storage.BMSrv;

export 'SemplexStorage.dart';
import 'SemplexStorage.dart';

import 'package:observe/observe.dart';
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

abstract class OntoEntity extends ORM.Model with Observable {
  OntoClass OwnerClass = null;
  @observable
  OntoIndivid ind = null;
  
  int id;
  
  _initChangesListener() {
    assert(ind!=null);
    ind.changes.listen((List<ChangeRecord> changes){
      changes.forEach((ChangeRecord record){
        notifyChange(record);
      });
      deliverChanges();
    });
  }
  
  void InitOnto(String className) {
    OwnerClass = GetOntology().GetClass(className);
  }
  
  Future createInd(String name) async {
    assert(OwnerClass!=null);
    ind = await OwnerClass.CreateIndivid(name);
  }
  
  Future<OntoIndivid> loadOntoInfo() async {
    assert(id != null);
    ind = await OwnerClass.GetIndivid("$id");
    _initChangesListener();
    return ind;
  }
  
  /*shortcast for OntoIndivid getter*/
  OntoIndivid get $ {assert(ind!=null); return ind;}
  
  @override
  Future<bool> save() async {
    if (this.id == null) {
      try {
        bool res = await super.save();
        if (res == true) {
          await this.createInd("${this.id}");
          await loadOntoInfo();
        }
        return res;
      } catch(error) { throw error; }
    } else {
      return super.save();
    }
  }
  
}