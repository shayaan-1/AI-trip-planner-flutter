// Weather Service
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:trip_planner_app/core/constants/api_constants.dart';

import '../models/weather.dart';

class WeatherService {
  static const _apiKey = ApiConstants.weatherApiKey; // Replace with your actual API key

  Future<WeatherForecast> fetchWeatherForecast(String destination, int days) async {
    final url = Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?key=$_apiKey&q=$destination&days=$days&aqi=no&alerts=no'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return WeatherForecast.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load weather forecast');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  List<PackingRecommendation> generatePackingRecommendations(WeatherForecast forecast, int tripDuration) {
    final recommendations = <PackingRecommendation>[];

    // Clothing Recommendations
    final clothingRecommendations = _getClothingRecommendations(forecast);
    recommendations.add(
        PackingRecommendation(
          category: 'Clothing',
          items: clothingRecommendations,
        )
    );

    // Accessory Recommendations
    final accessoryRecommendations = _getAccessoryRecommendations(forecast);
    recommendations.add(
        PackingRecommendation(
          category: 'Accessories',
          items: accessoryRecommendations,
        )
    );

    // Activity-specific Recommendations
    final activityRecommendations = _getActivityRecommendations(forecast);
    recommendations.add(
        PackingRecommendation(
          category: 'Activity Gear',
          items: activityRecommendations,
        )
    );

    return recommendations;
  }

  List<String> _getClothingRecommendations(WeatherForecast forecast) {
    final recommendations = <String>[];
    final avgTemp = forecast.temperature;

    if (avgTemp < 10) {
      recommendations.addAll([
        'Warm winter jacket',
        'Thermal underwear',
        'Sweaters',
        'Thick socks',
        'Gloves',
        'Beanie/winter hat'
      ]);
    } else if (avgTemp < 20) {
      recommendations.addAll([
        'Light jacket',
        'Long-sleeve shirts',
        'Light sweater',
        'Comfortable pants',
      ]);
    } else {
      recommendations.addAll([
        'T-shirts',
        'Shorts',
        'Light, breathable clothing',
        'Sun hat',
      ]);
    }

    return recommendations;
  }

  List<String> _getAccessoryRecommendations(WeatherForecast forecast) {
    final recommendations = <String>[];

    // Always include some basic accessories
    recommendations.addAll([
      'Reusable water bottle',
      'Day bag/backpack',
      'Phone charger',
      'Travel adapter',
    ]);

    // Add weather-specific accessories
    if (forecast.description.toLowerCase().contains('rain')) {
      recommendations.addAll([
        'Compact umbrella',
        'Waterproof jacket',
        'Water-resistant shoes',
      ]);
    } else if (forecast.description.toLowerCase().contains('sun')) {
      recommendations.addAll([
        'Sunglasses',
        'Sunscreen',
        'Sun hat',
      ]);
    }

    return recommendations;
  }

  List<String> _getActivityRecommendations(WeatherForecast forecast) {
    final recommendations = <String>[];

    // Always include some basic activity gear
    recommendations.addAll([
      'Comfortable walking shoes',
      'Portable battery pack',
      'First aid kit',
    ]);

    // Add temperature-based recommendations
    if (forecast.temperature > 20) {
      recommendations.addAll([
        'Swimming gear',
        'Beach towel',
        'Water bottle',
      ]);
    }

    if (forecast.temperature < 10) {
      recommendations.addAll([
        'Hand warmers',
        'Thermos',
        'Extra warm layers',
      ]);
    }

    // Add wind-related recommendations
    if (forecast.windSpeed > 15) {
      recommendations.addAll([
        'Light windbreaker',
        'Windproof layers',
        'Scarf or neck gaiter',
      ]);
    }

    return recommendations;
  }
}