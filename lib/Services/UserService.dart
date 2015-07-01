library BMSrv.UserService;
import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';

import 'package:BMSrv/Models/JsonWrappers/User.dart';
import 'package:BMSrv/Models/JsonWrappers/ObjectDeal.dart';

bool _isEmpty(String value) => value == "";

Future<User> _getUser(String email) async {
  ORM.Find find = new ORM.Find(User)..where(new ORM.Equals('email', email));
  List foundUsers = await find.execute();
  return foundUsers[0];
}

@app.Group("/users")
class UserService {
  DBAdapter _Db;
  Uuid _Generator;
  final log = new Logger("BMSrv.Services.UserService");
  UserService(DBAdapter this._Db)
  {
    _Generator = new Uuid();
  }

  @app.DefaultRoute(methods: const[app.POST])
  create(@app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['username']) ||
        _isEmpty(data['password']) ||
        _isEmpty(data['name']) ||
        _isEmpty(data['email']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }
    
    int id = await UserPass.CreateUserPass(data['email'], data["password"]);

    User newUser = new User.Dummy();
    newUser.id = id;
    newUser.name = data['name'];
    newUser.email = data['email'];

    var exception = null;

    var saveResult = await newUser.save().catchError((var error){
      exception = error;
    });
    
    if (exception != null) {
      return exception;
    } else {
      
      await newUser.$.AddData("hasUserName", newUser.name);
      await newUser.$.AddData("hasEmail", newUser.email);
      await newUser.$.AddData("hasUserId", newUser.id);
      
      User dbUser = await _getUser(newUser.email);
      return { "status" : "created" };
    }
  }

  @app.Route("/:id")
  @Encode()
  Future<UserWrapper> getUserById(String id) async {
    return UserWrapper.Create(await User.GetUser(id));
  }
  
  @app.Route("/:id/set_deal/private/:realestateid", methods: const[app.PUT])
  @Encode()
  addDealForREPrivate(String id, String realestateid, @app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['part']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }
    User user = await User.GetUser(id);
    REPrivate object = await REPrivate.Get(realestateid);
    
    double part = double.parse(data["part"]);
    ObjectDeal deal = new ObjectDeal.DummyPrivate(user, object, part);
    
    try {
      await deal.save();
      await deal.$.AddRelation('hasTargetRealEstate', object.$);
      await deal.$.AddRelation('hasUserParticipant', user.$);
      return deal.id;
    } catch (error) {
      return error; 
    }
  }
  
  @app.Route("/:id/set_deal/commercial/:realestateid", methods: const[app.PUT])
  @Encode()
  addDealForRECommercial(String id, String realestateid, @app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['part']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }
    User user = await User.GetUser(id);
    RECommercial object = await RECommercial.Get(realestateid);
    
    double part = double.parse(data["part"]);
    ObjectDeal deal = new ObjectDeal.DummyCommercial(user, object, part);
    
    try {
      await deal.save();
      await deal.$.AddRelation('hasTargetRealEstate', object.$);
      await deal.$.AddRelation('hasUserParticipant', user.$);
      return deal.id;
    } catch (error) {
      return error; 
    }
  }
  
  @app.Route("/:id/set_deal/land/:realestateid", methods: const[app.PUT])
  @Encode()
  addDealForRELand(String id, String realestateid, @app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['part']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }
    User user = await User.GetUser(id);
    RELand object = await RELand.Get(realestateid);
    
    double part = double.parse(data["part"]);
    ObjectDeal deal = new ObjectDeal.DummyLand(user, object, part);
    
    try {
      await deal.save();
      await deal.$.AddRelation('hasTargetRealEstate', object.$);
      await deal.$.AddRelation('hasUserParticipant', user.$);
      return deal.id;
    } catch (error) {
      return error; 
    }
  }
  
  @app.Route("/:id/deals", methods: const[app.GET])
  @Encode()
  Future<List<ObjectDealWrapper>> getUserDeals(String id) async {
    User user = await User.GetUser(id);

    List<ObjectDealWrapper> ret = new List();
    
    for(ObjectDeal deal in await user.GetDeals()) {
      var wrap = await ObjectDealWrapper.Create(deal);
      ret.add(wrap);
    }
    return ret;
  }
}