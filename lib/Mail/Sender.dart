library BMSrv.Mail.Sender;

import 'dart:async';

import 'package:mailer/mailer.dart';
import 'package:logging/logging.dart';

import 'package:SrvCommon/SrvCommon.dart';


class MailSender 
{
  SmtpOptions options;
  SmtpTransport transport;
  
  MailSender()
  {
    options = new YandexSmtpOptions();
    setUserName('service@semplex.ru', 'bno9mjc');
    transport = new SmtpTransport(options);
  }
  
  void setUserName(String user, String passwd)
  {
    options..username = user
      ..password = passwd; 
  }
  
  createActivateMail() {
    var envelope = new Envelope()
    ..from = 'service@semplex.ru'
    ..recipients.add('v.gordievskiy@gmail.com')
    ..subject = 'Testing the Dart Mailer library'
    ..text = 'This is a cool email message. Whats up?'
    ..html = '<h1>Test</h1><p>Hey!</p>';
    
    transport.send(envelope).then((envelope) => print('Email sent!'))
    .catchError((e) => print('Error occurred: $e'));
  }
  
  
}

