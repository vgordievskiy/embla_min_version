library BMSrv.Models.RealEstate;

import 'dart:async';

export 'package:BMSrv/Models/RealEstate/REPrivate.dart';
export 'package:BMSrv/Models/RealEstate/RECommercial.dart';
export 'package:BMSrv/Models/RealEstate/RELand.dart';

import 'package:observe/observe.dart';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:BMSrv/Storage/SemplexStorage.dart';
import 'package:BMSrv/Storage/BMOntology.dart';
import 'package:BMSrv/Models/ObjectDeal.dart';
import 'package:logging/logging.dart';

abstract class RealEstateBase {
  static OntoClass OwnerClass = GetOntology().GetClass("RealEstate");
  
  int id;
  
  Future<List<ObjectDeal>> _getParts(bool isPending) async {
    ORM.Find find = new ORM.Find(ObjectDeal)
                            ..where(new ORM.Equals('objectId', this.id)
                            .and(new ORM.Equals('isPending', isPending)));
    return find.execute();
  }
  
  Future<List<ObjectDeal>> GetPengindParts() async {
    return _getParts(true);
  }
  
  Future<List<ObjectDeal>> GetApprovedParts() async {
    return _getParts(false);
  }
  
  Future<List<ObjectDeal>> GetAllParts() async {
    ORM.Find find = new ORM.Find(ObjectDeal)
                        ..where(new ORM.Equals('objectId', this.id));
    return find.execute();
  }
}
