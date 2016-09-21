library srv_base.utils.crypro;

import 'dart:convert';
import 'package:crypto/crypto.dart';

String encryptPassword(String pass)
  => sha1.convert(UTF8.encode(pass)).toString();
