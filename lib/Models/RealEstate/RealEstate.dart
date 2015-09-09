library BMSrv.Models.RealEstate;

import 'dart:async';
import 'dart:mirrors';
import 'dart:convert';

export 'package:BMSrv/Models/RealEstate/REMetaData.dart';
export 'package:BMSrv/Models/RealEstate/REPrivate.dart';
export 'package:BMSrv/Models/RealEstate/RECommercial.dart';
export 'package:BMSrv/Models/RealEstate/RELand.dart';
export 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';

import 'package:observe/observe.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:simple_features/simple_features.dart' as Geo;
import 'package:postgresql/postgresql.dart' as psql_connector;
import 'package:logging/logging.dart';
import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Models/RealEstate/REMetaData.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';
import 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';
import 'package:BMSrv/Models/RealEstate/REMetaData.dart';


enum ReType {
  PRIVATE,
  COMMERCIAL,
  LAND,
  ROOM
}

class ReUtils {
  static int type2Int(ReType type) {
    switch(type) {
      case ReType.PRIVATE : return 0;
      case ReType.COMMERCIAL : return 1;
      case ReType.LAND : return 2;
      case ReType.ROOM : return 3;
    }
  }
  
  static ReType int2Type(int type) {
    switch(type) {
      case 0 : return ReType.PRIVATE;
      case 1 : return ReType.COMMERCIAL;
      case 2 : return ReType.LAND;
      case 3 : return ReType.ROOM;
    }
    throw "unknown type value";
  }
  
  static String type2Str(ReType type) {
    switch(type) {
      case ReType.PRIVATE :
        return "private";
      case ReType.COMMERCIAL :
        return "commercial";
      case ReType.LAND :
        return "land";
      case ReType.ROOM :
        return "room";
    }
  }
  
  static ReType str2Type(String type) {
    switch(type) {
      case "private"    : return ReType.PRIVATE;
      case "commercial" : return ReType.COMMERCIAL;
      case "land"       : return ReType.LAND;
      case "room"       : return ReType.ROOM;
    }
    throw "unknown type value";
  }
}

class FindObjectsInBounds extends ORM.FindBase {
  Type ModelType;
  Geo.Point SW;
  Geo.Point NE;
  FindObjectsInBounds(Type modelType, this.SW, this.NE): super(modelType)
  {
    ModelType = modelType;
  }
  
  psql_connector.Connection get Connection {
   return (ORM.Model.ormAdapter as ORM.SQLAdapter).connection;
  }
  
  List<Map> _convert(List rawRows) {
    List<Map> results = new List<Map>();
    // sql adapters usually returns a list of fields without field names
    for (var rawRow in rawRows) {
      Map<String, dynamic> row = new Map<String, dynamic>();

      int fieldNumber = 0;
      for (ORM.Field f in table.fields) {
        row[f.fieldName] = rawRow[fieldNumber];
        fieldNumber ++;
      }

      results.add(row);
    }

    return results;  
  }
  
  List<ORM.Model> _convertToType(List rawRows) {
    List<ORM.Model> result = new List();
    ClassMirror modelMirror = reflectClass(ModelType);
    for (Map<String, dynamic> row in _convert(rawRows)) {
      InstanceMirror newInstance = modelMirror.newInstance(
          new Symbol(''), [], new Map());

      for (ORM.Field field in table.fields) {
        var fieldValue = row[field.fieldName];
        newInstance.setField(field.constructedFromPropertyName, fieldValue);
      }

      result.add(newInstance.reflectee);
    }
    return result;
  }
 
  Future<List<ORM.Model>> execute() {
    return _getObjectsInBounds(SW, NE);
  }
  
  /*Lat are Geo.Point.y, Lng are Geo.Point.x*/
  Future<List<ORM.Model>> _getObjectsInBounds(Geo.Point SW, Geo.Point NE) async {
    /*xmin, ymin, xmax, ymax*/
    final String box = "ST_MakeEnvelope(${SW.x}, ${SW.y}, ${NE.x}, ${NE.y}, 4326)";
    List rows = await Connection.query("SELECT * FROM ${table.tableName} WHERE obj_geom && $box").toList();
   
    return _convertToType(rows);
  }
}

abstract class RealEstateBase {
  static OntoClass OwnerClass = GetOntology().GetClass("RealEstate");
  
  int id;
  
  ORM.Table get Table => ORM.AnnotationsParser.getTableForInstance(this);
  
  psql_connector.Connection get Connection {
    
    return (ORM.Model.ormAdapter as ORM.SQLAdapter).connection;
  }
  
  Future<int> SaveGeometryFromGeoJson(String geoJson) async {    
    Map<String, dynamic> obj = JSON.decode(geoJson);
    obj['geometry']['crs'] = { 'type' : 'name', 'properties' : { 'name' : 'EPSG:4326' } };
    
    geoJson = JSON.encode(obj['geometry']);
    
    int res = await Connection.execute("UPDATE ${Table.tableName} SET obj_geom = ST_GeomFromGeoJSON('$geoJson') WHERE id=${this.id}");
    return res;
  }
  
  Future<String> GetGeometryAsGeoJson() async {
    List<psql_connector.Row> res = await Connection.query("SELECT ST_AsGeoJSON(obj_geom) FROM ${Table.tableName} WHERE id=${this.id}").toList();
    if(res[0][0] == null) {
      return "{}";
    } else return res[0][0];
  }
  
  Future<Map<String, dynamic>> GetGeometry() async {
    String res = await GetGeometryAsGeoJson();
    return JSON.decode(res);
  }
  
  ReType get Type;
  
  Future<List<REMetaData>> GetMetaData({String fieldName: null}) => REMetaDataUtils.getForObject(this, fieldName: fieldName);
  Future<bool> addMetaData(String name, String metaName,
                           dynamic value)
  {
    return REMetaDataUtils.addForObject(this, name, metaName, value);
  }
  
  Future<List<ObjectDeal>> _getParts(bool isPending) async {
    ORM.Find find = new ORM.Find(ObjectDeal)
                            ..where(new ORM.Equals('objectId', this.id)
                            .and(new ORM.Equals('isPending', isPending)));
    return find.execute();
  }
  
  Future<List<ObjectDeal>> GetPengindParts() async {
    return _getParts(true);
  }
  
  Future<List<ObjectDeal>> GetApprovedParts() async {
    return _getParts(false);
  }
  
  Future<List<ObjectDeal>> GetAllParts() async {
    ORM.Find find = new ORM.Find(ObjectDeal)
                        ..where(new ORM.Equals('objectId', this.id));
    return find.execute();
  }
  
  Future<List<RERoom>> getRooms({int count: null, int page: null}) => RERoomUtils.getForOwner(this, count: count, page: page);
}
