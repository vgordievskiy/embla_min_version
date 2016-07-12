library tradem_srv.services.message_service;

import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:harvest/harvest.dart';
import 'package:mustache/mustache.dart';
import '../Events/UserEvents.dart';

import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Models/Users.dart';
import 'package:tradem_srv/Utils/Mail.dart';
import 'package:logging/logging.dart';

export 'package:srv_base/Models/Users.dart';

Map<String, String> templates = {
  'new-user' : '''<h2>Привет</h2><div>{{ name }}</div>'''
};

class MessageService extends Controller {
  final log = new Logger("tradem.Services.MessageService");
  MessageBus _bus;
  //MailSender mail = new MailSender('service@semplex.ru', 'SSemplex!2#');
  MailSender mail = new MailSender('v.gordievskiy@semplex.ru', 'bno9mjc');

  MessageService()
  {
    _bus = Utils.$(MessageBus);
    _bus.subscribe(CreateUser,(CreateUser event) async {
      await newUser(event.user);
    });
  }

  newUser(User user) async {
    Template mailBody = new Template(templates['new-user']);
    String subj = "Добро пожаловать в мир умных инвестиций";
    String html = mailBody.renderString({ 'name' : user.email });
    await mail.sendMail(new TMessage(subj, html, [user.email]));
    log.info("send welcome email");
  }
}
