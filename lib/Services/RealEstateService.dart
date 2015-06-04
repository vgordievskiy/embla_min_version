library BMSrv.RealEstateService;
import 'dart:async';

import 'package:BMSrv/Events/Event.dart';
import 'package:BMSrv/Models/JsonWrappers/ObjectDeal.dart';
import 'package:BMSrv/Models/JsonWrappers/RECommercial.dart';
import 'package:BMSrv/Models/JsonWrappers/RELand.dart';
import 'package:BMSrv/Models/JsonWrappers/REPrivate.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Utils/DbAdapter.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:logging/logging.dart';
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:uuid/uuid.dart';

Future<User> _getUser(String name) async {
  ORM.Find find = new ORM.Find(User)..where(new ORM.Equals('userName', name));
  List foundUsers = await find.execute();
  return foundUsers[0];
}

bool _isEmpty(String value) => value == "";

@app.Group("/realestate")
class RealEstateService {
  DBAdapter _Db;
  Uuid _Generator;
  final log = new Logger("BMSrv.Services.RealEstateService");
  RealEstateService(DBAdapter this._Db)
  {
    _Generator = new Uuid();
  }
  
  @app.Route("/commercial", methods: const[app.POST])
  create_commercial(@app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['objectName']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }

    RECommercial object = new RECommercial.Dummy();
    
    object.objectName = data['objectName'];

    var exception = null;

    var saveResult = await object.save().catchError((var error){
      exception = error;
    });
    
    if (exception != null) {
      return exception;
    } else {
      return object.id;
    }
  }
  
  @app.Route("/land", methods: const[app.POST])
  create_land(@app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['objectName']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }

    RELand object = new RELand.Dummy();
    
    object.objectName = data['objectName'];

    var exception = null;

    var saveResult = await object.save().catchError((var error){
      exception = error;
    });
    
    if (exception != null) {
      return exception;
    } else {
      return object.id;
    }
  }
  
  @app.Route("/private", methods: const[app.POST])
  create_private(@app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['objectName']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }

    REPrivate object = new REPrivate.Dummy();
    
    object.objectName = data['objectName'];

    var exception = null;

    var saveResult = await object.save().catchError((var error){
      exception = error;
    });
    
    if (exception != null) {
      return exception;
    } else {
      return object.id;
    }
  }
  
  @app.Route("/commercial", methods: const[app.GET])
  @Encode()
  Future<List<RECommercialWrapper>> getAllCommercial() async {
    ORM.Find find = new ORM.Find(RECommercial);
    List<RECommercialWrapper> ret = new List();
    for(RECommercial obj in await find.execute()) {
      ret.add(await RECommercialWrapper.Create(obj));
    }
    return ret;
  }
  
  @app.Route("/land", methods: const[app.GET])
  @Encode()
  Future<List<RELandWrapper>> getAllLand() async {
    ORM.Find find = new ORM.Find(RELand);
    List<RELandWrapper> ret = new List();
    for(RELand obj in await find.execute()) {
      ret.add(await RELandWrapper.Create(obj));
    }
    return ret;
  }
  
  @app.DefaultRoute()
  @Encode()
  Future<List<dynamic>> getAllObjects() async {
    List<dynamic> ret = new List();
    ret.addAll(await getAllPrivate());
    ret.addAll(await getAllCommercial());
    ret.addAll(await getAllLand());
    return ret;
  }
  
  @app.Route("/private", methods: const[app.GET])
  @Encode()
  Future<List<REPrivateWrapper>> getAllPrivate() async {
    ORM.Find find = new ORM.Find(REPrivate);
    List<REPrivateWrapper> ret = new List();
    for(REPrivate obj in await find.execute()) {
      ret.add(await REPrivateWrapper.Create(obj));
    }
    return ret;
  }
  
  @app.Route("/commercial/:id", methods: const[app.GET])
  @Encode()
  Future<RECommercialWrapper> getCommercialById(String id) async {
    ORM.FindOne find = new ORM.FindOne(RECommercial)..whereEquals('id', id);
    var ret = await find.execute();
    if (ret == null) {
      return  new app.ErrorResponse(404, {"error": "not found object"});
    }
    return RECommercialWrapper.Create(ret);
  }
  
  @app.Route("/land/:id", methods: const[app.GET])
  @Encode()
  Future<RELandWrapper> getLandById(String id) async {
    ORM.FindOne find = new ORM.FindOne(RELand)..whereEquals('id', id);
    var ret = await find.execute();
    if (ret == null) {
      return  new app.ErrorResponse(404, {"error": "not found object"});
    }
    return RELandWrapper.Create(ret);
  }
  
  @app.Route("/private/:id", methods: const[app.GET])
  @Encode()
  Future<REPrivateWrapper> getPrivateById(String id) async {
    ORM.FindOne find = new ORM.FindOne(REPrivate)..whereEquals('id', id);
    var ret = await find.execute();
    if (ret == null) {
      return  new app.ErrorResponse(404, {"error": "not found object"});
    }
    return REPrivateWrapper.Create(ret);
  }
  
  @app.Route("/private/:id/state", methods: const[app.GET])
  @Encode()
  Future<List<ObjectDealWrapper>> getPrivateStateById(String id) async {
    ORM.FindOne find = new ORM.FindOne(REPrivate)..whereEquals('id', id);
    REPrivate obj = await find.execute();
    if (obj == null) {
      return  new app.ErrorResponse(404, {"error": "not found object"});
    }
    
    List<ObjectDealWrapper> ret = new List();
    
    for(ObjectDeal deal in await obj.GetPengindParts()) {
      ret.add(await ObjectDealWrapper.Create(deal));
    }
    return ret;
  }
}