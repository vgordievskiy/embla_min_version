library BMSrv.Models.OntoUser;

import 'package:BMSrv/Storage/SemplexStorage.dart' as Storage;
import 'package:BMSrv/Storage/BMOntology.dart';

import 'package:BMSrv/Models/UserPeper/UserPaper.dart';

import 'package:BMSrv/Events/Event.dart';

import 'dart:async';
import 'package:redstone_mapper/mapper.dart';

import 'package:logging/logging.dart';

class OntoUser extends Storage.OntoIndivid {
  static Storage.OntoClass UsersClass = null;

  static dynamic InitBaseClass() async {
    if (UsersClass == null) {
      UsersClass = await GetLifeControlStorage().GetClass("User");
    }
    return UsersClass;
  }

  static Future<OntoUser> Create(String id, dynamic params) async {
    OntoIndivid ind = await UsersClass.CreateIndivid(id);

    await ind.AddData("hasUserId", params["id"]);
    await ind.AddData("hasUserName", params["name"]);
    await ind.AddData("hasEmail", params["email"]);

    return new OntoUser(id, isPreload: false);
  }

  Logger _log;
  dynamic _Repr = null;

  OntoUser(String id, {bool isPreload: true})
    : super(UsersClass, UsersClass.GenerateEntityName(id))
  {
    _log = new Logger("OntoUser[${id}]");
  }


  dynamic Update() async {
    _log.info("Update begin");
    UpdateUser event  = new UpdateUser(this);
    EventSys.GetEventBus().fire(event);

    OntoUser thisUser = await event.Result;
    Repr = thisUser._Repr;
    _log.info("Update end");
  }
  
  set Repr(dynamic repr) => _Repr = repr;

  String get UserName => _Repr["Name"];

  Map<String, List<dynamic>> get Data => _Repr["PropertyValues"];
  Map<String, List<dynamic>> get RelSet => _Repr["RelationValues"];

  int get UserId => Data["hasUserId"][0];
  
  Future<bool> AddPaper(UserPaper paper) async {
    this.AddRelation("hasUserPaper", paper);
  }
  
  List<UserPaper> GetPapers() {
    List<UserPaper> ret = new List();
    if(RelSet.containsKey('hasUserPaper')) {
      for(var repr in RelSet['hasUserPaper']) {
        ret.add(new UserPaper.ByRepr(repr));
      }  
    }
    return ret;
  }

}