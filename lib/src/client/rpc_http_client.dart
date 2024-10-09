import 'dart:async';
import 'dart:convert';
import 'package:alchemy_web3/alchemy_web3.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class RpcHttpClient with AlchemyConsoleMixin {
  // PROPERTIES
  String url;
  double jsonRPCVersion;
  bool verbose;
  Duration receiveTimeout;
  Duration sendTimeout;

  // CONSTRUCTOR
  RpcHttpClient({
    this.url = '',
    this.jsonRPCVersion = 2.0,
    this.receiveTimeout = const Duration(seconds: 10),
    this.sendTimeout = const Duration(seconds: 10),
    this.verbose = false,
  });

  static int _requestId = 0;

  // GETTERS

  // VARIABLES
  final _dio = Dio();

  // FUNCTIONS
  void init({
    required String url,
    double? jsonRPCVersion,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? verbose,
  }) {
    this.url = url;
    this.jsonRPCVersion = jsonRPCVersion ?? this.jsonRPCVersion;
    this.sendTimeout = sendTimeout ?? this.sendTimeout;
    this.receiveTimeout = receiveTimeout ?? this.receiveTimeout;
    this.verbose = verbose ?? this.verbose;
    _dio.options.baseUrl = url;
  }

  Future<Either> batchRequest({
    List<Map<String, dynamic>> requests = const [],
  }) async {
    if (url.isEmpty) throw 'Client URL is empty';

    var batchRequests = requests.map(_buildRpcRequest).toList();

    return await _makePostRequest(
      bodyData: batchRequests,
      requestType: 'Batch Requesting',
    );
  }

  Future<Either> request({
    Map<String, dynamic>? queryParameters,
    String endpoint = '',
    HTTPMethod method = HTTPMethod.post,
    List<dynamic> bodyParameters = const [],
  }) async {
    if (url.isEmpty) throw 'Client URL is empty';

    var bodyData = _buildRpcRequest({
      'method': endpoint,
      'params': bodyParameters,
    });

    if (method == HTTPMethod.post) {
      return await _makePostRequest(
        bodyData: [bodyData],
        queryParameters: _sanitizeQueryParams(queryParameters),
        endpoint: endpoint,
        requestType: 'Requesting',
      );
    } else {
      return await _makeGetRequest(
        queryParameters: _sanitizeQueryParams(queryParameters),
        endpoint: endpoint,
        requestType: 'GET Requesting',
      );
    }
  }

  // HELPER FUNCTIONS

  // Builds the standard JSON-RPC request body
  Map<String, dynamic> _buildRpcRequest(Map<String, dynamic> request) {
    return {
      'method': request['method'],
      'params': request['params'] ?? [],
      'jsonrpc': jsonRPCVersion.toString(),
      'id': _requestId = _requestId + 1,
    };
  }

  // Sanitizes query parameters by removing null values
  Map<String, dynamic> _sanitizeQueryParams(Map<String, dynamic>? queryParameters) {
    var updatedParametersMap = Map<String, dynamic>.from(queryParameters ?? {});
    updatedParametersMap.removeWhere((key, value) => value == null);

    // Convert arrays for query parameters
    if (updatedParametersMap['filters'] != null && queryParameters?['filters'] is List) {
      updatedParametersMap['filters[]'] = List.filled(updatedParametersMap['filters'].length, '');
      for (int i = 0; i < updatedParametersMap['filters'].length; i++) {
        updatedParametersMap['filters[]'][i] = updatedParametersMap['filters'][i]?.toString().split('.').last;
      }
    }
    updatedParametersMap.remove('filters');
    return updatedParametersMap;
  }

  // Handles POST requests (including batch requests)
  Future<Either<dynamic, dynamic>> _makePostRequest({
    required List<Map<String, dynamic>> bodyData,
    Map<String, dynamic>? queryParameters,
    String? endpoint,
    required String requestType,
  }) async {
    if (verbose) {
      console.trace('$requestType... POST: $url, method: $endpoint, body: \n$bodyData');
    }

    try {
      var response = await _dio.post<String>(
        url,
        queryParameters: queryParameters,
        data: jsonEncode(bodyData),
        options: Options(
          receiveTimeout: receiveTimeout,
          sendTimeout: sendTimeout,
          responseType: ResponseType.plain,
        ),
      );

      if (verbose) {
        console.debug('${response.statusCode} : ${response.realUri}\n${response.data}');
      }

      return Right(jsonDecode(response.data!));
    } on DioException catch (e) {
      if (verbose) {
        console.error('${e.type}! ${e.response?.statusCode} : ${e.response?.realUri}\n${e.response?.data}');
      }

      return Left(
        bodyData.map((request) {
          return RpcResponse(
            id: request['id'] ?? 0,
            jsonrpc: jsonRPCVersion.toString(),
            error: RPCError(
              code: e.response?.statusCode ?? 0,
              message: e.response?.data ?? e.message,
            ),
          );
        }).toList(),
      );
    }
  }

  // Handles GET requests
  Future<Either<RpcResponse, dynamic>> _makeGetRequest({
    required Map<String, dynamic> queryParameters,
    String? endpoint,
    required String requestType,
  }) async {
    if (verbose) {
      console.trace('$requestType... GET: $url, queryParameters: \n$queryParameters');
    }

    try {
      var response = await _dio.get<String>(
        '/$endpoint',
        queryParameters: queryParameters,
        options: Options(
          receiveTimeout: receiveTimeout,
          sendTimeout: sendTimeout,
          responseType: ResponseType.plain,
        ),
      );

      if (verbose) {
        console.debug('${response.statusCode} : ${response.realUri}\n${response.data}');
      }

      return Right(jsonDecode(response.data!));
    } on DioException catch (e) {
      if (verbose) {
        console.error('${e.type}! ${e.response?.statusCode} : ${e.response?.realUri}\n${e.response?.data}');
      }

      return Left(
        RpcResponse(
          id: 0,
          jsonrpc: jsonRPCVersion.toString(),
          error: RPCError(
            code: e.response?.statusCode ?? 0,
            message: e.response?.data ?? e.message,
          ),
        ),
      );
    }
  }
}

enum HTTPMethod {
  get,
  post,
}
