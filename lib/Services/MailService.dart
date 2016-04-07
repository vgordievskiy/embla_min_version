library BMSrv.MailService;
import 'dart:async';
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:uuid/uuid.dart';
import "package:ini/ini.dart";
import "package:otp/otp.dart";
import 'package:logging/logging.dart';

import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Events/UserEvent.dart';
import 'package:BMSrv/Events/SystemEvents.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Mail/Sender.dart';

@app.Group("/messages")
class MailService {
  final log = new Logger("BMSrv.Services.MailService");
  Config _config;
  MailSender mail = new MailSender('service@semplex.ru', 'bno9mjc');
  MailService(Config this._config)
    { initEvents(); }

  initEvents() {
    EventSys.asyncMessageBus.stream(SysEvt)
      .where((SysEvt evt) => evt.type == TSysEvt.ADD_USER ||
         evt.type == TSysEvt.WELCOME_MSG).listen(newUser);
    EventSys.asyncMessageBus.stream(SysEvt)
      .where((SysEvt evt) => evt.type == TSysEvt.USER_RESET_PASS)
        .listen(resetUserPass);
    EventSys.asyncMessageBus.stream(SysEvt)
      .where((SysEvt evt) => evt.type == TSysEvt.SEND_EMAIL)
        .listen(sendEmail);
  }

  newUser(SysEvt evt) {
    User user = evt.data;
    final String url = _config.get("ClientUrl", "client-url");
    String subj = "Добро пожаловать в мир умных инвестиций";
    String html =
      '''<a href="$url#activate?${user.uniqueID}">
         активировать мой аккаунт </a>
         <h4>
          Или введите ссылку в браузере: <br>
            $url#activate?${user.uniqueID}
         </h4>
      ''';
    mail.sendMail(new TMessage(subj, html, [user.email]));
    log.info("send welcome email");
  }

  resetUserPass(SysEvt evt) {
      User user = evt.data['user'];
      String pass = evt.data['pass'];

      String subj = "Semplex. Ваш новый пароль";
      String html =
        '''<h4>
            Вы инициировали смену пароля. <br>
            Новые данные для входа:
           </h4>
           <h4>
            email: ${user.email} <br>
            пароль: ${pass}
           </h4>
           <h2>После входа в систему поменяйте пароль в личном кабинете!</h2>
        ''';
      mail.sendMail(new TMessage(subj, html, [user.email]));
      log.info("reset user pass - send new pass");
  }

  sendEmail(SysEvt evt) {
      User user = evt.data['user'];
      String subj = evt.data['subj'];
      String html = evt.data['html'];
      mail.sendMail(new TMessage(subj, html, [user.email]));
      log.info("send email");
  }

}
