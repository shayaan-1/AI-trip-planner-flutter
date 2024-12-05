import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/trip.dart';
import '../../core/constants/api_constants.dart';

/// Service for generating trip plans using Gemini AI API
class GeminiService {
  final Dio _dio;

  GeminiService({Dio? dio}) : _dio = dio ?? Dio();

  /// Generates a trip plan using Gemini AI API
  Future<Trip> generateTripPlan({
    required String destination,
    required String travelGroup,
    required String budget,
    required int numberOfDays,
  }) async {
    final prompt = _constructTripPlanPrompt(
      destination: destination,
      travelGroup: travelGroup,
      budget: budget,
      numberOfDays: numberOfDays,
    );

    try {
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${ApiConstants.geminiApiKey}',
        data: _prepareRequestPayload(prompt),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      // print("Response: " + response.toString());

      return _processTripPlanResponse(response, destination, travelGroup, budget, numberOfDays);
    } on DioException catch (e) {
      throw TripGenerationException('Network error: ${e.message}');
    } catch (e) {
      throw TripGenerationException('Unexpected error: $e');
    }
  }

  /// Constructs the API prompt for trip plan generation
  String _constructTripPlanPrompt({
    required String destination,
    required String travelGroup,
    required String budget,
    required int numberOfDays,
  }) {
    return '''
    Generate a personalized trip plan for a travel group visiting a destination. The following parameters should be considered:

Destination: $destination
Travel Group: $travelGroup
Budget: $budget
Number of Days: $numberOfDays
Please provide a trip plan that includes the following:

Trip Overview:

The destination is $destination.
The travel group is $travelGroup.
The budget is $budget.
The trip duration is $numberOfDays days.
Daily Itinerary: Provide a detailed day-by-day itinerary for the specified number of days (numberOfDays). Each day should include:

The day number (from 1 to numberOfDays).
A list of activities, with each activity containing:
Name of the activity.
Description of the activity.
Estimated price.
Duration of the activity.
If applicable, provide a ticket URL and the time of the activity.
Hotels: List 3-5 hotels in New York City that fit the moderate budget range (600-1500 per night). For each hotel, provide:

Name
Address
Price range per night
Rating (out of 5)
Website URL
Key amenities (Wi-Fi, breakfast, pool, fitness center, etc.)
Restaurants: List 3-5 restaurants with moderate pricing (within 30-50 per person). For each restaurant, provide:

Name
Address
Price range
Rating (out of 5)
Website URL
Return the response in JSON format, following the model structure below, with the fields destination, travelGroup, budget, numberOfDays, dailyItineraries, hotels, and restaurants.
Return the response STRICTLY in this JSON format with NO EMPTY FIELDS:
{
  "destination": "$destination",
  "travelGroup": "$travelGroup",
  "budget": "$budget",
  "numberOfDays": $numberOfDays,
  "dailyItineraries": [
    {
      "day": 1,
      "activities": [
        {
          "name": "Central Park Walking Tour",
          "description": "A scenic walking tour through Central Park, taking in the most famous landmarks.",
          "price": 50.0,
          "duration": "2 hours",
          "ticketUrl": "https://example.com/tickets/central-park-tour",
          "time": "10:00 AM"
        },
        {
          "name": "Central Park Walking Tour",
          "description": "A scenic walking tour through Central Park, taking in the most famous landmarks.",
          "price": 50.0,
          "duration": "2 hours",
          "ticketUrl": "https://example.com/tickets/central-park-tour",
          "time": "10:00 AM"
        }
      ]
    },
    {
      "day": 2,
      "activities": [
        {
          "name": "Empire State Building Visit",
          "description": "Visit the iconic Empire State Building with breathtaking views of New York City.",
          "price": 30.0,
          "duration": "1.5 hours",
          "ticketUrl": "https://example.com/tickets/empire-state-building",
          "time": "11:00 AM"
        },
        {
          "name": "Central Park Walking Tour",
          "description": "A scenic walking tour through Central Park, taking in the most famous landmarks.",
          "price": 50.0,
          "duration": "2 hours",
          "ticketUrl": "https://example.com/tickets/central-park-tour",
          "time": "10:00 AM"
        }
      ]
    },
    {
      "day": 3,
      "activities": [
        {
          "name": "Museum of Modern Art",
          "description": "Explore world-renowned art collections at the Museum of Modern Art.",
          "price": 25.0,
          "duration": "3 hours",
          "ticketUrl": "https://example.com/tickets/moma",
          "time": "9:00 AM"
        }
      ]
    }
  ],
  "hotels": [
    {
      "name": "The Ritz-Carlton New York, Central Park",
      "address": "50 Central Park South, New York, NY 10019",
      "priceRange": "800-1500 per night",
      "rating": "4.8/5",
      "websiteUrl": "https://www.ritzcarlton.com/en/hotels/new-york-central-park"
    },
    {
      "name": "The Peninsula New York",
      "address": "700 Fifth Ave, New York, NY 10019",
      "priceRange": "700-1200 per night",
      "rating": "4.7/5",
      "websiteUrl": "https://www.peninsula.com/en/new-york"
    }
  ],
  "restaurants": [
    {
      "name": "The River Café",
      "address": "1 Water St, Brooklyn, NY 11201",
      "priceRange": "40-60 per person",
      "rating": "4.5/5",
      "websiteUrl": "https://www.rivercafe.com"
    },
    {
      "name": "Le Bernardin",
      "address": "155 W 51st St, New York, NY 10019",
      "priceRange": "50-70 per person",
      "rating": "4.7/5",
      "websiteUrl": "https://www.le-bernardin.com"
    }
  ]
}


''';
  }

