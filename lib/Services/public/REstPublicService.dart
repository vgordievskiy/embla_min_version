library BMSrv.public.RealEstatePublicService;
import 'dart:async';
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:logging/logging.dart';

import 'package:BMSrv/Events/Event.dart';
import 'package:BMSrv/Utils/DbAdapter.dart';

import 'package:BMSrv/Models/JsonWrappers/RECommercial.dart';
import 'package:BMSrv/Models/JsonWrappers/REPrivate.dart';
import 'package:BMSrv/Models/JsonWrappers/RELand.dart';

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
  
  @app.Route("/private/:id/state", methods: const[app.GET])
  @Encode()
  test(String id) {
    return _impl.getPrivateStateById(id);
  }
}