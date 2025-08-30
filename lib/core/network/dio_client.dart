import 'package:dio/dio.dart';

Dio createDioClient() {
  final BaseOptions baseOptions = BaseOptions(
    baseUrl: 'https://dummyjson.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    headers: <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  final Dio dio = Dio(baseOptions);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        options.extra['__startTime'] = DateTime.now();
        // Log request
        // ignore: avoid_print
        print('[API] → ${options.method} ${options.baseUrl}${options.path} params=${options.queryParameters}');
        handler.next(options);
      },
      onResponse: (Response<dynamic> response, ResponseInterceptorHandler handler) {
        final DateTime? start = response.requestOptions.extra['__startTime'] as DateTime?;
        final int ms = start != null ? DateTime.now().difference(start).inMilliseconds : -1;
        // ignore: avoid_print
        print('[API] ← ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri} (${ms}ms)');
        handler.next(response);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) {
        final DateTime? start = error.requestOptions.extra['__startTime'] as DateTime?;
        final int ms = start != null ? DateTime.now().difference(start).inMilliseconds : -1;
        // ignore: avoid_print
        print('[API] ⇤ ERROR ${error.response?.statusCode ?? ''} ${error.requestOptions.method} ${error.requestOptions.uri} (${ms}ms) message=${error.message}');
        handler.next(error);
      },
    ),
  );

  return dio;
}
