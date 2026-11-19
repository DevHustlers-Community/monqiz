import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../models/address_model.dart';

class AddressRemoteDataSource {
  final DioClient dioClient;

  AddressRemoteDataSource({required this.dioClient});

  Future<List<String>> getGovernorates() async {
    final response = await dioClient.dio.get(ApiEndpoints.addressGovernorates);
    final data = response.data;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    } else if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => e.toString()).toList();
    }
    return [
      'القاهرة',
      'الجيزة',
      'الإسكندرية',
      'الدقهلية',
      'الغربية',
      'القليوبية',
      'الشرقية',
      'أسيوط',
      'سوهاج',
    ];
  }

  Future<List<String>> getCities(String governorate) async {
    final response = await dioClient.dio.get(ApiEndpoints.addressCities(governorate));
    final data = response.data;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    } else if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<List<AddressModel>> getAllAddresses({String? governorate, String? city}) async {
    final Map<String, dynamic> query = {};
    if (governorate != null && governorate.isNotEmpty && governorate != 'الكل') {
      query['governorate'] = governorate;
    }
    if (city != null && city.isNotEmpty && city != 'الكل') {
      query['city'] = city;
    }

    final response = await dioClient.dio.get(
      ApiEndpoints.addresses,
      queryParameters: query,
    );

    final data = response.data;
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map && data['data'] is List) {
      list = data['data'] as List;
    } else {
      list = [];
    }

    return list.map((a) => AddressModel.fromJson(a as Map<String, dynamic>)).toList();
  }
}
