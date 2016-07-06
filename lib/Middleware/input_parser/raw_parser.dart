library srv_base.middleware.input_parser.raw_parser;
import 'dart:convert';
import 'dart:async';
import 'dart:io' show ContentType, HttpHeaders;
import 'package:embla/http.dart';

import 'input_parser.dart';

class RawInputParser extends InputParser {
  Future parse(Stream<List<int>> body, Encoding encoding, [Request request]) async {
    return parseString(await body.map(encoding.decode).join('\n'));
  }

  dynamic parseString(String value) {
    if (new RegExp(r'^(?:\d+\.?\d*|\.\d+)$').hasMatch(value)) {
      return num.parse(value);
    }
    if (new RegExp(r'^true$').hasMatch(value)) {
      return true;
    }
    if (new RegExp(r'^false$').hasMatch(value)) {
      return false;
    }
    return value == '' ? null : value;
  }

  @override
  String get mimeType => null;
}
