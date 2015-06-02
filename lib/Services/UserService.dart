library BMSrv.UserService;
import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

import 'package:BMSrv/Events/Event.dart';
import 'package:BMSrv/Utils/DbAdapter.dart';
import 'package:BMSrv/Utils/Encrypter.dart' as Enc;
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';

import 'package:BMSrv/Models/JsonWrappers/User.dart';
import 'package:BMSrv/Models/JsonWrappers/ObjectDeal.dart';

bool _isEmpty(String value) => value == "";

Future<User> _getUser(String name) async {
  ORM.Find find = new ORM.Find(User)..where(new ORM.Equals('userName', name));
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

    User newUser = new User.Dummy();
    newUser.userName = data['username'];
    newUser.name = data['name'];
    newUser.password = Enc.encryptPassword(data["password"]);
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
      
      User dbUser = await _getUser(newUser.userName);
      return { "status" : "created" };
    }
  }

  @app.Route("/:id")
  @Encode()
  Future<UserWrapper> getUserById(String id) async {
    return UserWrapper.Create(await User.GetUser(id));
  }
  
  @app.Route("/:id/set_deal_private/:realestateid", methods: const[app.PUT])
  @Encode()
  addDealForREPrivate(String id, String realestateid) async {
    User user = await User.GetUser(id);
    REPrivate object = await REPrivate.Get(realestateid);
    
    ObjectDeal deal = new ObjectDeal.DummyPrivate(user, object);
    
    try {
      await deal.save();
      await deal.$.AddRelation('hasTargetRealEstate', object.$);
      await deal.$.AddRelation('hasUserParticipant', user.$);
      return deal.id;
    } catch (error) {
      return error; 
    }
  }
  
  @app.Route("/:id/set_deal_commercial/:realestateid", methods: const[app.PUT])
  @Encode()
  addDealForRECommercial(String id, String realestateid) async {
    User user = await User.GetUser(id);
    RECommercial object = await RECommercial.Get(realestateid);
    
    ObjectDeal deal = new ObjectDeal.DummyCommercial(user, object);
    
    try {
      await deal.save();
      await deal.$.AddRelation('hasTargetRealEstate', object.$);
      await deal.$.AddRelation('hasUserParticipant', user.$);
      return deal.id;
    } catch (error) {
      return error; 
    }
  }
  
  @app.Route("/:id/set_deal_land/:realestateid", methods: const[app.PUT])
  @Encode()
  addDealForRELand(String id, String realestateid) async {
    User user = await User.GetUser(id);
    RELand object = await RELand.Get(realestateid);
    
    ObjectDeal deal = new ObjectDeal.DummyLand(user, object);
    
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