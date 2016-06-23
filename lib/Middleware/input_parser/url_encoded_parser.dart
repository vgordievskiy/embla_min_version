library tradem_srv.middleware.input_parser.url_encoded_parser;
import 'dart:convert';
import 'dart:async';
import 'dart:io' show ContentType, HttpHeaders;
import 'package:embla/http.dart';

import 'input_parser.dart';
import 'raw_parser.dart';

class UrlEncodedInputParser extends InputParser {
  final RawInputParser _raw = new RawInputParser();

  @override
  String get mimeType => 'application/x-www-form-urlencoded';

  Future<Map<String, String>> parse(Stream<List<int>> body, Encoding encoding,
                                    [Request request]) async
  {
    final value = await body.map(encoding.decode).join('\n');
    return parseQueryString(value);
  }

  // This is absolutely horrendous, but works
  Map<String, String> parseQueryString(String query) {
    _verifyQueryString(query);

    final parts = query.split('&');
    final Iterable<String> rawKeys = parts.map((s) => s.split('=').map(Uri.decodeComponent).first);
    final List<String> values = parts.map((s) => s.split('=').map(Uri.decodeComponent).last).toList();
    final map = {};
    final rootNamePattern = new RegExp(r'^([^\[]+)(.*)$');
    final contPattern = new RegExp(r'^\[(.*?)\](.*)$');
    dynamic nextValue() {
      return _raw.parseString(values.removeAt(0));
    }
    for (var restOfKey in rawKeys) {
      final rootMatch = rootNamePattern.firstMatch(restOfKey);
      final rootKey = rootMatch[1];
      final rootCont = rootMatch[2];
      if (rootCont == '') {
        map[rootKey] = nextValue();
        continue;
      }
      dynamic target = map;
      dynamic targetKey = rootKey;

      restOfKey = rootCont;

      while (contPattern.hasMatch(restOfKey)) {
        final contMatch = contPattern.firstMatch(restOfKey);
        final keyName = contMatch[1];
        if (keyName == '') {
          target[targetKey] ??= [];
          (target[targetKey] as List).add(null);
          target = target[targetKey];
          targetKey = target.length - 1;
        } else if (new RegExp(r'^\d+$').hasMatch(keyName)) {
          final List targetList = target[targetKey] ??= [];
          final index = int.parse(keyName);
          if (targetList.length == index) {
            targetList.add(null);
          } else {
            targetList[index] ??= null;
          }
          target = targetList;
          targetKey = index;
        } else {
          target[targetKey] ??= {};
          (target[targetKey] as Map)[keyName] ??= null;
          target = target[targetKey];
          targetKey = keyName;
        }
        restOfKey = contMatch[2];
      }
      target[targetKey] = nextValue();
    }
    return new Map.unmodifiable(map);
  }

  void _verifyQueryString(String query) {
    final pattern = new RegExp(r'^(?:[^\[]+(?:\[[^\[\]]*\])*(?:\=.*?)?)$');
    if (!pattern.hasMatch(query)) {
      throw new Exception('$query is not a valid query string');
    }
  }
}
