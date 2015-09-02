library BMSrv.RealEstateService;

import "dart:mirrors";
import 'dart:async';

import 'package:BMSrv/Models/JsonWrappers/ObjectDeal.dart';
import 'package:BMSrv/Models/JsonWrappers/RECommercial.dart';
import 'package:BMSrv/Models/JsonWrappers/RELand.dart';
import 'package:BMSrv/Models/JsonWrappers/REPrivate.dart';
import 'package:BMSrv/Models/JsonWrappers/RERoom.dart';
import 'package:BMSrv/Models/JsonWrappers/REstate.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/Utils/PopularObjects.dart';
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

bool _isEmpty(String value) => value == "";

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
  
  static final Map<ReType, Function> _reContructors = 
  {
    ReType.COMMERCIAL : () => new RECommercial.Dummy(),
    ReType.PRIVATE : () => new REPrivate.Dummy(),
    ReType.LAND : () => new RELand.Dummy()
  };
  
  static final Map<ReType, Type> _reIntTypes = 
  {
    ReType.COMMERCIAL : RECommercial,
    ReType.PRIVATE : REPrivate,
    ReType.LAND : RELand,
    ReType.ROOM: RERoom
  };
  
  static RealEstateBase _getDummy(ReType type) => _reContructors[type]();
  
  static Type _getIntReType(ReType type) => _reIntTypes[type]; 
  
  DBAdapter _Db;
  Uuid _Generator;
  final log = new Logger("BMSrv.Services.RealEstateService");
  RealEstateService(DBAdapter this._Db) {
    _Generator = new Uuid();
  }
  
  Future<List<ObjectDealWrapper>> _getDeals(Type type, String id) async {
    ORM.FindOne find = new ORM.FindOne(type)..whereEquals('id', id);
    var obj = await find.execute();
    if (obj == null) {
      return new app.ErrorResponse(404, {"error": "not found object"});
    }

    List<ObjectDealWrapper> ret = new List();

    for (ObjectDeal deal in await obj.GetAllParts()) {
      ret.add(await ObjectDealWrapper.Create(deal));
    }
    return ret;
  }
  
  Future<dynamic> _getObject(ReType type, String id) {
    switch (type) {
      case ReType.PRIVATE : return REPrivate.Get(id);
      case ReType.COMMERCIAL : return RECommercial.Get(id);
      case ReType.LAND : return RELand.Get(id);
      case ReType.ROOM : return RERoom.Get(id);
    }
  }
  
  _create_object_by_type(String type, @app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['objectName']) /*&& _isEmpty(data['objectGeom'])*/) {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }
    final ReType reType = ReUtils.str2Type(type);
    var newObj = _getDummy(reType);
    
    newObj.objectName = data['objectName'];

    var exception = null;

    var saveResult = await newObj.save().catchError((var error) {
      exception = error;
    });

    if (data.containsKey('objectGeom')) {
      int res = await newObj.SaveGeometryFromGeoJson(data['objectGeom']);
    }

    if (exception != null) {
      return exception;
    } else {
      return newObj.id;
    }
  }
  
  @app.Route("/:type/:id/rooms", methods: const [app.POST])
  create_room(String type, String id, @app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['objectName']) /*&& _isEmpty(data['objectGeom'])*/
        && _isEmpty(data['square'])) {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }
    var reObj = await _getObject(ReUtils.str2Type(type), id);
     
    RERoom newRoom = new RERoom.Dummy(ReUtils.str2Type(type), reObj);
  
    newRoom.objectName = data['objectName'];
    newRoom.square = data['square'];
     
    var exception = null;
  
    var saveResult = await newRoom.save().catchError((var error) {
      exception = error;
    });
  
    if (data.containsKey('objectGeom')) {
      int res = await newRoom.SaveGeometryFromGeoJson(data['objectGeom']);
    }
    if (exception != null) {
      return exception;
    } else {
      return newRoom.id;
    }
  }
  
  @app.Route("/:type/:id/rooms", methods: const [app.GET])
  @Encode()
  Future<List<RERoomWrapper>> getAllRoomForObject(String type, String id) async {
    ReType reType = ReUtils.str2Type(type);
    RealEstateBase obj = await _getObject(reType, id);
    return new HelperObjectConverter<RERoomWrapper>().getFrom(await obj.getRooms());
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

    for (ObjectDeal deal in await room.GetAllParts()) {
      ret.add(await ObjectDealWrapper.Create(deal));
    }
    return ret;
  }

  @app.Route("/commercial", methods: const [app.POST])
  create_commercial(@app.Body(app.FORM) Map data) => _create_object_by_type("commercial", data);

  @app.Route("/land", methods: const [app.POST])
  create_land(@app.Body(app.FORM) Map data) => _create_object_by_type("land", data);

  @app.Route("/private", methods: const [app.POST])
  create_private(@app.Body(app.FORM) Map data) => _create_object_by_type("private", data);
  
  @app.Route("/commercial", methods: const [app.GET])
  @Encode()
  Future<List<RECommercialWrapper>> getAllCommercial() => new HelperObjectConverter<RECommercialWrapper>().get(RECommercialWrapper.OriginType);

  @app.Route("/land", methods: const [app.GET])
  @Encode()
  Future<List<RELandWrapper>> getAllLand() => new HelperObjectConverter<RELandWrapper>().get(RELandWrapper.OriginType);
  
  @app.Route("/private", methods: const [app.GET])
  @Encode()
  Future<List<REPrivateWrapper>> getAllPrivate() => new HelperObjectConverter<REPrivateWrapper>().get(REPrivateWrapper.OriginType);
  
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
  Future<List<RECommercialWrapper>> getAllCommercialInBounds(
      String SWLng, String SWLat, String NELng, String NELat) async {
    Geo.Point sw = new Geo.Point(double.parse(SWLng), double.parse(SWLat));
    Geo.Point ne = new Geo.Point(double.parse(NELng), double.parse(NELat));
    var find = await new FindObjectsInBounds(RECommercial, sw, ne);

    return new HelperObjectConverter<RECommercialWrapper>().getFrom(await find.execute());
  }
  
  @app.Route("/land/bounds/:SWLng/:SWLat/:NELng/:NELat",
      methods: const [app.GET])
  @Encode()
  Future<List<RELandWrapper>> getAllLandsInBounds(
      String SWLng, String SWLat, String NELng, String NELat) async {
    Geo.Point sw = new Geo.Point(double.parse(SWLng), double.parse(SWLat));
    Geo.Point ne = new Geo.Point(double.parse(NELng), double.parse(NELat));
    var find = await new FindObjectsInBounds(RELand, sw, ne);

    return new HelperObjectConverter<RELandWrapper>().getFrom(await find.execute());
  }

  @app.Route("/private/bounds/:SWLng/:SWLat/:NELng/:NELat",
      methods: const [app.GET])
  @Encode()
  Future<List<REPrivateWrapper>> getAllPrivatesInBounds(
      String SWLng, String SWLat, String NELng, String NELat) async {
    Geo.Point sw = new Geo.Point(double.parse(SWLng), double.parse(SWLat));
    Geo.Point ne = new Geo.Point(double.parse(NELng), double.parse(NELat));
    var find = await new FindObjectsInBounds(REPrivate, sw, ne);

    return new HelperObjectConverter<REPrivateWrapper>().getFrom(await find.execute());
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
  Future<RECommercialWrapper> getCommercialById(String id) async {
    ORM.FindOne find = new ORM.FindOne(RECommercial)..whereEquals('id', id);
    var ret = await find.execute();
    if (ret == null) {
      return new app.ErrorResponse(404, {"error": "not found object"});
    }
    return RECommercialWrapper.Create(ret);
  }

  @app.Route("/land/:id", methods: const [app.GET])
  @Encode()
  Future<RELandWrapper> getLandById(String id) async {
    ORM.FindOne find = new ORM.FindOne(RELand)..whereEquals('id', id);
    var ret = await find.execute();
    if (ret == null) {
      return new app.ErrorResponse(404, {"error": "not found object"});
    }
    return RELandWrapper.Create(ret);
  }

  @app.Route("/private/:id", methods: const [app.GET])
  @Encode()
  Future<REPrivateWrapper> getPrivateById(String id) async {
    ORM.FindOne find = new ORM.FindOne(REPrivate)..whereEquals('id', id);
    var ret = await find.execute();
    if (ret == null) {
      return new app.ErrorResponse(404, {"error": "not found object"});
    }
    return REPrivateWrapper.Create(ret);
  }
}
