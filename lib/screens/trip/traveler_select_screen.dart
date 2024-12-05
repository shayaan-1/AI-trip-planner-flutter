import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner_app/core/theme/app_theme.dart';
import '../../data/providers/trip_provider.dart';

class TravelerSelectScreen extends ConsumerStatefulWidget {
  const TravelerSelectScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TravelerSelectScreen> createState() => _TravelerSelectScreenState();
}

class _TravelerSelectScreenState extends ConsumerState<TravelerSelectScreen> {
  String _selectedTravelers = 'Just Me';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Who\'s Traveling',
          style: TextStyle(color: AppTheme.textColor),
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Choose your travelers',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      _buildRadioTile(
                        context,
                        value: 'Just Me',
                        label: 'Just Me',
                        icon: Icons.person,
                      ),
                      _buildRadioTile(
                        context,
                        value: 'A Couple',
                        label: 'A Couple',
                        icon: Icons.favorite,
                      ),
                      _buildRadioTile(
                        context,
                        value: 'Family',
                        label: 'Family',
                        icon: Icons.group,
                      ),
                      _buildRadioTile(
                        context,
                        value: 'Friends',
                        label: 'Friends',
                        icon: Icons.people,
                      ),
                    ],
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
                      ref
                          .read(currentTripProvider.notifier)
                          .updateTravelGroup(_selectedTravelers);
                      Navigator.pushNamed(context, '/review-trip');
                    },
                    child: const Text(
                      'Continue',
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

  Widget _buildRadioTile(BuildContext context,
      {required String value, required String label, required IconData icon}) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(color: AppTheme.primaryColor),
          ),
        ],
      ),
      value: value,
      activeColor: AppTheme.primaryColor,
      groupValue: _selectedTravelers,
      onChanged: (newValue) {
        setState(() {
          _selectedTravelers = newValue!;
        });
      },
    );
  }
}
