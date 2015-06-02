library BMSrv.RealEstateService;
import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

import 'package:BMSrv/Events/Event.dart';
import 'package:BMSrv/Utils/DbAdapter.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/JsonWrappers/RECommercial.dart';
import 'package:BMSrv/Models/JsonWrappers/REPrivate.dart';
import 'package:BMSrv/Models/JsonWrappers/RELand.dart';

bool _isEmpty(String value) => value == "";

Future<User> _getUser(String name) async {
  ORM.Find find = new ORM.Find(User)..where(new ORM.Equals('userName', name));
  List foundUsers = await find.execute();
  return foundUsers[0];
}

@app.Group("/realestate")
class RealEstateService {
  DBAdapter _Db;
  Uuid _Generator;
  final log = new Logger("BMSrv.Services.RealEstateService");
  RealEstateService(DBAdapter this._Db)
  {
    _Generator = new Uuid();
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
  
  @app.Route("/private/:id", methods: const[app.GET])
  @Encode()
  getPrivateById(String id) async {
    
  }
  
  @app.Route("/:id")
  @Encode()
  getObjectById(String id) async {
    REPrivate ret = await REPrivate.Get(id);
    return ret;
  }
}