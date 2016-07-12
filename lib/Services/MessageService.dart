library tradem_srv.services.message_service;

import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:harvest/harvest.dart';
import '../Events/UserEvents.dart';

import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Models/Users.dart';
import 'package:tradem_srv/Utils/Mail.dart';
import 'package:logging/logging.dart';

export 'package:srv_base/Models/Users.dart';

class MessageService extends Controller {
  final log = new Logger("tradem.Services.MessageService");
  MessageBus _bus;
  MailSender mail = new MailSender('service@semplex.ru', 'SSemplex!2#');

  MessageService()
  {
    _bus = Utils.$(MessageBus);
    _bus.subscribe(CreateUser,(CreateUser event){
      newUser(event.user);
    });
  }

  newUser(User user) {
    String subj = "Добро пожаловать в мир умных инвестиций";
    String html =
      '''<h4>
          Привет
         </h4>
      ''';
    mail.sendMail(new TMessage(subj, html, [user.email]));
    log.info("send welcome email");
  }
}
