library BMSrv.Models.UserPaper.UserPaper;

export 'package:OntoORM/src/OntoClass.dart';
export 'package:OntoORM/src/OntoIndivid.dart';
export 'package:BMSrv/Models/UserPeper/PaperItem.dart';

import 'package:BMSrv/Models/UserPeper/PaperItem.dart';
import 'package:BMSrv/Storage/SemplexStorage.dart' as Storage;
import 'package:BMSrv/Storage/BMOntology.dart';

import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:uuid/uuid.dart';

//--------------------------Impl-----------------------------------

class UserPaper extends Storage.OntoIndivid {
  static Storage.OntoClass BaseClass = null;
  static Uuid Generator = new Uuid();

  static dynamic InitBaseClass() async {
    if (BaseClass == null) {
      BaseClass = await GetLifeControlStorage().GetClass("UserPaper");
    }
    return BaseClass;
  }
  
  static Future<UserPaper> Get(String name) async
  {
    UserPaper ret = new UserPaper.byDefault(name);
    ret.Repr = await ret.GetRepresentation(IsFull: true);
    return ret;
  }

  static Future<UserPaper> Create(Map<String, dynamic> params) async {
    UserPaper ret = new UserPaper.FromParams(params);
    OntoIndivid newInd = await BaseClass.CreateIndivid(ret.EntityName, isNativeName: true);
    Map<String, dynamic> data = ret.Repr["PropertyValues"];
    for(String key in data.keys) {
      for (var value in data[key]) {
        await newInd.AddData(key, value);
      }
    }
    return ret;
  }

  UserPaper.byDefault(String name, {var repr : null})
    : super(BaseClass, name)
    , _Repr = repr;
  
  UserPaper.ByRepr(dynamic repr, {String id: null})
    : super(BaseClass, id == null ? repr["Name"] : id)
    , _Repr = repr;
  
  UserPaper.FromParams(Map<String, dynamic> params)
      : super(BaseClass, BaseClass.GenerateEntityName(Generator.v4()))
  {
    Repr = new Map<String, dynamic>();
    Repr["PropertyValues"] = new Map<String, dynamic>();
    params.forEach((String key, dynamic value){
      Repr["PropertyValues"][key] = [value];
    });
  }
  
  @override
  Future Delete() async {
    for(String id in await super.GetRelation('hasPaperItem')) {
      PaperItem paperItem = new PaperItem.byDefault(id);
      await paperItem.Delete();
    }
    return super.Delete();
  }


  dynamic _Repr = null;

  get Repr => _Repr;

  set Repr(Map<String, dynamic> repr) => _Repr = repr;
  
  Map<String, List<dynamic>> get Data => _Repr["PropertyValues"];

  Map<String, List<dynamic>> get RelSet => _Repr["RelationValues"];
  
  String get Color       => Data['hasPaperColor'][0];
  String get Name        => Data['hasPaperName'][0];
  String get TargetItem  => Data['hasPaperTargetItem'][0];
  
  List<PaperItem> GetItems() {
    List<PaperItem> ret = new List();
    if(RelSet.containsKey('hasPaperItem')) {
      for(var repr in RelSet['hasPaperItem']) {
        ret.add(new PaperItem.ByRepr(repr));
      }  
    }
    return ret;
  }
  
  Future<bool> AddItem(PaperItem item) async {
    this.AddRelation("hasPaperItem", item);
  }
}