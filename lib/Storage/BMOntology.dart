library BMSrv.Storage.BMSrv;

export 'SemplexStorage.dart';
import 'SemplexStorage.dart';

import 'dart:async';

class BMOnto {
  static final String BaseOntoName = "investments";
  static Ontology BaseOnto = null;
  static bool isIntitilizing = false;

  static InitBaseOnto() async {
    if (isIntitilizing) return;
    isIntitilizing = true;
    if (BaseOnto == null) {
      SemplexStorage storage = await GetStorage();
      BaseOnto = await storage.GetOntology(BaseOntoName);
      await BaseOnto.LoadMetaInfo();
    }
    isIntitilizing = false;
  }

  BMOnto() {}

  Future<OntoClass> GetClass(String name) async {
    if (BaseOnto == null) await InitBaseOnto();
    return await BaseOnto.GetClass(name);
  }
}

BMOnto _def_Onto = new BMOnto();

Future IntitOntology() async {
  await BMOnto.InitBaseOnto();
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