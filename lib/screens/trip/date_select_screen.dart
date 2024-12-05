import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner_app/core/theme/app_theme.dart';
import 'package:trip_planner_app/data/providers/trip_provider.dart';

class TravelDatesScreen extends ConsumerStatefulWidget {
  const TravelDatesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TravelDatesScreen> createState() => _TravelDatesScreenState();
}

class _TravelDatesScreenState extends ConsumerState<TravelDatesScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Travel Dates',
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
              AppTheme.secondaryColor.withOpacity(0.1),
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
              children: [
                const Text(
                  'Select your travel dates',
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Start: ${_startDate.day}/${_startDate.month}/${_startDate.year}',
                              style: TextStyle(color: AppTheme.primaryColor),
                            ),
                            Text(
                              'End: ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                              style: TextStyle(color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2025),
                                  builder: (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        primaryColor: AppTheme.primaryColor, // Set the primary color
                                        colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor), // Modify color scheme
                                        buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary), // Button text color
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (selectedDate != null) {
                                  setState(() {
                                    _startDate = selectedDate;
                                  });
                                }
                              },
                              child: const Text(
                                'Start Date',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: _startDate.add(const Duration(days: 1)),
                                  lastDate: DateTime(2025),
                                  builder: (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        primaryColor: AppTheme.primaryColor, // Set the primary color
                                        colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor), // Modify color scheme
                                        buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary), // Button text color
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (selectedDate != null) {
                                  setState(() {
                                    _endDate = selectedDate;
                                  });
                                }
                              },
                              child: const Text(
                                'End Date',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    ref.read(currentTripProvider.notifier).updateDates(_startDate, _endDate);
                    Navigator.pushNamed(context, '/select-budget');
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
