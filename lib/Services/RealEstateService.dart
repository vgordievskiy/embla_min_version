library BMSrv.RealEstateService;

import "dart:mirrors";
import 'dart:async';
import "dart:convert";

import 'package:BMSrv/Models/JsonWrappers/ObjectDeal.dart';
import 'package:BMSrv/Models/JsonWrappers/REMetaData.dart';
import 'package:BMSrv/Models/JsonWrappers/REstate.dart';
import 'package:BMSrv/Models/JsonWrappers/RERoom.dart';

import 'package:BMSrv/Models/RealEstate/RealEstateGeneric.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/Utils/LikeObject.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:SrvCommon/SrvCommon.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:simple_features/simple_features.dart' as Geo;
import 'package:uuid/uuid.dart';

Future<User> _getUser(String name) async {
  ORM.Find find = new ORM.Find(User)..where(new ORM.Equals('userName', name));
  List foundUsers = await find.execute();
  return foundUsers[0];
}

bool _isEmpty(String value) => value == null;

class HelperObjectConverter<JsonWrapper> {
  ClassMirror _Class = reflectClass(JsonWrapper);
  
  Future<List<JsonWrapper>> get(Type type) async {
    ORM.Find find = new ORM.Find(type);
    List<JsonWrapper> ret = new List();
    for (var obj in await find.execute()) {
      var wrapper = await _Class.invoke(#Create, [obj]).reflectee;
      ret.add(wrapper);
    }
    return ret;
  }
  
  Future<List<JsonWrapper>> getFrom(List<dynamic> objects) async {
    List<JsonWrapper> ret = new List();
    for (var obj in objects) {
      var wrapper = await _Class.invoke(#Create, [obj]).reflectee;
      ret.add(wrapper);
    }
    return ret;
  }
}

@app.Group("/realestate")
class RealEstateService {
  DBAdapter _Db;
  
  Uuid _Generator;
  final log = new Logger("BMSrv.Services.RealEstateService");
  RealEstateService(DBAdapter this._Db) {
    _Generator = new Uuid();
    
    REGenericUtils.createPartition();
    RERoomUtils.createPartition();
  }
  
  Future<dynamic> _getObject(ReType type, String idStr) {
    int id = int.parse(idStr);
    if (type != ReType.ROOM) {
      return REGeneric.Get(type, id);
    } else {
      return RERoom.Get(id);
    }
  }
  
  _create_object_by_type(String type, @app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['objectName']) /*&& _isEmpty(data['objectGeom'])*/) {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }
    final ReType reType = ReUtils.str2Type(type);
    var newObj = new REGeneric.Dummy(reType);
    
    newObj.objectName = data['objectName'];

    var exception = null;

    try {
      var saveResult = await newObj.save();
      if (data.containsKey('objectGeom')) {
        int res = await newObj.SaveGeometryFromGeoJson(data['objectGeom']);
      }
      return newObj.id;
    } catch (error) {
      return new app.ErrorResponse(400, {"error": error});
    }
  }
  
