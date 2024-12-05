import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trip_planner_app/core/theme/app_theme.dart';

import '../data/models/trip.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.destination,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header Section with Weather Summary
          _buildHeaderSection(),

          // Hotels Section
          _buildSectionTitle('Hotels'),
          _buildHotelsSection(),

          // Restaurants Section
          _buildSectionTitle('Restaurants'),
          _buildRestaurantsSection(),

          // Daily Plans Section
          _buildSectionTitle('Daily Itinerary'),
          _buildDailyPlansSection(),

          // Weather Forecast Section
          _buildSectionTitle('Weather Forecast'),
          _buildWeatherForecastSection(),

          // Packing Recommendations Section
          _buildSectionTitle('Packing Recommendations'),
          _buildPackingRecommendationsSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.destination,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'From ${trip.startDate.toLocal().toString().split(' ')[0]} '
                  'to ${trip.endDate.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16),
            ),
            if (trip.weatherForecast != null) ...[
              const SizedBox(height: 12),
              _buildWeatherSummary(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSummary() {
    final weather = trip.weatherForecast!;
    return Row(
      children: [
        const Icon(Icons.wb_sunny, color: Colors.orange),
        const SizedBox(width: 8),
        Text(
          '${weather.temperature}°C, ${weather.description}',
          style: const TextStyle(fontSize: 16),
        ),
        const Spacer(),
        Text(
          'Humidity: ${weather.humidity}%\nWind: ${weather.windSpeed} kph',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHotelsSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trip.hotels.length,
      itemBuilder: (context, index) {
        final hotel = trip.hotels[index];
        return Card(
          child: ListTile(
            leading: hotel.imageUrl != null
                ? CachedNetworkImage(
              imageUrl: hotel.imageUrl!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
              const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
              const Icon(Icons.hotel),
            )
                : const Icon(Icons.hotel),
            title: Text(hotel.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hotel.address != null) Text(hotel.address!),
                if (hotel.rating != null)
                  Text('Rating: ${hotel.rating}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRestaurantsSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trip.restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = trip.restaurants[index];
        return Card(
          child: ListTile(
            leading: restaurant.imageUrl != null
                ? CachedNetworkImage(
              imageUrl: restaurant.imageUrl!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
              const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
              const Icon(Icons.restaurant),
            )
                : const Icon(Icons.restaurant),
            title: Text(restaurant.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (restaurant.address != null) Text(restaurant.address!),
                if (restaurant.rating != null)
                  Text('Rating: ${restaurant.rating}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyPlansSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trip.dayPlans.length,
      itemBuilder: (context, index) {
        final dayPlan = trip.dayPlans[index];
        return Card(
          child: ExpansionTile(
            title: Text('Day ${dayPlan.day}'),
            children: dayPlan.activities.map((activity) {
              return ListTile(
                leading: activity.imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: activity.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                  const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.local_activity),
                )
                    : const Icon(Icons.local_activity),
                title: Text(activity.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.description),
                    if (activity.time != null) Text('Time: ${activity.time!}'),
                    if (activity.price != null)
                      Text('Price: \$${activity.price!.toStringAsFixed(2)}'),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildWeatherForecastSection() {
    if (trip.weatherForecast == null) {
      return const Text('No weather forecast available');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trip.weatherForecast!.dailyForecasts.length,
      itemBuilder: (context, index) {
        final forecast = trip.weatherForecast!.dailyForecasts[index];
        return Card(
          child: ListTile(
            title: Text(
              forecast.date.toLocal().toString().split(' ')[0],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Max: ${forecast.maxTemp}°C'),
                Text('Min: ${forecast.minTemp}°C'),
                Text(forecast.description),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPackingRecommendationsSection() {
    if (trip.weatherForecast?.packingRecommendation == null ||
        trip.weatherForecast!.packingRecommendation!.isEmpty) {
      return const Text('No packing recommendations available');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trip.weatherForecast!.packingRecommendation!.length,
      itemBuilder: (context, index) {
        final recommendation =
        trip.weatherForecast!.packingRecommendation![index];
        return Card(
          child: ExpansionTile(
            title: Text(recommendation.category),
            children: recommendation.items.map((item) {
              return ListTile(
                title: Text(item),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}