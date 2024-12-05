import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner_app/core/theme/app_theme.dart';
import '../../data/providers/trip_provider.dart';

class SelectBudgetScreen extends ConsumerStatefulWidget {
  const SelectBudgetScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SelectBudgetScreen> createState() => _SelectBudgetScreenState();
}

class _SelectBudgetScreenState extends ConsumerState<SelectBudgetScreen> {
  String _selectedBudget = 'Cheap';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Budget',
          style: TextStyle(color: AppTheme.textColor),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
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
                  'Choose spending habits',
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
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Row(
                          children: [
                            Icon(Icons.money_off, color: AppTheme.primaryColor),
                            SizedBox(width: 8),
                            Text(
                              'Cheap',
                              style: TextStyle(color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                        value: 'Cheap',
                        activeColor: AppTheme.primaryColor,
                        groupValue: _selectedBudget,
                        onChanged: (value) {
                          setState(() {
                            _selectedBudget = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Row(
                          children: [
                            Icon(Icons.attach_money, color: AppTheme.primaryColor),
                            SizedBox(width: 8),
                            Text(
                              'Moderate',
                              style: TextStyle(color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                        value: 'Moderate',
                        activeColor: AppTheme.primaryColor,
                        groupValue: _selectedBudget,
                        onChanged: (value) {
                          setState(() {
                            _selectedBudget = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Row(
                          children: [
                            Icon(Icons.diamond, color: AppTheme.primaryColor),
                            SizedBox(width: 8),
                            Text(
                              'Luxury',
                              style: TextStyle(color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                        value: 'Luxury',
                        activeColor: AppTheme.primaryColor,
                        groupValue: _selectedBudget,
                        onChanged: (value) {
                          setState(() {
                            _selectedBudget = value!;
                          });
                        },
                      ),
                    ],
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
                    ref.read(currentTripProvider.notifier).updateBudget(_selectedBudget);
                    Navigator.pushNamed(context, '/travelers');
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
