library BMSrv.public.RealEstatePublicService;
import 'dart:async';
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:logging/logging.dart';

import 'package:SrvCommon/SrvCommon.dart';

import 'package:BMSrv/Models/JsonWrappers/REMetaData.dart';
import 'package:BMSrv/Models/JsonWrappers/RECommercial.dart';
import 'package:BMSrv/Models/JsonWrappers/REPrivate.dart';
import 'package:BMSrv/Models/JsonWrappers/RELand.dart';
import 'package:BMSrv/Models/JsonWrappers/RERoom.dart';
import 'package:BMSrv/Models/JsonWrappers/REstate.dart';
import 'package:BMSrv/Models/JsonWrappers/ObjectDeal.dart';

import 'package:BMSrv/Services/RealEstateService.dart';

@app.Group("/public/realestate")
class RealEstatePublicService {
  RealEstateService _impl;
  final log = new Logger("BMSrv.Services.RealEstatePublicService");
  RealEstatePublicService(RealEstateService this._impl)
  {}
  
  @app.DefaultRoute()
  @Encode()
  Future<List<dynamic>> getAllObjects() async {
    return _impl.getAllObjects();
  }
  
  @app.Route("/private", methods: const[app.GET])
  @Encode()
  Future<List<REPrivateWrapper>> getAllPrivate() async {
    return _impl.getAllPrivate();
  }
  
  @app.Route("/commercial", methods: const[app.GET])
  @Encode()
  Future<List<RECommercialWrapper>> getAllCommercial() async {
    return _impl.getAllCommercial();
  }
  
  @app.Route("/land", methods: const[app.GET])
  @Encode()
  Future<List<RELandWrapper>> getAllLand() async {
    return _impl.getAllLand();
  }
  
  @app.Route("/private/:id", methods: const[app.GET])
  @Encode()
  Future<REPrivateWrapper> getPrivateById(String id) async {
    return _impl.getPrivateById(id);
  }
  
  @app.Route("/commercial/:id", methods: const[app.GET])
  @Encode()
  Future<RECommercialWrapper> getCommercialById(String id) async {
    return _impl.getCommercialById(id);
  }
  
  @app.Route("/land/:id", methods: const[app.GET])
  @Encode()
  Future<RELandWrapper> getLandById(String id) async {
    return _impl.getLandById(id);
  }
  
  @app.Route("/bounds/:SWLng/:SWLat/:NELng/:NELat", methods: const[app.GET])
 @Encode()
 Future<List<dynamic>> getAllInBounds(String SWLng, String SWLat,
                                      String NELng, String NELat)
 {
   return _impl.getAllInBounds(SWLng, SWLat, NELng, NELat);
 }
 
 @app.Route("/commercial/bounds/:SWLng/:SWLat/:NELng/:NELat", methods: const[app.GET])
 @Encode()
 Future<List<RECommercialWrapper>> getAllCommercialInBounds(String SWLng, String SWLat,
                                                              String NELng, String NELat)
 async {
   return _impl.getAllCommercialInBounds(SWLng, SWLat, NELng, NELat);  
 }
 
 @app.Route("/private/bounds/:SWLng/:SWLat/:NELng/:NELat", methods: const[app.GET])
 @Encode()
 Future<List<RECommercialWrapper>> getAllPrivatesInBounds(String SWLng, String SWLat,
                                                              String NELng, String NELat)
 async {
   return _impl.getAllPrivatesInBounds(SWLng, SWLat, NELng, NELat);  
 }
 
 @app.Route("/land/bounds/:SWLng/:SWLat/:NELng/:NELat", methods: const[app.GET])
 @Encode()
 Future<List<RECommercialWrapper>> getAllLandsInBounds(String SWLng, String SWLat,
                                                              String NELng, String NELat)
 async {
   return _impl.getAllLandsInBounds(SWLng, SWLat, NELng, NELat);  
 }
 
 @app.Route("/rooms", methods: const [app.GET])
 @Encode()
 Future<List<RERoomWrapper>> getAllRooms(@app.QueryParam("count") int count,
                                         @app.QueryParam("page") int page) async
 {
   return _impl.getAllRooms(count, page);
 }
 
 @app.Route("/rooms/popular", methods: const [app.GET])
 @Encode()
 Future<List<RERoomWrapper>> getAllPopularRooms(@app.QueryParam("count") int count,
                                                @app.QueryParam("page") int page) async
 {
   return _impl.getAllPopularRooms(count, page);
 }
 
 @app.Route("/:type/:id/rooms", methods: const [app.GET])
 @Encode()
 Future<List<RERoomWrapper>> getAllRoomForObject(String type, String id,
                                                 @app.QueryParam("count") int count,
                                                 @app.QueryParam("page") int page) async {
   return _impl.getAllRoomForObject(type, id, count, page);
 }
 
 @app.Route("/:type/:id/rooms/:roomid/state", methods: const [app.GET])
 @Encode()
 Future<List<ObjectDealWrapper>> getRoomState(String type, String id, String roomid) async {
   return _impl.getRoomState(type, id, roomid);
 }
 
 @app.Route("/:type/:id/rooms/:roomid/data", methods: const [app.GET])
 @Encode()
 Future<REMetaDataWrapper> getDataForRoom(String type, String id, String roomid) async {
   return _impl.getDataForRoom(type, id, roomid);
 }
}