import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner_app/data/models/trip.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/trip_details_screen.dart';

class TripListScreen extends ConsumerStatefulWidget {
  const TripListScreen({super.key});

  @override
  _TripListScreenState createState() => _TripListScreenState();
}

class _TripListScreenState extends ConsumerState<TripListScreen> {
  List<Trip> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserTrips();
  }

  Future<void> _fetchUserTrips() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('trips')
          .get();


      setState(() {
        _trips = querySnapshot.docs.map((doc) {
          return Trip.fromJson(doc.data());
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load trips: ${e.toString()}')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Trips',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2193b0),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF2193b0)),
                    onPressed: () => Navigator.pushNamed(context, '/search'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Conditional rendering based on trips
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _trips.isEmpty
                  ? _buildEmptyTripsView()
                  : _buildTripsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTripsView() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.landscape,
              size: 80,
              color: Color(0xFF2193b0),
            ),
            const SizedBox(height: 20),
            const Text(
              'No trips planned yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Looks like it\'s time to plan a new\ntravel experience! Get Started',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Start a new trip',
              onPressed: () => Navigator.pushNamed(context, '/search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _trips.length,
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return _buildTripCard(trip);
        },
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // City Image
              trip.cityImageUrl != null
                  ? Image.network(
                trip.cityImageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.landscape, size: 50),
                  );
                },
              )
                  : Container(
                height: 200,
                color: Colors.grey[300],
                child: Icon(Icons.landscape, size: 50),
              ),

              // Trip Details
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.destination.isNotEmpty ? trip.destination : 'Mystery Destination',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2193b0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailChip(
                          icon: Icons.calendar_today,
                          text: _formatDateRange(trip.startDate, trip.endDate),
                        ),
                        _buildDetailChip(
                          icon: Icons.attach_money,
                          text: trip.budget.isNotEmpty ? trip.budget : '\$0',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildDetailChip(
                      icon: Icons.group,
                      text: trip.travelGroup.isNotEmpty ? trip.travelGroup : 'Travelers',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: const Icon(Icons.travel_explore),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TripDetailsScreen(trip: trip)
                          )
                      );
                    },
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper method to format date range
  String _formatDateRange(DateTime start, DateTime end) {
    try {
      return '${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd, yyyy').format(end)}';
    } catch (e) {
      return 'Dates Not Available';
    }
  }
  Widget _buildDetailChip({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}