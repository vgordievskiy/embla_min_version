library BMSrv.Storage.SemplexStorage;

export 'package:OntoORM/OntoORM.dart';
import 'package:OntoORM/OntoORM.dart' as OntoORM;

import 'dart:async';

class SemplexStorage extends OntoORM.OntoStorage {
  static final String _BaseUrl = "http://127.0.0.1:8080/semplex";

  Map<String, OntoORM.Ontology> _Ontologies = new Map();

  SemplexStorage() : super(_BaseUrl)
  {}

  Future<bool> Init() async {
    Completer<bool>
              comleter = new Completer<bool>();
    List<String> ontologies = await GetOntologiesNames()
      .then((List<String> names) async {
      for(String name in names) {
        _Ontologies[name] = new OntoORM.Ontology(this, name);
      }
      comleter.complete(true);
    }).catchError((var err) => comleter.completeError(err));
    return comleter.future;
  }

  @override
  Future<OntoORM.Ontology> GetOntology(String name) async
  {
    do {
      if (_Ontologies.isNotEmpty) {
        if(_Ontologies.containsKey(name)) {
          return _Ontologies[name];
        } else {assert(false);}
      }
      var res = await Init();
    } while(true);
  }

}

SemplexStorage _defStorage = null;

Future<SemplexStorage> GetStorage() async {
  if (_defStorage == null) {
    _defStorage = new SemplexStorage();
    await _defStorage.Init();
  }
  return _defStorage;
}