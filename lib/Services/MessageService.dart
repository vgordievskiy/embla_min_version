library tradem_srv.services.message_service;

import 'dart:async';
import 'package:embla/http.dart';
import 'package:embla/http_annotations.dart';
import 'package:harvest/harvest.dart';
import 'package:mustache/mustache.dart';
import '../Events/UserEvents.dart';

import 'package:srv_base/Utils/Utils.dart';
import 'package:srv_base/Models/Users.dart';
import 'package:tradem_srv/Config/Config.dart';
import 'package:tradem_srv/Utils/Mail.dart';
import 'package:logging/logging.dart';

export 'package:srv_base/Models/Users.dart';

Map<String, Map> templates = {
  'new-user' :
  {
    'subj' : 'Добро пожаловать в мир умных инвестиций',
    'body' : '''<h2>Привет</h2><div>{{ name }}</div>'''
  }
};

class MessageService extends Controller {
  final log = new Logger("tradem.Services.MessageService");
  MessageBus _bus;
  final AppConfig _config;
  MailSender mail;

  MessageService()
    : _config = Utils.$(AppConfig)
  {
    mail = new MailSender(_config.emailLogin, _config.emailPassword);
    _bus = Utils.$(MessageBus);
    _bus.subscribe(CreateUser,(CreateUser event) {
      return newUser(event.user);
    });
  }

  newUser(User user) {
    log.info("create new user");
    Template mailBody = new Template(templates['new-user']['body']);
    String subj = templates['new-user']['subj'];
    String html = mailBody.renderString({ 'name' : user.email });
    return mail.sendMail(new TMessage(subj, html, [user.email]));
  }
}
