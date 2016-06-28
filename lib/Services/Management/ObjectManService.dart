library tradem_srv.services.management.object_man_service;
import 'dart:async';
import 'dart:convert';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';

import '../../Utils/Utils.dart';
import '../../Models/Objects.dart';
import '../../Middleware/input_parser/input_parser.dart';


class ObjectManService extends Controller {
  final Repository<Entity> entities;

  ObjectManService(this.entities);

  @Post('/') create(Input args) async {
    Map params = args.body;
    if(expect(params, 'type') &&
       expect(params, 'data')) {
        EntityType type = EntityType.fromStr(params['type']);
        Entity obj = new Entity()
          ..type = EntityType.toInt(type)
          ..data = params['data'];
    } else {
      this.abortBadRequest('wrong data');
    }
  }

}
