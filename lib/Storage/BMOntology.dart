library BMSrv.Storage.BMSrv;

export 'SemplexStorage.dart';
import 'SemplexStorage.dart' as Storage;

import 'dart:async';

class LifeControlOnto {
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

  LifeControlOnto() {}

  Future<Storage.OntoClass> GetClass(String name) async {
    if (BaseOnto == null) await InitBaseOnto();
    return await BaseOnto.GetClass(name);
  }
}

LifeControlOnto _def_L_F_Onto = new LifeControlOnto();

Future LF_Init() async {
  await LifeControlOnto.InitBaseOnto();
}

LifeControlOnto GetLifeControlStorage() {
  return _def_L_F_Onto;
}