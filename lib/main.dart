import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Import for Firebase initialization
import 'package:flutter_riverpod/flutter_riverpod.dart';  // Import for Riverpod
import 'package:trip_planner_app/screens/splash/splash_screen.dart';
import 'package:trip_planner_app/screens/auth/login_screen.dart';
import 'package:trip_planner_app/screens/auth/signup_screen.dart';
import 'package:trip_planner_app/screens/trip/budget_select_screen.dart';
import 'package:trip_planner_app/screens/trip/date_select_screen.dart';
import 'package:trip_planner_app/screens/trip/generated_trip_screen.dart';
import 'package:trip_planner_app/screens/trip/review_trip_plan.dart';
import 'package:trip_planner_app/screens/trip/search_screen.dart';
import 'package:trip_planner_app/screens/trip/traveler_select_screen.dart';
import 'package:trip_planner_app/screens/trip/trip_list_screen.dart';

import 'data/services/unsplash_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await UnsplashService.clearImageCacheOnStartup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(  // Wrapping the app in ProviderScope
      child: MaterialApp(
        title: 'Trip Planner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
        ),
        initialRoute: '/',
        routes:  {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/trips': (context) => TripListScreen(),
          '/search': (context) => SearchScreen(),
          '/travelers': (context) => TravelerSelectScreen(),
          '/select-budget': (context) => SelectBudgetScreen(),
          '/select-travel-dates': (context) => TravelDatesScreen(),
          '/review-trip': (context) => ReviewTripScreen(),
          '/generated-trip': (context) => GeneratedTripScreen(),//   trip: ModalRoute.of(context)!.settings.arguments as Trip,
          // ),
        },
      ),
    );
  }
}