  @app.Route("/:type/:id/rooms", methods: const [app.POST])
  @OnlyForUserGroup(const ['admin'])
  create_room(String type, String id, @app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['objectName']) /*&& _isEmpty(data['objectGeom'])*/
        && _isEmpty(data['square'])) {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }
    var reObj = await _getObject(ReUtils.str2Type(type), id);
     
    RERoom newRoom = new RERoom.Dummy(ReUtils.str2Type(type), reObj);
  
    newRoom.objectName = data['objectName'];
    newRoom.square = JSON.decode(data['square']);
     
    var exception = null;
    
    try {
      var saveResult = await newRoom.save();
      if (data.containsKey('objectGeom')) {
        int res = await newRoom.SaveGeometryFromGeoJson(data['objectGeom']);
      }
      return newRoom.id;
    } catch (error) {
      return new app.ErrorResponse(400, {"error": error});
    }
  }
  
  @app.Route("/rooms", methods: const [app.GET])
  @Encode()
  Future<List<RERoomWrapper>> getAllRooms(@app.QueryParam("count") int count,
                                          @app.QueryParam("page") int page) async
  {
    return new HelperObjectConverter<RERoomWrapper>().getFrom(await RERoomUtils.getRooms(count: count, page: page));
  }
  
  @app.Route("/rooms/popular", methods: const [app.GET])
  @Encode()
  Future<List<RERoomWrapper>> getAllPopularRooms(@app.QueryParam("count") int count,
                                                 @app.QueryParam("page") int page) async
  {
    return getAllRooms(count, page);
  }
  
  @app.Route("/:type/:id/rooms", methods: const [app.GET])
  @Encode()
  Future<List<RERoomWrapper>> getAllRoomForObject(String type, String id,
                                                 @app.QueryParam("count") int count,
                                                 @app.QueryParam("page") int page) async
  {
    ReType reType = ReUtils.str2Type(type);
    RealEstateBase obj = await _getObject(reType, id);
    return new HelperObjectConverter<RERoomWrapper>().getFrom(await obj.getRooms(count: count, page: page));
  }
  
  @app.Route("/:type/:id/rooms/:roomid/state", methods: const [app.GET])
  @Encode()
  Future<List<ObjectDealWrapper>> getRoomState(String type, String id, String roomid) async
  {
    ReType reType = ReUtils.str2Type(type);
    RERoom room = await _getObject(ReType.ROOM, roomid);
    if(room.ownerObjectId != int.parse(id) ||
       ReUtils.str2Type(type) != room.OwnerType) throw new app.ErrorResponse(400, {"error": "wrong data"});
    
    List<ObjectDealWrapper> ret = new List();

    List<ObjectDeal> deals = await room.GetAllParts();
    if(deals != null) {
      for (ObjectDeal deal in deals) {
          ret.add(await ObjectDealWrapper.Create(deal));
      }
    }
    return ret;
  }
  
  @app.Route("/:type/:id/rooms/:roomid/data", methods: const [app.GET])
  @Encode()
  Future<Map<String, dynamic>> getDataForRoom(String type, String id, String roomid) async {
    ReType reType = ReUtils.str2Type(type);
    RERoom room = await _getObject(ReType.ROOM, roomid);
    if(room.ownerObjectId != int.parse(id) ||
      ReUtils.str2Type(type) != room.OwnerType) throw new app.ErrorResponse(400, {"error": "wrong data"});
    
    List<REMetaData> ret = await room.GetMetaData();
    return REMetaDataWrapper.Create(ret);
  }
  
  @app.Route("/:type/:id/rooms/:roomid/data/:param", methods: const [app.GET])
  @Encode()
  Future<REMetaDataWrapper> getDataForRoomByName(String type, String id,
                                           String roomid, String param) async {
    RERoom room = await _getObject(ReType.ROOM, roomid);
    if(room.ownerObjectId != int.parse(id) ||
      ReUtils.str2Type(type) != room.OwnerType) throw new app.ErrorResponse(400, {"error": "wrong data"});
    
    List<REMetaData> ret = await room.GetMetaData(fieldName: param);
    return REMetaDataWrapper.Create(ret);
  }
  
  @app.Route("/:type/:id/rooms/:roomid/data/:param", methods: const [app.POST])
  @OnlyForUserGroup(const ['admin'])
  @Encode()
  Future<REMetaDataWrapper> addDataForRoom(String type, String id,
                                           String roomid, String param,
                                           @app.Body(app.FORM) Map data) async {
    if (!REMetaDataUtils.checkMetaName(param)) {
      throw new app.ErrorResponse(400, {"error": "wrong field name"});
    }
    if (_isEmpty(data['value'])) {
      throw new app.ErrorResponse(400, {"error": "data empty"}); 
    }
    RERoom room = await _getObject(ReType.ROOM, roomid);
    if(room.ownerObjectId != int.parse(id) ||
      ReUtils.str2Type(type) != room.OwnerType) throw new app.ErrorResponse(400, {"error": "wrong data"});
    
    var value = JSON.decode(data['value']);
    
    if(value == null) throw new app.ErrorResponse(400, {"error": "data empty"});
    
    return room.addMetaData(param, param, value);
  }
  
  @app.Route("/:type/:id/rooms/:roomid/data/:param/:indx", methods: const [app.PUT])
  @OnlyForUserGroup(const ['admin'])
  @Encode()
  Future<REMetaDataWrapper> changeDataForRoom(String type, String id,
                                              String roomid, String param, String indx,
                                              @app.Body(app.FORM) Map data) async
  {
    if (!REMetaDataUtils.checkMetaName(param)) {
      throw new app.ErrorResponse(400, {"error": "wrong field name"});
    }
    if (_isEmpty(data['value'])) {
      throw new app.ErrorResponse(400, {"error": "data empty"}); 
    }
    RERoom room = await _getObject(ReType.ROOM, roomid);
    if(room.ownerObjectId != int.parse(id) ||
      ReUtils.str2Type(type) != room.OwnerType) throw new app.ErrorResponse(400, {"error": "wrong data"});
    
    List<REMetaData> oldValue = await room.GetMetaData(fieldName: param);
    
    int pos = int.parse(indx);
    
    var value = JSON.decode(data['value']);
    
    oldValue[pos].Data = value;
    return oldValue[pos].save();
  }

  @app.Route("/commercial", methods: const [app.POST])
  @OnlyForUserGroup(const ['admin'])
  create_commercial(@app.Body(app.FORM) Map data) => _create_object_by_type("commercial", data);

  @app.Route("/land", methods: const [app.POST])
  @OnlyForUserGroup(const ['admin'])
  create_land(@app.Body(app.FORM) Map data) => _create_object_by_type("land", data);

  @app.Route("/private", methods: const [app.POST])
  @OnlyForUserGroup(const ['admin'])
  create_private(@app.Body(app.FORM) Map data) => _create_object_by_type("private", data);
  
  @app.Route("/commercial", methods: const [app.GET])
  @Encode()
  Future<List<REstateWrapper>> getAllCommercial() async
    => new HelperObjectConverter<REstateWrapper>()
       .getFrom(await REGenericUtils.GetAllByType(ReType.COMMERCIAL));

  @app.Route("/land", methods: const [app.GET])
  @Encode()
  Future<List<REstateWrapper>> getAllLand() async
    => new HelperObjectConverter<REstateWrapper>()
           .getFrom(await REGenericUtils.GetAllByType(ReType.LAND));
  
  @app.Route("/private", methods: const [app.GET])
  @Encode()
  Future<List<REstateWrapper>> getAllPrivate() async 
    => new HelperObjectConverter<REstateWrapper>()
         .getFrom(await REGenericUtils.GetAllByType(ReType.PRIVATE));
  
  @app.DefaultRoute()
  @Encode()
  Future<List<dynamic>> getAllObjects() async {
    List<dynamic> ret = new List();
    ret.addAll(await getAllPrivate());
    ret.addAll(await getAllCommercial());
    ret.addAll(await getAllLand());
    return ret;
  }
  
  @app.Route("/commercial/bounds/:SWLng/:SWLat/:NELng/:NELat",
             methods: const [app.GET])
  @Encode()
  Future<List<REstateWrapper>> getAllCommercialInBounds(
      String SWLng, String SWLat, String NELng, String NELat) async {
    Geo.Point sw = new Geo.Point(double.parse(SWLng), double.parse(SWLat));
    Geo.Point ne = new Geo.Point(double.parse(NELng), double.parse(NELat));
    var find = await new FindObjectsInBounds(REGeneric, sw, ne, ReType.COMMERCIAL);

    return new HelperObjectConverter<REstateWrapper>().getFrom(await find.execute());
  }
  
  @app.Route("/land/bounds/:SWLng/:SWLat/:NELng/:NELat",
      methods: const [app.GET])
  @Encode()
  Future<List<REstateWrapper>> getAllLandsInBounds(
      String SWLng, String SWLat, String NELng, String NELat) async {
    Geo.Point sw = new Geo.Point(double.parse(SWLng), double.parse(SWLat));
    Geo.Point ne = new Geo.Point(double.parse(NELng), double.parse(NELat));
    var find = await new FindObjectsInBounds(REGeneric, sw, ne, ReType.LAND);

    return new HelperObjectConverter<REstateWrapper>().getFrom(await find.execute());
  }

  @app.Route("/private/bounds/:SWLng/:SWLat/:NELng/:NELat",
      methods: const [app.GET])
  @Encode()
  Future<List<REstateWrapper>> getAllPrivatesInBounds(
      String SWLng, String SWLat, String NELng, String NELat) async {
    Geo.Point sw = new Geo.Point(double.parse(SWLng), double.parse(SWLat));
    Geo.Point ne = new Geo.Point(double.parse(NELng), double.parse(NELat));
    var find = await new FindObjectsInBounds(REGeneric, sw, ne, ReType.PRIVATE);

    return new HelperObjectConverter<REstateWrapper>().getFrom(await find.execute());
  }
  
  @app.Route("/bounds/:SWLng/:SWLat/:NELng/:NELat", methods: const [app.GET])
  @Encode()
  Future<List<dynamic>> getAllInBounds(String SWLng, String SWLat, String NELng, String NELat) async {
    List<dynamic> ret = new List();
    ret.addAll(await getAllPrivatesInBounds(SWLng, SWLat, NELng, NELat));
    ret.addAll(await getAllCommercialInBounds(SWLng, SWLat, NELng, NELat));
    ret.addAll(await getAllLandsInBounds(SWLng, SWLat, NELng, NELat));
    return ret;
  }
  
  @app.Route("/commercial/:id", methods: const [app.GET])
  @Encode()
  Future<REstateWrapper> getCommercialById(String id) async {
    REGeneric ret = await REGeneric.Get(ReType.COMMERCIAL, int.parse(id));
    if (ret == null) {
      return new app.ErrorResponse(404, {"error": "not found object"});
    }
    return REstateWrapper.Create(ret);
  }

  @app.Route("/land/:id", methods: const [app.GET])
  @Encode()
  Future<REstateWrapper> getLandById(String id) async {
    REGeneric ret = await REGeneric.Get(ReType.LAND, int.parse(id));
    if (ret == null) {
      return new app.ErrorResponse(404, {"error": "not found object"});
    }
    return REstateWrapper.Create(ret);
  }

  @app.Route("/private/:id", methods: const [app.GET])
  @Encode()
  Future<REstateWrapper> getPrivateById(String id) async {
    REGeneric ret = await REGeneric.Get(ReType.PRIVATE, int.parse(id));
    if (ret == null) {
      return new app.ErrorResponse(404, {"error": "not found object"});
    }
    return REstateWrapper.Create(ret);
  }
}
