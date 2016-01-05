library BMSrv.UserService;
import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:shelf/shelf.dart' as shelf;
import 'package:redstone_mapper/plugin.dart';
import 'package:uuid/uuid.dart';
import "package:ini/ini.dart";
import 'package:logging/logging.dart';

import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Mail/Sender.dart';
import 'package:BMSrv/Events/SystemEvents.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/RealEstate/RealEstate.dart';
import 'package:BMSrv/Models/RealEstate/Rooms/Room.dart';
import 'package:BMSrv/Models/Utils/LikeObject.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';
import 'package:BMSrv/Models/Social/ObjGroup.dart';

import 'package:BMSrv/Models/JsonWrappers/User.dart';
import 'package:BMSrv/Models/JsonWrappers/ObjectDeal.dart';
import 'package:BMSrv/Models/JsonWrappers/RERoom.dart';

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
  MailSender mail = new MailSender('service@semplex.ru', 'bno9mjc');
  Config _config;
  
  UserService(DBAdapter this._Db, Config this._config)
  {
    _Generator = new Uuid();
    initEvents();
  }
  
  Future<dynamic> _getObject(ReType type, String idStr) {
     int id = int.parse(idStr);
     if (type != ReType.ROOM) {
       return REGeneric.Get(type, id);
     } else {
       return RERoom.Get(id);
     }
   }
  
  Future<double> _getBusyObjectParts(RealEstateBase object) async {
    List<ObjectDeal> parts = await object.GetAllParts();
    double busyParts = 0.0;
    for(ObjectDeal deal in parts) {
      busyParts += deal.part;
    }
    
    return busyParts;
  }
  
  Future _chackObjectParts(RERoom object, double reqPart) async {
    double busyPart = await _getBusyObjectParts(object);
    final double avaliablePart = object.square - busyPart; 
    if(avaliablePart < reqPart) throw new app.ErrorResponse(400, {'error': "part are not available"});
  }
  
  Future _addUserToObjectGroup(RealEstateBase obj, User user) async {
    ObjGroupUtils.addUserToGroup(obj, user);
  }
  
  initEvents() {
    EventSys.asyncMessageBus.stream(SysEvt)
      .where((SysEvt evt) => evt.type == TSysEvt.ADD_USER)
      .listen((SysEvt evt) {
        User user = evt.data;
        final String url = _config.get("ClientUrl", "client-url");
        String subj = "Добро пожаловать в мир умных инвестиций";
        String html =
          '''<a href="$url#activate?${user.uniqueID}">
             активировать мой аккаунт </a>
          ''';
        mail.createActivateMail(user.email, subj, html);
    });
  }

  @app.DefaultRoute(methods: const[app.POST])
  create(@app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['password']) ||
        _isEmpty(data['name']) ||
        _isEmpty(data['email']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }
    
    bool existUser = await UserPass.checkExistUser(data['email']);
    
    if (existUser) throw new app.ErrorResponse(400, {"error": "already exist"});

    User newUser = new User.Dummy();
    newUser.name = data['name'];
    newUser.email = data['email'];

    var exception = null;

    var saveResult = await newUser.save().catchError((var error){
      exception = error;
    });
    
    await UserPass.CreateUserPass(data['email'], data["password"], newUser.id);
    
    EventSys.asyncPub(new SysEvt(TSysEvt.ADD_USER, newUser));
    
    if (exception != null) {
      return exception;
    } else {
      User dbUser = await _getUser(newUser.email);
      return { "status" : "created" };
    }
  }

  @app.Route("/:id")
  @ProtectedAccess(filtrateByUser: true)
  @Encode()
  Future<UserWrapper> getUserById(String id) async {
    return UserWrapper.Create(await User.GetUser(id));
  }
  
  @app.Route("/:id/deals/:type/:estateid/rooms/:roomid", methods: const[app.PUT])
  @ProtectedAccess(filtrateByUser: true)
  @Encode()
  addDealForRoom(String id, String type, String estateid, String roomid,
                 @app.Body(app.FORM) Map data) async
  {
    try {
      User user = await User.GetUser(id);
      RERoom room = await RERoomUtils.getById(int.parse(roomid));
      if(room.ownerObjectId != int.parse(estateid) ||
         ReUtils.str2Type(type) != room.OwnerType)
          throw new app.ErrorResponse(400, {"error": "wrong data"});
      
      double part = double.parse(data["part"]);
      double price = await room.Price; 
      
      await _chackObjectParts(room, part);
      
      ObjectDeal deal = new ObjectDeal.DummyRoom(user, room, part, price);
          
      try {
        await deal.save();
        EventSys.asyncPub(new SysEvt(TSysEvt.ADD_DEAL, deal));
        new Future(() => _addUserToObjectGroup(room, user));
        
        return deal.id;
      } catch (error) {
        return error; 
      }
    } catch(error) {
      return new app.ErrorResponse(400, {"error": error});
    }
  }
  
  @app.Route("/:id/deals", methods: const[app.GET])
  @ProtectedAccess(filtrateByUser: true)
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
  
  @app.Route("/:id/deals/:type/:estateid/rooms/:roomid", methods: const[app.GET])
  @ProtectedAccess(filtrateByUser: true)
  @Encode()
  getDealsForRoom(String id, String type, String estateid, String roomid,
                  @app.Body(app.FORM) Map data) async
  {
    ReType reType = ReUtils.str2Type(type);
    RERoom room = await _getObject(ReType.ROOM, roomid);
    if(room.ownerObjectId != int.parse(estateid) ||
       ReUtils.str2Type(type) != room.OwnerType) 
        throw new app.ErrorResponse(400, {"error": "wrong data"});
    
    List<ObjectDealWrapper> ret = new List();

    List<ObjectDeal> deals = await room.GetAllParts();
    deals ??= [];
    
    for (ObjectDeal deal in deals.where((ObjectDeal el) => 
                              el.userId == int.parse(id)))
    {
      ret.add(await ObjectDealWrapper.Create(deal));
    }
    return ret;
  }
  
  @app.Route("/:id/likes", methods: const[app.GET])
  @ProtectedAccess(filtrateByUser: true)
  @Encode()
  Future<List<RERoomWrapper>> getUserLikes(String id) async {
    User user = await User.GetUser(id);

    List<RERoomWrapper> ret = new List();
    
    for(LikeObject obj in await LikeObjectsUtils.GetForUser(user)) {
      RERoom room = await obj.room;
      var wrap = await RERoomWrapper.Create(room);
      ret.add(wrap);
    }
    return ret;
  }
  
  @app.Route("/:id/likes/:roomId", methods: const[app.GET])
  @ProtectedAccess(filtrateByUser: true)
  @Encode()
  Future<bool> haveLake(String id, roomId) async {
    User user = await User.GetUser(id);
    RERoom room = await RERoomUtils.getById(int.parse(roomId));
    return LikeObjectsUtils.HaveLike(room, user);
  }
  
  @app.Route("/:id/likes/:roomId", methods: const[app.DELETE])
  @ProtectedAccess(filtrateByUser: true)
  Future deleteLake(String id, roomId) async {
    User user = await User.GetUser(id);
    RERoom room = await RERoomUtils.getById(int.parse(roomId));
    return LikeObjectsUtils.DeleteLike(room, user);
  }
  
  @app.Route("/:id/likes/:roomId", methods: const[app.PUT])
  @ProtectedAccess(filtrateByUser: true)
  Future addUserLike(String id, String roomId) async {
    User user = await User.GetUser(id);
    RERoom room = await RERoomUtils.getById(int.parse(roomId));
    if(await LikeObjectsUtils.HaveLike(room, user)) {
      return new app.ErrorResponse(400, {"error": "already laked"});
    }
    return LikeObjectsUtils.CreateLike(room, user);
  }
  
  @app.Route("/activate/:uniqueId", methods: const[app.GET])
  @FreeAccess()
  Future validateUser(String uniqueId) async {
    User user = await UserUtils.GetUserByUniqueId(uniqueId);
    if (user == null) return new app.ErrorResponse(400, {"error": "not found"});
    await user.Activate();
    return { 'status' : 'activated' };
  }
}