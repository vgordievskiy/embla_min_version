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

Future<dynamic> _getObject(ReType type, String id) {
  switch (type) {
    case ReType.PRIVATE : return REPrivate.Get(id);
    case ReType.COMMERCIAL : return RECommercial.Get(id);
    case ReType.LAND : return RELand.Get(id);
    case ReType.ROOM : return RERoom.Get(id);
  }
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
  
  Future<double> _getBusyObjectParts(RealEstateBase object) async {
    List<ObjectDeal> parts = await object.GetAllParts();
    double busyParts = 0.0;
    for(ObjectDeal deal in parts) {
      busyParts += deal.part;
    }
    
    return busyParts;
  }
  
  Future _chackObjectParts(RealEstateBase object, double reqPart) async {
    double busyPart = await _getBusyObjectParts(object);
    final double avaliablePart = 100.0 - busyPart; 
    if(avaliablePart < reqPart) throw new app.ErrorResponse(400, {'error': "part are not available"});
  }

  @app.DefaultRoute(methods: const[app.POST])
  create(@app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['password']) ||
        _isEmpty(data['name']) ||
        _isEmpty(data['email']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }

    User newUser = new User.Dummy();
    newUser.name = data['name'];
    newUser.email = data['email'];

    var exception = null;

    var saveResult = await newUser.save().catchError((var error){
      exception = error;
    });
    
    await UserPass.CreateUserPass(data['email'], data["password"], newUser.id);
    
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
  
  @app.Route("/:id/set_deal/:type/:estateid/room/:roomid", methods: const[app.PUT])
  @Encode()
  addDealForRoom(String id, String type, String estateid, String roomid,
                 @app.Body(app.FORM) Map data) async
  {
    User user = await User.GetUser(id);
    RERoom room = await _getObject(ReType.ROOM, roomid);
    if(room.ownerObjectId != int.parse(estateid) ||
       ReUtils.str2Type(type) != room.OwnerType) throw new app.ErrorResponse(400, {"error": "wrong data"});
    
    double part = double.parse(data["part"]);
    
    await _chackObjectParts(room, part);
    
    ObjectDeal deal = new ObjectDeal.DummyRoom(user, room, part);
        
    try {
      await deal.save();
      await deal.$.AddRelation('hasTargetRealEstate', room.$);
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