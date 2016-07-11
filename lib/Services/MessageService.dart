library tradem_srv.services.message_service;

import 'dart:async';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:embla_trestle/embla_trestle.dart';
import 'package:harvest/harvest.dart';
import '../Events/UserEvents.dart';

import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Utils/Crypto.dart' as crypto;
import 'package:srv_base/Middleware/input_parser/input_parser.dart';
import 'package:srv_base/Models/Users.dart';
import '../Utils/Deals.dart';
import '../Utils/Prices.dart';

export 'package:srv_base/Models/Users.dart';

class MessageService extends Controller {
  MessageBus _bus;

  MessageService()
  {
    _bus = Utils.$(MessageBus);
    _bus.subscribe(CreateUser,(CreateUser event){
      print("MESSAGE !!!!!!!!!!!!!!!!!!!!!!!!!!! ${event.user.id}");
    });
  }
}
