// /// This class provides methods for making API requests using Dio.
// /// It includes methods for performing HTTP POST, PUT, and GET requests.
// library;

// 
// import '../../constants/linkapi.dart';

// class ApiService {
//   final Dio _dio;
//   ApiService(this._dio);

//   Future<Map<String, dynamic>> post(
//       {required String url, required Map<String, dynamic> data}) async {
//     var response = await _dio
//         .post(
//           "${AppLink.server}$url",
//           data: data,
//         )
//         .timeout(const Duration(minutes: 1));

//     return response.data;
//   }

//   Future<Map<String, dynamic>> postWithToken(
//       {required String url,
//       required Map<String, dynamic> data,
//       required String accessToken}) async {
//     var response = await _dio
//         .post(
//           "${AppLink.server}$url",
//           data: data,
//           options: Options(headers: {'Authorization': 'Token $accessToken'}),
//         )
//         .timeout(const Duration(minutes: 1));

//     return response.data;
//   }

//   Future<Map<String, dynamic>> put(
//       {required String url,
//       required Map<String, dynamic> data,
//       required String accessToken}) async {
//     var response = await _dio
//         .put(
//           "${AppLink.server}$url",
//           options: Options(headers: {'Authorization': 'Token $accessToken'}),
//           data: data,
//         )
//         .timeout(const Duration(minutes: 1));
//     return response.data;
//   }

//   Future<Map<String, dynamic>> put2(
//       {required String url,
//       required FormData data,
//       required String accessToken}) async {
//     var response = await _dio.put(
//       "${AppLink.server}$url",
//       options: Options(headers: {'Authorization': 'Token $accessToken'}),
//       data: data,
//     );

//     return response.data;
//   }

//   Future<Map<String, dynamic>> postFormData(
//       {required String url,
//       required FormData data,
//       required String accessToken}) async {
//     var response = await _dio.post(
//       "${AppLink.server}$url",
//       options: Options(headers: {'Authorization': 'Token $accessToken'}),
//       data: data,
//     );
//     return response.data;
//   }

//   Future<Map<String, dynamic>> putFormData(
//       {required String url,
//       required FormData data,
//       required String accessToken}) async {
//     var response = await _dio.patch(
//       "${AppLink.server}$url",
//       options: Options(headers: {'Authorization': 'Token $accessToken'}),
//       data: data,
//     );
//     return response.data;
//   }

//   Future<Map<String, dynamic>> patch(
//       {required String url,
//       required Map<String, dynamic> data,
//       required String accessToken}) async {
//     var response = await _dio.patch(
//       "${AppLink.server}$url",
//       options: Options(headers: {'Authorization': 'Token $accessToken'}),
//       data: data,
//     );
//     return response.data;
//   }

//   Future<Map<String, dynamic>> get(
//       {required String url, required String accessToken}) async {
//     var response = await _dio
//         .get("${AppLink.server}$url",
//             options: Options(headers: {'Authorization': 'Token $accessToken'}))
//         .timeout(const Duration(minutes: 1));
//     return response.data;
//   }

//   Future<Map<String, dynamic>> getWithoutToten({required String url}) async {
//     var response = await _dio
//         .get(
//           "${AppLink.server}$url",
//         )
//         .timeout(const Duration(minutes: 1));
//     return response.data;
//   }

//   Future<Response> get2(
//       {required String url, required String accessToken}) async {
//     var response = await _dio
//         .get("${AppLink.server}$url",
//             options: Options(headers: {'Authorization': 'Token $accessToken'}))
//         .timeout(const Duration(minutes: 1));
//     return response;
//   }

//   Future<Map<String, dynamic>> get1(
//       {required String url, required String accessToken}) async {
//     var response = await _dio
//         .get("${AppLink.server}$url",
//             options: Options(headers: {'Authorization': 'Token $accessToken'}))
//         .timeout(const Duration(minutes: 1));
//     return {"data": response.data};
//   }

//   Future<int> getEmailReceipt(
//       {required String url,
//       required String accessToken,
//       required Map<String, dynamic> data}) async {
//     var response = await _dio.post("${AppLink.server}$url",
//         data: data,
//         options: Options(headers: {'Authorization': 'Token $accessToken'}));
//     return response.statusCode!;
//   }

//   Future<Response> getOutlookReceipt(
//       {required String url,
//       required String accessToken,
//       required Map<String, dynamic> data}) async {
//     var response = await _dio.post("${AppLink.server}$url",
//         data: data,
//         options: Options(headers: {'Authorization': 'Token $accessToken'}));
//     return response;
//   }

//   Future<Map<String, dynamic>> getReceiptJson({
//     required String url,
//   }) async {
//     var response = await _dio.get(
//       url,
//     );
//     return response.data;
//   }

//   Future<int?> delete(
//       {required String url,
//       required String accessToken,
//       Map<String, dynamic>? data}) async {
//     var response = await _dio
//         .delete("${AppLink.server}$url",
//             options: Options(headers: {'Authorization': 'Token $accessToken'}),
//             data: data)
//         .timeout(const Duration(minutes: 1));
//     return response.statusCode;
//   }

//   Future<int?> deleteMyAccount({
//     required String url,
//     required String accessToken,
//   }) async {
//     var response = await _dio
//         .delete(
//           "${AppLink.server}$url",
//           options: Options(headers: {'Authorization': 'Token $accessToken'}),
//         )
//         .timeout(const Duration(minutes: 1));
//     return response.statusCode;
//   }
// }
