import 'package:dio/dio.dart';

class DioHelper {
  static late Dio dio;
  static getInit() async {
    dio = Dio(
      BaseOptions(
          baseUrl: "https://orikvision.com/backend",
          receiveDataWhenStatusError: false,
          headers: {
            'Content-Type': 'application/json',
          }),
    );
  }

  static Future<Response> postData(
      {required String url, Map<String, dynamic>? data}) async {
    return await dio.post(
      url,
      data: data,
    );
  }

  static Future<Response> getData(
      {required String url, Map<String, dynamic>? queryParameters}) async {
    return await dio.get(
      url,
      queryParameters: queryParameters,
    );
  }

  // static putData({required String url, required query}) async {
  //   return await dio.put(url, queryParameters: query);
  // }

  static Future<Response> delData(
      {required String url, queryParameters, data}) async {
    return await dio.delete(url, data: data);
  }
}
