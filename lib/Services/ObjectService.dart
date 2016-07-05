library tradem_srv.services.object_service;

import 'dart:async';
import 'dart:convert';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';

import '../Utils/Utils.dart';
import '../Utils/QueryLimit.dart';
import '../Models/Objects.dart';
import '../Middleware/input_parser/input_parser.dart';

class ObjectService extends Controller with QueryLimit {
  final Repository<Entity> entities;

  ObjectService(this.entities);

  Future<Entity> _getObjById(String id) => entities.find(int.parse(id));

  _returnOk(String key, var value) => {'msg':'ok', key : value};

  @Get('/') getAllObjects(Input args) {
    Map params = args.body;
    RepositoryQuery query = entities.where((el) => el.enabled == true);

    if(params.containsKey('count')) {
      final int count = int.parse(params['count']);
      if(params.containsKey('page')) {
        final int page = int.parse(params['page']);
        query = limit(query, count, page);
      } else {
        query = limit(query, count);
      }
    }

    return query.get().toList();
  }

  @Get('/:id') getObject({String id}) => _getObjById(id);

}
