library BMSrv.UserService;
import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:shelf/shelf.dart' as shelf;
import 'package:redstone_mapper/plugin.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

import 'package:BMSrv/Utils/Encrypter.dart' as Enc;
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/UserPeper/UserPaper.dart';
import 'package:BMSrv/Utils/DbAdapter.dart';

import 'package:BMSrv/Events/Event.dart';

import 'package:BMSrv/Models/JsonWrappers/OntoUser.dart';


bool _isEmpty(String value) => value == "";

Future<User> _getUser(String name) async {
  ORM.Find find = new ORM.Find(User)..where(new ORM.Equals('userName', name));
  List foundUsers = await find.execute();
  return foundUsers[0];
}

@app.Group("/users")
class UserService {
  DBAdapter _Db;
  UserManager _UserManager;
  Uuid _Generator;
  final log = new Logger("BMSrv.Services.UserService");
  UserService(DBAdapter this._Db,
              UserManager this._UserManager)
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

    User newUser = new User();
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
      User dbUser = await _getUser(newUser.userName);
      EventSys.GetEventBus().fire(new CreateUser(newUser.id, newUser));
      return { "status" : "created" };
    }
  }

  @app.Route("/:id")
  @Encode()
  Future<OntoUserWrapper> getUserById(String id) async {
    OntoUser user = _UserManager.GetUser(int.parse(id));
    
    List<UserPaperWrapper> papers = new List();
    for(UserPaper paper in user.GetPapers()) {
      paper = await UserPaper.Get(paper.EntityName);
      papers.add(new UserPaperWrapper.byPaper(paper));
    }
    
    return new OntoUserWrapper.byParams(user, papers);
  }

  @app.Route("/:id/paper", methods: const[app.POST])
  createPaper(String id,
              @app.Body(app.FORM) Map data) async {
    if (_isEmpty(data['Color']) ||
        _isEmpty(data['TargetItem']) ||
        _isEmpty(data['Label']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }
    
    Map<String, dynamic> params = new Map();
    params['hasPaperColor'] = data['Color'];
    params['hasPaperName'] = data['Label'];
    params['hasPaperTargetItem'] = data['TargetItem'];
    
    UserPaper paper = await UserPaper.Create(params);
  
    _UserManager.GetUser(int.parse(id)).AddPaper(paper);
    
    //TODO!!!: Refactor It
    
    await _UserManager.GetUser(int.parse(id)).Update();
    
    return paper.EntityName;
  }
  
  @app.Route("/:id/paper/:paperId", methods: const[app.DELETE])
  deletePaper(String id, String paperId) async {
    OntoUser user = _UserManager.GetUser(int.parse(id));
    UserPaper paper = user.GetPapers().firstWhere((UserPaper paper) => paper.EntityName == paperId);
    await paper.Delete();
  }
  
  @app.Route("/:id/paper/:paperId", methods: const[app.POST])
  addPaperItem(String id, String paperId, 
               @app.Body(app.FORM) Map data) async
  {
    if (_isEmpty(data['Element']) ||
        _isEmpty(data['Number']))
    {
      throw new app.ErrorResponse(403, {"error": "data empty"});
    }
    
    Map<String, dynamic> params = new Map();
    params['hasPaperItemElement'] = data['Element'];
    params['hasPaperItemNumber']  = int.parse(data['Number']);
    if (data.containsKey('hasPaperItemParams')) {
      params['hasPaperItemParams']  = data['Params']; 
    }
    if (data.containsKey('hasPaperItemStyle')) { 
      params['hasPaperItemStyle']  = data['Style'];
    }
    
    PaperItem item = await PaperItem.Create(params);
    
    OntoUser user = _UserManager.GetUser(int.parse(id));
    
    UserPaper paper = user.GetPapers().firstWhere((UserPaper paper){
      return paper.EntityName == paperId;
    });
    
    await paper.AddItem(item);
    await user.Update();
    
    return item.EntityName;
  }
  
  @app.Route("/:id/paper/:paperId/", methods: const[app.DELETE])
  deletePaperItem(String id, String paperId, 
               @app.Body(app.FORM) Map data) async
  {
    throw new app.ErrorResponse(501, {"error": "not implemented"});
  }

}