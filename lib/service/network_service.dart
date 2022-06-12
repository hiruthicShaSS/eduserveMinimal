// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:http/http.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/exceptions.dart';

class NetworkService {
  late Client client;

  NetworkService({Client? client}) {
    this.client = client ?? Client();
  }

  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    try {
      return await client.get(url, headers: headers);
    } on SocketException catch (e) {
      throw NetworkException(e.message, e);
    } on ClientException catch (e) {
      throw NetworkException(e.message, e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    try {
      return await client.post(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      );
    } on SocketException catch (e) {
      throw NetworkException(e.message, e);
    } on ClientException catch (e) {
      throw NetworkException(e.message, e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