  /// Prepares the request payload for the API
  Map<String, dynamic> _prepareRequestPayload(String prompt) {
    return {
      'contents': [
        {
          'parts': [{'text': prompt}],
          'role': 'user'
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 8192,
        'responseMimeType': 'application/json'
      },
    };
  }

  /// Processes the API response and parses it into a [Trip] object
  Trip _processTripPlanResponse(
      Response response,
      String destination,
      String travelGroup,
      String budget,
      int numberOfDays,
      ) {
    if (response.statusCode != 200 || response.data == null) {
      throw TripGenerationException('Invalid API response');
    }

    final data = response.data;
    final candidates = (data['candidates'] as List?) ?? [];
    if (candidates.isEmpty) {
      throw TripGenerationException('No trip plan candidates found');
    }

    final content = candidates[0]['content']?['parts']?[0]?['text'] ?? '';
    return _parseTripPlanContent(content, destination, travelGroup, budget, numberOfDays);
  }

  /// Parses JSON content into a [Trip] object
  Trip _parseTripPlanContent(
      String content,
      String destination,
      String travelGroup,
      String budget,
      int numberOfDays,
      ) {
    try {
      final cleanedContent = content.replaceAll('```json', '').replaceAll('```', '').trim();
      final jsonData = jsonDecode(cleanedContent);

      _validateJsonStructure(jsonData);
      //print(jsonData.toString());

      return Trip(
        id: DateTime.now().toIso8601String(),
        destination: destination,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: numberOfDays)),
        travelGroup: travelGroup,
        budget: budget,
        dayPlans: (jsonData['dailyItineraries'] as List<dynamic>)
            .map((e) => DayPlan.fromJson(e))
            .toList(),
        hotels: (jsonData['hotels'] as List<dynamic>)
            .map((e) => Hotel.fromJson(e))
            .toList(),
        restaurants: (jsonData['restaurants'] as List<dynamic>)
            .map((e) => Restaurant.fromJson(e))
            .toList(),
      );
    } catch (e) {
      throw TripGenerationException('Failed to parse trip plan: $e');
    }
  }

  /// Validates the structure of the JSON response
  void _validateJsonStructure(Map<String, dynamic> jsonData) {
    if (!jsonData.containsKey('dailyItineraries') ||
        !jsonData.containsKey('hotels') ||
        !jsonData.containsKey('restaurants')) {
      throw TripGenerationException('Invalid JSON structure');
    }
  }
}

/// Exception for handling trip generation errors
class TripGenerationException implements Exception {
  final String message;

  TripGenerationException(this.message);

  @override
  String toString() => 'TripGenerationException: $message';
}
