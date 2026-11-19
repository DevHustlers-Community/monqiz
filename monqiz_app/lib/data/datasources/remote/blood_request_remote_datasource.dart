import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../domain/entities/enums.dart';
import '../../models/blood_request_model.dart';
import '../../models/request_acceptance_model.dart';
import '../blood_request_datasource.dart';

class BloodRequestRemoteDataSource implements BloodRequestDataSource {
  final DioClient dioClient;

  BloodRequestRemoteDataSource({required this.dioClient});

  @override
  Future<List<BloodRequestModel>> getUrgentRequests({
    BloodType? bloodType,
    String? governorate,
    String? city,
    int page = 1,
  }) async {
    final Map<String, dynamic> query = {
      'pageIndex': page,
    };
    if (bloodType != null && bloodType != BloodType.unknown) {
      query['bloodType'] = bloodType.toBackendString();
    }
    if (governorate != null && governorate.isNotEmpty && governorate != 'الكل') {
      query['governorate'] = governorate;
    }
    if (city != null && city.isNotEmpty && city != 'الكل') {
      query['city'] = city;
    }

    final response = await dioClient.dio.get(
      ApiEndpoints.requests,
      queryParameters: query,
    );

    final rawData = response.data;
    List<dynamic> items = [];

    if (rawData is Map<String, dynamic>) {
      if (rawData['dates'] is List) {
        items = rawData['dates'] as List;
      } else if (rawData['data'] is Map && rawData['data']['dates'] is List) {
        items = rawData['data']['dates'] as List;
      } else if (rawData['data'] is List) {
        items = rawData['data'] as List;
      }
    } else if (rawData is List) {
      items = rawData;
    }

    return items
        .map((item) => BloodRequestModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BloodRequestModel> getRequestById(String id) async {
    final response = await dioClient.dio.get(ApiEndpoints.requestById(id));
    final data = response.data;
    final item = data is Map<String, dynamic> && data['data'] != null
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return BloodRequestModel.fromJson(item);
  }

  @override
  Future<RequestAcceptanceModel> pledgeDonation({required String requestId}) async {
    final response = await dioClient.dio.post(ApiEndpoints.acceptRequest(requestId));
    final data = response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : {};
    return RequestAcceptanceModel(
      userId: data['userId']?.toString() ?? '',
      requestId: requestId,
      acceptanceStatus: DonationStatus.accepted,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<RequestAcceptanceModel>> getMyDonationHistory() async {
    final response = await dioClient.dio.get(ApiEndpoints.myDonations);
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map && data['data'] is List) {
      list = data['data'] as List;
    } else if (data is List) {
      list = data;
    }
    return list
        .map((e) => RequestAcceptanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BloodRequestModel> createEmergencyRequest({
    required String hospitalId,
    required BloodType bloodType,
    required int unitsNeeded,
    DateTime? requiredDate,
    String? details,
    required String roomInfo,
    required String category,
  }) async {
    final response = await dioClient.dio.post(
      '/requests',
      data: {
        'hospitalId': hospitalId,
        'bloodType': bloodType.toBackendInt(),
        'unitsNeeded': unitsNeeded,
        'requiredDate': requiredDate?.toIso8601String(),
        'details': details ?? '',
      },
    );
    final data = response.data;
    final item = data is Map<String, dynamic> && data['data'] != null
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return BloodRequestModel.fromJson(item);
  }
}
