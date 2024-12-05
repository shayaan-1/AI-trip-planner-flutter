// lib/core/constants/api_constants.dart
class ApiConstants {
  // Google Places API constants
  static const String travelAdvisorBaseUrl  =
      'https://travel-advisor.p.rapidapi.com';
  static const String rapidApiKey = 'c5ec2f23e1msh8fe95556653f5bfp19439ajsn2736927743f9';
  static const Map<String, String> rapidApiHeaders = {
    'X-RapidAPI-Key': rapidApiKey,
    'X-RapidAPI-Host': 'travel-advisor.p.rapidapi.com',
  };

  // Gemini API constants
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com';
  static const String geminiApiKey = 'AIzaSyAAlNlRo-b8RGK2u9ZXGE9nckMCz97ZKfk';

  static const String unsplashAccessKey = "vB254PBWzW3aBF9IXPhUJk252i0osZy7pmWe4K7Tjg4";
  static const String unsplashSecretKey = "9mZGqGFABYOrvfhb9ZOJ--_rLHHdT8sEozYZBexUaiA";

  static const weatherApiKey = "553a0ae307364313afd70541243011";
}
