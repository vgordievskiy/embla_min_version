library srv_base.utils.mail.isolated;

import 'dart:async';
import 'dart:isolate';
import 'package:mailer/mailer.dart';
import 'package:log4dart/log4dart.dart';
import 'Mail.dart';

export 'Mail.dart' show TMessage;

class IsoSender implements MailSender {
  final log = LoggerFactory.getLogger("MailSender.isolated");
  final String user;
  final String passwd;
  final String baseMail;

  ReceivePort _port = new ReceivePort();
  Isolate _isolate;
  MailSender _impl;

  SendPort get port => _port.sendPort;

  IsoSender(this.user, this.passwd, [this.baseMail = null]);

  Future start() async {
    _isolate = new Isolate(_port.sendPort);
    _impl = new MailSender(user, passwd, baseMail);
    _port.listen(_handleRequest);
  }

  _handleRequest(TMessage msg) async {
    await _impl.sendMail(msg);
  }

  @override
  SmtpOptions get options => _impl.options;

  @override
  set options(SmtpOptions options) {
    _impl.options = options;
  }

  @override
  SmtpTransport get transport => _impl.transport;

  @override
  set transport(SmtpTransport transport) {
    this.transport = transport;
  }

  @override
  createMailAndSend(String target, String subj, String html) async {
    sendMail(new TMessage(subj, html, [target]));
  }

  @override
  sendMail(TMessage msg) async {
    port.send(msg);
  }

  @override
  void setUserName(String user, String passwd) {
    _impl.setUserName(user, passwd);
  }

}
