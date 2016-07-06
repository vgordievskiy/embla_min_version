library srv_base.middleware.input_parser.json_parser;
import 'dart:convert';
import 'dart:async';
import 'dart:io' show ContentType, HttpHeaders;
import 'package:embla/http.dart';

import 'input_parser.dart';

class JsonInputParser extends InputParser {
  Future parse(Stream<List<int>> body, Encoding encoding, [Request request]) async {
    final asString = await body.map(encoding.decode).join('\n');
    final output = JSON.decode(asString);
    if (output is Map<String, dynamic>) {
      return new Map.unmodifiable(output);
    } else if (output is Iterable) {
      return new List.unmodifiable(output);
    }
    return output;
  }

  @override
  String get mimeType => 'application/json';
}
