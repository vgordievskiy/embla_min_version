library BMSrv.Models.JsonWrappers.OntoUser;
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';

import 'package:BMSrv/Models/OntoUser.dart';
import 'package:BMSrv/Models/UserPeper/UserPaper.dart';
import 'package:BMSrv/Models/UserPeper/PaperItem.dart';

@Decode()
class PaperItemWrapper {
  PaperItem _paper;
  PaperItemWrapper(this._paper);
  
  @Field()
  String get Id => _paper.EntityName;
  
  @Field()
  String get Element => _paper.Element;
  
  @Field()
  int get OrederNum => _paper.OrderNum;
  
  @Field()
  String get Params => _paper.Params;
  
  @Field()
  String get Style => _paper.Style;
}

@Decode()
class UserPaperWrapper {
  UserPaper _paper;
  
  @Field()
  List<PaperItemWrapper> Items;
  
  UserPaperWrapper.byPaper(this._paper) {
    Items = new List();
    for(PaperItem item in _paper.GetItems()) {
      Items.add(new PaperItemWrapper(item));
    }
  }
  
  UserPaperWrapper.byParams(this._paper, this.Items);
  
  @Field()
  String get Id => _paper.EntityName;
  
  @Field()
  String get Name => _paper.Name;
  
  @Field()
  String get Color => _paper.Color;
  
  @Field()
  String get TargetItem => _paper.TargetItem;
}

@Decode()
class OntoUserWrapper {
  OntoUser _user;
  
  @Field()
  List<UserPaperWrapper> Papers;
  
  OntoUserWrapper.byUser(this._user) {
    Papers = new List();
    for(UserPaper paper in _user.GetPapers()) {
      Papers.add(new UserPaperWrapper.byPaper(paper));
    }
  }
  
  OntoUserWrapper.byParams(this._user, this.Papers);

  @Field()
  String get UserName => _user.UserName;

  @Field()
  Object get Data => _user.Data;
}