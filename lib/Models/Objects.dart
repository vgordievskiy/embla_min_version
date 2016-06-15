library tradem_srv.models.objects;
import 'package:embla_trestle/embla_trestle.dart';

class Entity extends Model {
  @field int id;
  @field int type;
  @field Map data;
}
