library BMSrv.Storage.BMSrv;

export 'SemplexStorage.dart';
import 'SemplexStorage.dart' as Storage;

import 'dart:async';

class BMOnto {
  static final String BaseOntoName = "LifeControl";
  static Storage.Ontology BaseOnto = null;
  static bool isIntitilizing = false;

  static InitBaseOnto() async {
    if (isIntitilizing) return;
    isIntitilizing = true;
    if (BaseOnto == null) {
      Storage.SemplexStorage storage = await Storage.GetStorage();
      BaseOnto = await storage.GetOntology(BaseOntoName);
      await BaseOnto.LoadMetaInfo();
    }
    isIntitilizing = false;
  }

  BMOnto() {}

  Future<Storage.OntoClass> GetClass(String name) async {
    if (BaseOnto == null) await InitBaseOnto();
    return await BaseOnto.GetClass(name);
  }
}

BMOnto _def_L_F_Onto = new BMOnto();

Future IntitOntology() async {
  await BMOnto.InitBaseOnto();
}

BMOnto GetLifeControlStorage() {
  return _def_L_F_Onto;
}