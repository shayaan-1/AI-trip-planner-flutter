import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trip_planner_app/data/models/weather.dart';

class Trip {
  final String id;
  String? cityImageUrl;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String travelGroup;
  final String budget;
  final List<DayPlan> dayPlans;
  final List<Hotel> hotels;
  final List<Restaurant> restaurants;
  final WeatherForecast? weatherForecast; // New property

  Trip({
    this.cityImageUrl,
    required this.id,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.travelGroup,
    required this.budget,
    this.dayPlans = const [],
    this.hotels = const [],
    this.restaurants = const [],
    this.weatherForecast,
  });

  /// Deserialize from JSON
  factory Trip.fromJson(Map<String, dynamic> json) {
    try {
      return Trip(
        id: json['id'] ?? DateTime.now().toString(),
        cityImageUrl: json['cityImageUrl'],
        destination: json['destination'] ?? 'Unknown Destination',
        startDate: _parseDate(json['startDate'], DateTime.now()),
        endDate: _parseDate(json['endDate'], DateTime.now().add(Duration(days: 3))),
        travelGroup: json['travelGroup'] ?? 'Group Travel',
        budget: json['budget'] ?? '\$0',
        dayPlans: _parseDayPlans(json['dailyItineraries']),
        hotels: _parseHotels(json['hotels']),
        restaurants: _parseRestaurants(json['restaurants']),
        weatherForecast: _parseWeatherForecast(json['weatherForecast']),
      );
    } catch (e) {
      print('Error parsing trip: $e');
      print('Problematic JSON: $json');
      return Trip(
        id: DateTime.now().toString(),
        destination: 'Travel Destination',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 3)),
        travelGroup: 'Friends',
        budget: '\$500',
      );
    }
  }

// Helper method to parse dates safely
  static DateTime _parseDate(dynamic dateValue, DateTime defaultDate) {
    if (dateValue == null) return defaultDate;

    if (dateValue is Timestamp) {
      return dateValue.toDate();
    }

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return defaultDate;
      }
    }

    return defaultDate;
  }

// Helper method to parse day plans safely
  static List<DayPlan> _parseDayPlans(dynamic dailyItineraries) {
    try {
      return dailyItineraries != null
          ? (dailyItineraries as List)
          .map<DayPlan>((e) => DayPlan.fromJson(e as Map<String, dynamic>))
          .toList()
          : [];
    } catch (e) {
      print('Error parsing day plans: $e');
      return [];
    }
  }

// Helper method to parse hotels safely
  static List<Hotel> _parseHotels(dynamic hotelsData) {
    try {
      return hotelsData != null
          ? (hotelsData as List)
          .map<Hotel>((e) => Hotel.fromJson(e as Map<String, dynamic>))
          .toList()
          : [];
    } catch (e) {
      print('Error parsing hotels: $e');
      return [];
    }
  }

