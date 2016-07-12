library srv_base.utils.mail;

import 'dart:convert';

import 'package:mailer/mailer.dart';
import 'package:logging/logging.dart';

class TMessage {
  String subj;
  String html;
  List<String> targets;

  TMessage(this.subj, this.html, this.targets);
}

class MailSender
{
  final log = new Logger("srv_base.Mail.Sender");

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

  sendMail(TMessage msg) async {
    Envelope envelope = new Envelope();
    envelope.encoding = UTF8;
    envelope.from = baseMail ?? user;
    envelope.recipients.addAll(msg.targets);
    envelope.subject = msg.subj;
    envelope.html = msg.html;

    return transport.send(envelope)
             .then((envelope) => log.info('Email sent!'))
             .catchError((e) => log.log(Level.SEVERE, 'Error occurred: $e'));
  }

  createMailAndSend(String target, String subj, String html) {
    TMessage msg = new TMessage(subj, html, [target]);
    return sendMail(msg);
  }

}
