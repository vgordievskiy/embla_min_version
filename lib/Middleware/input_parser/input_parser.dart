library tradem_srv.middleware.input_parser.i_input_parser;
import 'dart:async';
import 'dart:convert';
import 'package:embla/http.dart';

abstract class InputParser {
  String get mimeType;
  Future parse(Stream<List<int>> body, Encoding encoding, [Request request]);
}

class Input {
  final dynamic body;

  Input(this.body);

  dynamic toJson() => body;

  String toString() {
    return 'Input($body)';
  }
}
