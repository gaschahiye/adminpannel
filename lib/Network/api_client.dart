import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../main.dart';

class ApiClient {
  final http.Client _client;

  ApiClient(this._client);

  // GET request
  Future<http.Response> getRequest(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.get(
      Uri.parse(url),
      headers: _buildHeaders(headers),
    );
    _handleResponse(response);
    return response;
  }

  // POST request using http.Request
  Future<http.Response> postRequest(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final request = http.Request('POST', Uri.parse(url));
    request.headers.addAll(_buildHeaders(headers));
    request.body = jsonEncode(body);
    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    _handleResponse(response);
    return response;
  }

  // PUT request using http.Request
  Future<http.Response> putRequest(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final request = http.Request('PUT', Uri.parse(url));
    request.headers.addAll(_buildHeaders(headers));
    request.body = jsonEncode(body);

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    _handleResponse(response);
    return response;
  }

  // PATCH request using http.Request
  Future<http.Response> patchRequest(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final request = http.Request('PATCH', Uri.parse(url));
    request.headers.addAll(_buildHeaders(headers));
    request.body = jsonEncode(body);

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    _handleResponse(response);
    return response;
  }

  // DELETE request using http.Request
  Future<http.Response> deleteRequest(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final request = http.Request('DELETE', Uri.parse(url));
    request.headers.addAll(_buildHeaders(headers));
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    _handleResponse(response);
    return response;
  }

  // File upload request with http.MultipartRequest
  Future<http.StreamedResponse> uploadFile(
    String url, {
    File? file,
    List<int>? bytes,
    String? filename,
    Map<String, String>? headers,
    Map<String, String>? fields,
    String fileField = 'file',
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(_buildHeaders(headers));
    if (fields != null) request.fields.addAll(fields);

    if (bytes != null && filename != null) {
      request.files.add(
        http.MultipartFile.fromBytes(fileField, bytes, filename: filename),
      );
    } else if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );
    } else {
      throw Exception('Either file or bytes/filename must be provided');
    }

    final response = await _client.send(request);
    await _handleStreamedResponse(response);
    return response;
  }

  // Helper method to build headers with default token and content type
  Map<String, String> _buildHeaders(Map<String, String>? headers) {
    final Map<String, String> baseHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      print(token);
      baseHeaders['Authorization'] = 'Bearer ${token}';
    }

    // Merge any additional headers
    if (headers != null) {
      baseHeaders.addAll(headers);
    }

    return baseHeaders;
  }

  // Handles HTTP errors for regular requests
  void _handleResponse(http.Response response) {
    if (response.statusCode >= 400) {
      var body = jsonDecode(response.body);

      throw Exception("${body['message']}");
    }
  }

  // Handles HTTP errors for streamed (file upload) requests
  Future<void> _handleStreamedResponse(http.StreamedResponse response) async {
    if (response.statusCode >= 400) {
      final error = await response.stream.bytesToString();
      throw Exception("HTTP Error: ${response.statusCode} - $error");
    }
  }

  // Close the client
  void close() {
    _client.close();
  }
}
