library BMSrv.Models.UserPaper.PaperItem;

export 'package:OntoORM/src/OntoClass.dart';
export 'package:OntoORM/src/OntoIndivid.dart';

import 'package:BMSrv/Storage/SemplexStorage.dart' as Storage;
import 'package:BMSrv/Storage/BMOntology.dart';
import 'dart:async';
import 'package:redstone_mapper/mapper.dart';
import 'package:uuid/uuid.dart';

//--------------------------Impl-----------------------------------

class PaperItem extends Storage.OntoIndivid {
  static Storage.OntoClass BaseClass = null;
  static Uuid Generator = new Uuid();

  static dynamic InitBaseClass() async {
    if (BaseClass == null) {
      BaseClass = await GetLifeControlStorage().GetClass("PaperItem");
    }
    return BaseClass;
  }
  
  static Future<PaperItem> Get(String name) async
  {
    PaperItem ret = new PaperItem.byDefault(name);
    ret.Repr = await ret.GetRepresentation(IsFull: true);
    return ret;
  }

  static Future<PaperItem> Create(Map<String, dynamic> params) async {
    OntoIndivid newInd = null;
    PaperItem ret = null;
    try {
      ret = new PaperItem.FromParams(params);
      newInd = await BaseClass.CreateIndivid(ret.EntityName, isNativeName: true);
      Map<String, dynamic> data = ret.Repr["PropertyValues"];
      for(String key in data.keys) {
        for (var value in data[key]) {
          await newInd.AddData(key, value);
        }
      }
    } catch (error) {
      await newInd.Delete();
      throw error;
    }
    return ret;
  }

  PaperItem.byDefault(String name, {var repr : null})
    : super(BaseClass, name)
    , _Repr = repr;
  
  PaperItem.ByRepr(dynamic repr, {String id: null})
    : super(BaseClass, id == null ? repr["Name"] : id)
    , _Repr = repr;
  
  PaperItem.FromParams(Map<String, dynamic> params)
      : super(BaseClass, BaseClass.GenerateEntityName(Generator.v4()))
  {
    Repr = new Map<String, dynamic>();
    Repr["PropertyValues"] = new Map<String, dynamic>();
    params.forEach((String key, dynamic value){
      Repr["PropertyValues"][key] = [value];
    });
  }


  dynamic _Repr = null;

  get Repr => _Repr;

  set Repr(Map<String, dynamic> repr) => _Repr = repr;
  
  Map<String, List<dynamic>> get Data => _Repr["PropertyValues"];

  Map<String, List<dynamic>> get RelSet => _Repr["RelationValues"];
  
  String get Element  => Data['hasPaperItemElement'][0];
  int    get OrderNum => Data['hasPaperItemNumber'][0];
  String get Params { 
    if (Data.containsKey('hasPaperItemParams'))
      return Data['hasPaperItemParams'][0];
    else 
      return "";
  }
  String get Style{ 
    if (Data.containsKey('hasPaperItemStyle'))
      return Data['hasPaperItemStyle'][0];
    else 
      return "";
  }
}