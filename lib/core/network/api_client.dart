import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ajyal/core/config/app_config.dart';
import 'package:ajyal/core/errors/app_errors.dart';
import 'package:http/http.dart' as http;


class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final request = http.Request(method, Uri.parse('${AppConfig.baseUrl}$path'))
      ..headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
        if (token != null) 'Authorization': 'Bearer $token',
      });
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed =
          await _client.send(request).timeout(AppConfig.requestTimeout);
      return _decode(await http.Response.fromStream(streamed));
    } on SocketException {
      throw const AppException(AppErrorType.network, 'err_network');
    } on http.ClientException {
      throw const AppException(AppErrorType.network, 'err_network');
    } on TimeoutException {
      throw const AppException(AppErrorType.timeout, 'err_timeout');
    } on FormatException {
      throw const AppException(AppErrorType.server, 'err_server');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    final code = response.statusCode;
    if (code == 401 || code == 403) {
      throw const AppException(AppErrorType.unauthorized, 'err_unauthorized');
    }
    if (code >= 500) {
      throw const AppException(AppErrorType.server, 'err_server');
    }
    if (code >= 400) {
      throw const AppException(AppErrorType.validation, 'err_invalid_request');
    }
    if (response.bodyBytes.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic>) return decoded;
    throw const AppException(AppErrorType.server, 'err_server');
  }
}