// Helper method to parse restaurants safely
  static List<Restaurant> _parseRestaurants(dynamic restaurantsData) {
    try {
      return restaurantsData != null
          ? (restaurantsData as List)
          .map<Restaurant>((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList()
          : [];
    } catch (e) {
      print('Error parsing restaurants: $e');
      return [];
    }
  }

// Helper method to parse weather forecast safely
  static WeatherForecast? _parseWeatherForecast(dynamic weatherData) {
    try {
      if (weatherData == null) return null;

      // If weatherData is already a Map, pass it directly
      if (weatherData is Map<String, dynamic>) {
        return WeatherForecast.fromJson(weatherData);
      }

      // If it's a string, try to parse it
      if (weatherData is String) {
        return WeatherForecast.fromJson(json.decode(weatherData));
      }

      return null;
    } catch (e) {
      print('Error parsing weather forecast: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityImageUrl': cityImageUrl,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'travelGroup': travelGroup,
      'budget': budget,
      'dailyItineraries': dayPlans.map((e) => e.toJson()).toList(),
      'hotels': hotels.map((e) => e.toJson()).toList(),
      'restaurants': restaurants.map((e) => e.toJson()).toList(),
      'weatherForecast': weatherForecast?.toJson(), // Serialize weather
    };
  }

  /// Copy with updated properties
  Trip copyWith({
    String? cityImageUrl,
    String? id,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? travelGroup,
    String? budget,
    List<DayPlan>? dayPlans,
    List<Hotel>? hotels,
    List<Restaurant>? restaurants,
    WeatherForecast? weatherForecast,
  }) {
    return Trip(
      cityImageUrl: cityImageUrl ?? this.cityImageUrl,
      id: id ?? this.id,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      travelGroup: travelGroup ?? this.travelGroup,
      budget: budget ?? this.budget,
      dayPlans: dayPlans ?? this.dayPlans,
      hotels: hotels ?? this.hotels,
      restaurants: restaurants ?? this.restaurants,
      weatherForecast: weatherForecast ?? this.weatherForecast,
    );
  }

  @override
  String toString() {
    return 'Trip(id: $id, cityImageUrl: $cityImageUrl, destination: $destination, startDate: $startDate, endDate: $endDate, travelGroup: $travelGroup, budget: $budget, dayPlans: $dayPlans, hotels: $hotels, restaurants: $restaurants, weatherForecast: $weatherForecast)';
  }
}

class DayPlan {
  final int day;
  final List<Activity> activities;

  DayPlan({required this.day, required this.activities});

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      day: json['day'] ?? 1,
      activities: ((json['activities'] ?? []) as List)
          .map<Activity>((activity) => Activity.fromJson(activity as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'activities': activities.map((e) => e.toJson()).toList(),
    };
  }
  @override
  String toString() {
    return 'DayPlan(day: $day, activities: $activities)';
  }
}

class Activity {
  final String name;
  final String description;
  String? imageUrl;
  final double? price;
  final String duration;
  final String? ticketUrl;
  final String? time;  // Add time field

  Activity({
    required this.name,
    required this.description,
    this.imageUrl,
    this.price,
    required this.duration,
    this.ticketUrl,
    this.time,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      name: json['name'] ?? 'Unnamed Activity',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      price: json['price'] is num
          ? json['price'].toDouble()
          : double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      duration: json['duration'] ?? '',
      ticketUrl: json['websiteUrl'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'duration': duration,
      'ticketUrl': ticketUrl,
      'time': time,
    };
  }
  @override
  String toString() {
    return 'Activity(name: $name, description: $description, imageUrl: $imageUrl, price: $price, duration: $duration, ticketUrl: $ticketUrl, time: $time)';
  }
}

class Hotel {
  String name;
  String? address;
  String? priceRange;
  String? imageUrl;
  String? geoCoordinates;
  String? rating;
  String? websiteUrl;

  Hotel({
    required this.name,
    this.address,
    this.priceRange,
    this.imageUrl,
    this.geoCoordinates,
    this.rating,
    this.websiteUrl,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      name: json['hotelName'] ?? json['name'] ?? 'Unnamed Hotel',
      address: json['address']?.toString(),
      priceRange: json['priceRange']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      geoCoordinates: json['geoCoordinates'] is Map
          ? "${json['geoCoordinates']['latitude']},${json['geoCoordinates']['longitude']}"
          : json['geoCoordinates']?.toString(),
      rating: json['rating']?.toString(),
      websiteUrl: json['websiteUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotelName': name,
      'address': address,
      'priceRange': priceRange,
      'imageUrl': imageUrl,
      'geoCoordinates': geoCoordinates,
      'rating': rating,
      'websiteUrl': websiteUrl,
    };
  }

  @override
  String toString() {
    return 'Hotel(name: $name, address: $address, priceRange: $priceRange, imageUrl: $imageUrl, geoCoordinates: $geoCoordinates, rating: $rating, websiteUrl: $websiteUrl)';
  }
}

class Restaurant {
  String name;
  String? address;
  String? priceRange;
  String? imageUrl;
  String? geoCoordinates;
  String? rating;
  String? websiteUrl;

  Restaurant({
    required this.name,
    this.address,
    this.priceRange,
    this.imageUrl,
    this.geoCoordinates,
    this.rating,
    this.websiteUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['restaurantName'] ?? json['name'] ?? 'Unnamed Restaurant',
      address: json['address']?.toString(),
      priceRange: json['priceRange']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      geoCoordinates: json['geoCoordinates'] is Map
          ? "${json['geoCoordinates']['latitude']},${json['geoCoordinates']['longitude']}"
          : json['geoCoordinates']?.toString(),
      rating: json['rating']?.toString(),
      websiteUrl: json['websiteUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantName': name,
      'address': address,
      'priceRange': priceRange,
      'imageUrl': imageUrl,
      'geoCoordinates': geoCoordinates,
      'rating': rating,
      'websiteUrl': websiteUrl,
    };
  }

  @override
  String toString() {
    return 'Restaurant(name: $name, address: $address, priceRange: $priceRange, imageUrl: $imageUrl, geoCoordinates: $geoCoordinates, rating: $rating, websiteUrl: $websiteUrl)';
  }
}
