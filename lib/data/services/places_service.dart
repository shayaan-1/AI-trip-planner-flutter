import 'package:dio/dio.dart';
import '../models/place.dart';
import '../../core/constants/api_constants.dart';

class PlacesService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.travelAdvisorBaseUrl,
      connectTimeout: const Duration(seconds: 60),  // Set connection timeout to 60 seconds
      receiveTimeout: const Duration(seconds: 60),  // Set receive timeout to 60 seconds
    ),
  );

  Future<List<Place>> searchPlaces(String query) async {
    try {
      final response = await _dio.get(
        '/locations/v2/auto-complete',
        queryParameters: {'query': query, 'lang': 'en_US', 'units': 'km'},
        options: Options(headers: ApiConstants.rapidApiHeaders),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data == null) {
          throw Exception('Response data is null');
        }

        final typeaheadData = data['data']?['Typeahead_autocomplete'];
        if (typeaheadData == null) {
          throw Exception('Typeahead_autocomplete data is null');
        }

        final results = typeaheadData['results'];
        if (results == null) {
          throw Exception('Results are null');
        }

        List<Place> places = [];
        for (var item in results) {
          try {
            Place place = Place.fromJson(item);

            // Skip invalid places with 'Unknown Place' name
            if (place.name == 'Unknown Place' || place.description.isEmpty) {
              continue;  // Skip this place
            }

            places.add(place);
          } catch (e) {
            print('Error parsing individual place: $e');
          }
        }

        return places;
      } else {
        throw Exception('Failed to load places. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Detailed error: $e');
      rethrow;
    }
  }
}