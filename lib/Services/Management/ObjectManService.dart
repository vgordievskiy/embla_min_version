library tradem_srv.services.management.object_man_service;
import 'dart:async';
import 'dart:convert';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';

import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Middleware/input_parser/input_parser.dart';
import '../../Models/Objects.dart';
import '../../Utils/Prices.dart';

class ObjectManService extends Controller {
  final Repository<Entity> entities;

  ObjectManService(this.entities);

  Future<Entity> _getObjById(String id) => entities.find(int.parse(id));

  _returnOk(String key, var value)
    => {'msg':'ok', key : value};

  Future _setEnableValue(String id, bool enabled) async {
    try {
      Entity obj = await _getObjById(id);
      obj.enabled = enabled;
      await entities.save(obj);
      return _returnOk('id', obj.id);
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
          ..busy_part = 0
          ..data = {
            'value' : JSON.decode(params['data'])
          };
        await entities.save(obj);
        return _returnOk('id', obj.id);
    } else {
      this.abortBadRequest('wrong data');
    }
  }

  @Put('/:id') update(Input args, {String id}) async {
    Map params = args.body;
    if(expect(params, 'field') && expect(params, 'value')) {
      Entity obj = await _getObjById(id);
      switch (new Symbol(params['field'])) {
        case #type:
          obj.type = EntityType.fromStr(params['value']).Str;
          break;
        case #pieces:
          obj.pieces = int.parse(params['value']);
          break;
        case #data:
          obj.data = { 'value' : JSON.decode(params['value']) };
          break;
      }
      await entities.save(obj);
      return obj;
    } else {
      this.abortBadRequest('wrong data');
    }

  }

  @Put('/:id/enable') enableObj({String id}) => _setEnableValue(id, true);
  @Delete('/:id/enable') disableObj({String id})  => _setEnableValue(id, false);

  @Post('/:id/price') addPrice(Input args, {String id}) async {
    Map params = args.body;
    if(expect(params, 'value')) {
      Entity obj = await _getObjById(id);
      final double value = double.parse(params['value']);
      Price price = await PricesUtils.addPrice(obj, value);
      return _returnOk('id', price.id);
    } else {
      this.abortBadRequest('wrong data');
    }
  }

}
