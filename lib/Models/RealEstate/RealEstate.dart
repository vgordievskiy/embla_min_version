library BMSrv.Models.RealEstate;

import 'dart:async';
import 'dart:mirrors';
import 'dart:convert';

export 'package:BMSrv/Models/RealEstate/RealEstateGeneric.dart';
export 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';
export 'package:BMSrv/Models/RealEstate/REMetaData.dart';

import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:simple_features/simple_features.dart' as Geo;
import 'package:postgresql/postgresql.dart' as psql_connector;
import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';
export 'package:BMSrv/Models/RealEstate/RealEstateGeneric.dart';
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

class FindObjectsInBounds extends CustomFindObjects {
  Geo.Point SW;
  Geo.Point NE;

  FindObjectsInBounds(Type modelType, this.SW, this.NE,
                      {ReType type : null, bool inclDisable: false})
    : super(modelType)
  {
    final String box =
      "ST_MakeEnvelope(${SW.x}, ${SW.y}, ${NE.x}, ${NE.y}, 4326)";

    final String filter =
      type == null ? "" : " type = ${ReUtils.type2Int(type)} and";

    final String disabledFilter = inclDisable ? "" : "AND is_disable = FALSE";

    this.sqlQuery =
      """SELECT * FROM ${table.tableName}
         WHERE $filter obj_geom && $box $disabledFilter""";
  }
}

abstract class RealEstateBase {
  int id;

  ORM.Table get Table => ORM.AnnotationsParser.getTableForInstance(this);

  psql_connector.Connection get Connection {

    return (ORM.Model.ormAdapter as ORM.SQLAdapter).connection;
  }

  Future<int> SaveGeometryFromGeoJson(String geoJson) async {
    Map<String, dynamic> obj = JSON.decode(geoJson);
    obj['geometry']['crs'] = { 'type' : 'name',
                               'properties' : { 'name' : 'EPSG:4326' } };

    geoJson = JSON.encode(obj['geometry']);

    int res = await Connection
      .execute('''UPDATE ${Table.tableName}
                  SET obj_geom = ST_GeomFromGeoJSON('$geoJson')
                  WHERE id=${this.id}''');
    return res;
  }

  Future<String> GetGeometryAsGeoJson() async {
    List<psql_connector.Row> res = await Connection
      .query('''SELECT ST_AsGeoJSON(obj_geom)
                FROM ${Table.tableName}
                WHERE id=${this.id}''').toList();
    if(res[0][0] == null) {
      return "{}";
    } else return res[0][0];
  }

  Future<Map<String, dynamic>> GetGeometry() async {
    String res = await GetGeometryAsGeoJson();
    return JSON.decode(res);
  }

  ReType get Type;

  Future<List<REMetaData>> GetMetaData({String fieldName: null})
    => REMetaDataUtils.getForObject(this, fieldName: fieldName);

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

  Future<List<RERoom>> getRooms({int count: null, int page: null})
    => RERoomUtils.getForOwner(this, count: count, page: page);
}
