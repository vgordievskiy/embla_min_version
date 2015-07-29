library BMSrv.Models.RealEstate;

import 'dart:async';
import 'dart:convert';

export 'package:BMSrv/Models/RealEstate/REPrivate.dart';
export 'package:BMSrv/Models/RealEstate/RECommercial.dart';
export 'package:BMSrv/Models/RealEstate/RELand.dart';

import 'package:observe/observe.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:postgresql/postgresql.dart' as psql_connector;
import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';
import 'package:logging/logging.dart';
import 'package:simple_features/simple_features.dart' as Geo;

abstract class RealEstateBase {
  static OntoClass OwnerClass = GetOntology().GetClass("RealEstate");
  
  int id;
  
  static ORM.Table get Table => ORM.AnnotationsParser.getTableForType(RealEstateBase);
  
  static psql_connector.Connection get Connection {
    
    return (ORM.Model.ormAdapter as ORM.SQLAdapter).connection;
  }
  
  /*Lat are Geo.Point.y, Lng are Geo.Point.x*/
  Future<List<int>> getObjectsInBounds(Geo.Point SW, Geo.Point NE) async {
    /*xmin, ymin, xmax, ymax*/
    final String box = "ST_MakeEnvelope(${SW.x}, ${SW.y}, ${NE.x}, ${NE.y}, 4326)";
    List<int> res = await Connection.query("SELECT id FROM ${Table.tableName} WHERE obj_geom && $box").toList();
    return res;
  }
  
  Future<int> SaveGeometryFromGeoJson(String geoJson) async {    
    Map<String, dynamic> obj = JSON.decode(geoJson);
    obj['geometry']['crs'] = { 'type' : 'name', 'properties' : { 'name' : 'EPSG:4326' } };
    
    geoJson = JSON.encode(obj['geometry']);
    
    int res = await Connection.execute("UPDATE ${Table.tableName} SET obj_geom = ST_GeomFromGeoJSON('$geoJson') WHERE id=${this.id}");
    return res;
  }
  
  Future<String> GetGeometryAsGeoJson() async {
    List<String> res = await Connection.query("SELECT ST_AsGeoJSON(obj_geom) FROM ${Table.tableName} WHERE id=${this.id}").toList();
    return res[0][0];
  }
  
  Future<Map<String, dynamic>> GetGeometry() async {
    String res = await GetGeometryAsGeoJson();
    return JSON.decode(res);
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
}
