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

  Future<Entity> _getObjById(String id) => entities.find(int.parse(id));

  Future _setEnableValue(String id, bool enabled) async {
    try {
      Entity obj = await _getObjById(id);
      obj.enabled = true;
      await entities.save(obj);
      return {'msg':'ok', 'id' : obj.id};
    } catch(err) {
      return abortNotFound();
    }
  }

  @Post('/') create(Input args) async {
    Map params = args.body;
    if(expect(params, 'type') &&
       expect(params, 'data') &&
       expect(params, 'pieces')) {
        EntityType type = EntityType.fromStr(params['type']);
        Entity obj = new Entity()
          ..type = EntityType.fromStr(params['type']).Str
          ..pieces = int.parse(params['pieces'])
          ..enabled = false
          ..data = {
            'value' : JSON.decode(params['data'])
          };
        await entities.save(obj);
        return {'msg':'ok', 'id' : obj.id};
    } else {
      this.abortBadRequest('wrong data');
    }
  }

  @Put('/:id/enable') enableObj({String id}) => _setEnableValue(id, true);
  @Delete('/:id/enable') disableObj({String id})  => _setEnableValue(id, false);

}
