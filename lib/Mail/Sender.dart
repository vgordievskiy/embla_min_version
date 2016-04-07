library BMSrv.Mail.Sender;

import 'dart:async';

import 'package:mailer/mailer.dart';
import 'package:logging/logging.dart';

import 'package:SrvCommon/SrvCommon.dart';


class MailSender
{
  final log = new Logger("BMSrv.Mail.Sender");

  SmtpOptions options;
  SmtpTransport transport;

  final String user;
  final String passwd;
  final String baseMail;

  MailSender(this.user, this.passwd, [this.baseMail = null])
  {
    options = new YandexSmtpOptions();
    setUserName(this.user, passwd);
    transport = new SmtpTransport(options);
  }

  void setUserName(String user, String passwd)
  {
    options..username = user
      ..password = passwd;
  }

  createActivateMail(String target, String subj, String html) {
    Envelope envelope = new Envelope();
    envelope.from = baseMail ?? user;
    envelope.recipients.add(target);
    envelope.subject = subj;
    envelope.html = html;

    transport.send(envelope)
      .then((envelope) => log.info('Email sent!'))
      .catchError((e) => log.log(Level.SEVERE, 'Error occurred: $e'));
  }

}
