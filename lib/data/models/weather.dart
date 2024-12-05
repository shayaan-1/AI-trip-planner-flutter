// Weather Model
class WeatherForecast {
  final String location;
  final double temperature;
  final String description;
  final double humidity;
  final double windSpeed;
  final List<DailyForecast> dailyForecasts;
  late final List<PackingRecommendation>? packingRecommendation;

  WeatherForecast({
    required this.location,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.dailyForecasts,
    this.packingRecommendation,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final isWeatherApi = json.containsKey('location') && json['location'] is Map;

    return WeatherForecast(
        location: isWeatherApi
            ? (json['location']?['name'] ?? "Unknown")
            : (json['location'] ?? 'Unknown'),
        temperature: isWeatherApi
            ? (json['current']?['temp_c'] ?? 0).toDouble()
            : (json['temperature'] ?? 0).toDouble(),
        description: isWeatherApi
            ? (json['current']?['condition']?['text'] ?? 'No description')
            : json['description'] ?? 'No description',
        humidity: isWeatherApi
            ? (json['current']?['humidity'] ?? 0).toDouble()
            : (json['humidity'] ?? 0).toDouble(),
        windSpeed: isWeatherApi
            ? (json['current']?['wind_kph'] ?? 0).toDouble()
            : (json['windSpeed'] ?? 0).toDouble(),
        dailyForecasts: isWeatherApi
            ? (json['forecast']?['forecastday'] ?? [])
            .map<DailyForecast>((day) => DailyForecast.fromJson(day))
            .toList()
            : (json['dailyForecasts'] ?? [])
            .map<DailyForecast>((day) => DailyForecast.fromJson(day))
            .toList(),
        packingRecommendation: json['packingRecommendation'] != null
            ? (json['packingRecommendation'] as List)
            .map((item) => PackingRecommendation.fromJson(item))
            .toList()
            : []
    );  }
  @override
  String toString() {
    return 'WeatherForecast(location: $location, temperature: $temperature°C, description: $description, humidity: $humidity%, windSpeed: $windSpeed kph, dailyForecasts: $dailyForecasts, packingRecommendation: $packingRecommendation)';
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'temperature': temperature,
      'description': description,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'dailyForecasts':
      dailyForecasts.map((forecast) => forecast.toJson()).toList(),
      'packingRecommendation': packingRecommendation
          ?.map((recommendation) => recommendation.toJson())
          .toList(),
    };
  }

  WeatherForecast copyWith({
    String? location,
    double? temperature,
    String? description,
    double? humidity,
    double? windSpeed,
    List<DailyForecast>? dailyForecasts,
    List<PackingRecommendation>? packingRecommendation,
  }) {
    return WeatherForecast(
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
      description: description ?? this.description,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      dailyForecasts: dailyForecasts ?? this.dailyForecasts,
      packingRecommendation: packingRecommendation ?? this.packingRecommendation,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String description;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final isWeatherApi = json.containsKey('day');
    final dayData = isWeatherApi ? json['day'] : json;

    return DailyForecast(
      date: DateTime.parse(json['date']),
      maxTemp: (dayData['maxtemp_c'] ?? dayData['maxTemp'] ?? 0).toDouble(),
      minTemp: (dayData['mintemp_c'] ?? dayData['minTemp'] ?? 0).toDouble(),
      description: dayData['condition']?['text'] ?? dayData['description'] ?? 'No description',
    );
  }

  @override
  String toString() {
    return 'DailyForecast(date: $date, maxTemp: $maxTemp°C, minTemp: $minTemp°C, description: $description)';
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'description': description,
      'maxTemp': maxTemp,
      'minTemp': minTemp,
    };
  }

  DailyForecast copyWith({
    DateTime? date,
    double? maxTemp,
    double? minTemp,
    String? description,
  }) {
    return DailyForecast(
      date: date ?? this.date,
      maxTemp: maxTemp ?? this.maxTemp,
      minTemp: minTemp ?? this.minTemp,
      description: description ?? this.description,
    );
  }
}

class PackingRecommendation {
  final String category;
  final List<String> items;

  PackingRecommendation({
    required this.category,
    required this.items,
  });

  factory PackingRecommendation.fromJson(Map<String, dynamic> json) {
    return PackingRecommendation(
      category: json['category'],
      items: List<String>.from(json['items']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'items': items,
    };
  }
  @override
  String toString() {
    return 'PackingRecommendation(category: $category, items: ${items.join(', ')})';
  }

  PackingRecommendation copyWith({
    String? category,
    List<String>? items,
  }) {
    return PackingRecommendation(
      category: category ?? this.category,
      items: items ?? this.items,
    );
  }
}
