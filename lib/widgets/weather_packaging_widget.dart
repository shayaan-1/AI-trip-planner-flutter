import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner_app/data/providers/trip_provider.dart';
import '../data/models/trip.dart';
import '../data/models/weather.dart';
import '../data/services/weather_service.dart';
import '../core/theme/app_theme.dart';

class WeatherAndPackingDialog extends ConsumerStatefulWidget {
  final Trip trip;

  const WeatherAndPackingDialog({Key? key, required this.trip}) : super(key: key);

  @override
  ConsumerState<WeatherAndPackingDialog> createState() => _WeatherAndPackingDialogState();
}

class _WeatherAndPackingDialogState extends ConsumerState<WeatherAndPackingDialog> {
  late Future<WeatherForecast> _weatherFuture;
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _weatherFuture = _fetchWeatherData();
  }

  Future<WeatherForecast> _fetchWeatherData() async {
    final tripDuration = widget.trip.endDate.difference(widget.trip.startDate).inDays + 1;
    final weatherData = await _weatherService.fetchWeatherForecast(widget.trip.destination, tripDuration);

    // After fetching the weather, update packing recommendations
    final packingRecommendations = _weatherService.generatePackingRecommendations(
      weatherData,
      tripDuration,
    );
    final updatedWeatherData = weatherData.copyWith(
      packingRecommendation: packingRecommendations,
    );
    print(updatedWeatherData.toString());

    // Call the updateRecommendations method here
    ref.read(currentTripProvider.notifier).updateWeatherForecast(updatedWeatherData);

    return weatherData;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      // Increase width and adjust shape
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.05
      ),
      child: Container(
        width: screenWidth * 0.9, // Make it wider
        padding: const EdgeInsets.all(16),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitle(theme),
              Expanded(
                child: FutureBuilder<WeatherForecast>(
                  future: _weatherFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingState(theme);
                    }

                    if (snapshot.hasError) {
                      return _buildErrorState(theme);
                    }

                    if (!snapshot.hasData) {
                      return _buildNoDataState(theme);
                    }

                    // Safely handle the data case
                    final weatherData = snapshot.data!;

                    return _buildWeatherContent(weatherData, theme, screenWidth);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhance the title to be more prominent
  Widget _buildTitle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.7)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Weather & Packing for ${widget.trip.destination}',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return _buildMessageState(
      theme,
      icon: Icons.error_outline,
      message: 'Unable to fetch weather data',
      color: theme.colorScheme.error,
    );
  }

  Widget _buildNoDataState(ThemeData theme) {
    return _buildMessageState(
      theme,
      icon: Icons.cloud_off,
      message: 'No weather data available',
      color: theme.primaryColor.withOpacity(0.5),
    );
  }

  Widget _buildMessageState(ThemeData theme, {required IconData icon, required String message, required Color color}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 60),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }


// Modify the WeatherContent to have better spacing
  Widget _buildWeatherContent(WeatherForecast forecast, ThemeData theme, double screenWidth) {
    final packingRecommendations = _weatherService.generatePackingRecommendations(
      forecast,
      widget.trip.endDate.difference(widget.trip.startDate).inDays + 1,
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCurrentWeatherSection(forecast, theme),
          const SizedBox(height: 16),
          _buildDailyForecastSection(forecast, theme),
          const SizedBox(height: 16),
          ..._buildPackingRecommendationSections(packingRecommendations, theme),
        ],
      ),
    );
  }
  Widget _buildCurrentWeatherSection(WeatherForecast forecast, ThemeData theme) {
    // Function to get the appropriate icon based on weather description
    IconData _getWeatherIcon(String description) {
      description = description.toLowerCase();

      if (description.contains('sunny') || description.contains('clear')) {
        return Icons.wb_sunny_outlined;
      } else if (description.contains('cloud')) {
        return Icons.cloud_outlined;
      } else if (description.contains('rain')) {
        return Icons.water_drop_outlined;
      } else if (description.contains('storm') || description.contains('thunder')) {
        return Icons.thunderstorm_outlined;
      } else if (description.contains('snow')) {
        return Icons.ac_unit_outlined;
      } else if (description.contains('wind')) {
        return Icons.air_outlined;
      } else {
        return Icons.wb_cloudy_outlined; // default icon
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor.withOpacity(0.1), theme.primaryColor.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Add the weather icon
          Icon(
            _getWeatherIcon(forecast.description),
            size: 80,
            color: theme.primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            '${forecast.temperature.round()}°C',
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            forecast.description,
            style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeatherInfoTile('Humidity', '${forecast.humidity}%', theme),
              _buildWeatherInfoTile('Wind', '${forecast.windSpeed} km/h', theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfoTile(String title, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastSection(WeatherForecast forecast, ThemeData theme) {
    return Card(
      color: theme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: forecast.dailyForecasts.length,
        itemBuilder: (context, index) {
          final daily = forecast.dailyForecasts[index];
          return ListTile(
            title: Text(
              DateFormat('EEEE, MMM d').format(daily.date),
              style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(daily.description, style: theme.textTheme.bodyMedium),
            trailing: Text(
              '${daily.maxTemp.round()}°C / ${daily.minTemp.round()}°C',
              style: theme.textTheme.bodyMedium,
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPackingRecommendationSections(List<PackingRecommendation> recommendations, ThemeData theme) {
    return recommendations.map((recommendation) {
      return Card(
        color: theme.cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          title: Text(
            recommendation.category,
            style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          children: recommendation.items.map((item) {
            return ListTile(
              title: Text(item, style: theme.textTheme.bodyMedium),
              leading: Icon(Icons.check_circle_outline, color: theme.primaryColor),
            );
          }).toList(),
        ),
      );
    }).toList();
  }

}