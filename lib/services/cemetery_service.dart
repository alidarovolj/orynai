import 'api_service.dart';
import '../models/cemetery.dart';
import '../models/grave.dart';

class CemeteryService {
  final ApiService _apiService = ApiService();

  Future<List<Cemetery>> getCemeteries() async {
    try {
      // Используем полный URL для запросов к кладбищам
      final result = await _apiService.get(
        'https://orynai.kz/api/v1/cemeteries',
      );

      if (result is Map<String, dynamic> && result['data'] != null) {
        final List<dynamic> cemeteriesData = result['data'];
        return cemeteriesData.map((json) => Cemetery.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cemeteries: invalid response format');
      }
    } catch (e) {
      if (e is ApiException) {
        throw Exception('Failed to load cemeteries: ${e.message}');
      }
      throw Exception('Error loading cemeteries: $e');
    }
  }

  Future<List<Grave>> getGravesByCoordinates({
    required int cemeteryId,
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
  }) async {
    try {
      // Используем полный URL для запросов к кладбищам
      final result = await _apiService.get(
        'https://orynai.kz/api/v1/graves/by-coordinates',
        queryParameters: {
          'min_x': minX.toString(),
          'max_x': maxX.toString(),
          'min_y': minY.toString(),
          'max_y': maxY.toString(),
          'cemetery_id': cemeteryId.toString(),
        },
      );

      // API возвращает список напрямую
      if (result is List) {
        return result
            .map((json) => Grave.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (result is Map<String, dynamic>) {
        if (result['data'] != null) {
          final List<dynamic> gravesData = result['data'] as List<dynamic>;
          return gravesData
              .map((json) => Grave.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Invalid response format: data field not found');
      } else {
        throw Exception('Invalid response format: expected List or Map');
      }
    } catch (e) {
      if (e is ApiException) {
        throw Exception('Failed to load graves: ${e.message}');
      }
      throw Exception('Error loading graves: $e');
    }
  }
}

