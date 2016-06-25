library tradem_srv.middleware.input_parser.url_encoded_parser;
import 'dart:convert';
import 'dart:async';
import 'dart:io' show ContentType, HttpHeaders;
import 'package:embla/http.dart';
import 'package:http_server/src/http_body_impl.dart';
import 'package:http_server/src/http_body.dart';

import 'input_parser.dart';

class UrlEncodedInputParser extends InputParser {
  @override
  Future parse(Stream<List<int>> body, Encoding encoding, [Request request]) async {
    HttpBody parsedBody = await HttpBodyHandlerImpl.process(body,
      new _HttpHeaders(request.headers,
        ContentType.parse(request.headers['content-type'])), UTF8);
    return parsedBody.body;
  }

  @override
  String get mimeType => 'application/x-www-form-urlencoded';
}

class _HttpHeaders implements HttpHeaders {
  final Map<String, String> headers;
  ContentType _contentType;

  _HttpHeaders(this.headers, this._contentType);

  @override
  List<String> operator [](String name) {
    return headers[name].split(";");
  }

  @override
  ContentType get contentType => _contentType;

  @override
  void forEach(void f(String name, List<String> values)) {
    headers.forEach((k, v) => f(k, v.split(";")));
  }

  @override
  String value(String name) {
    return headers[name];
  }

  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
