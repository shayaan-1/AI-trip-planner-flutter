import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner_app/core/theme/app_theme.dart';
import 'package:trip_planner_app/data/models/trip.dart';
import '../../data/providers/trip_provider.dart';

class ReviewTripScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(currentTripProvider);

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Review Trip",
            style: TextStyle(color: AppTheme.textColor),
          ),
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: AppTheme.primaryColor),
        ),
        body: const Center(child: Text("No trip data available")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child:  Text(
            "Review Trip",
            style: TextStyle(color: AppTheme.textColor),
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.backgroundColor,
              AppTheme.secondaryColor.withOpacity(0.1)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Trip Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTripDetailRow('Destination', trip.destination),
                        _buildTripDetailRow(
                          'Start Date',
                          '${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year}',
                        ),
                        _buildTripDetailRow(
                          'End Date',
                          '${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}',
                        ),
                        _buildTripDetailRow('Budget', trip.budget),
                        _buildTripDetailRow('Travel Group', trip.travelGroup),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      // Add your final trip confirmation logic here
                      Navigator.pushNamed(context, '/generated-trip');
                    },
                    child: const Text(
                      'Confirm Trip',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white, // Ensuring text is white
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(color: AppTheme.textColor),
          ),
        ],
      ),
    );
  }
}
