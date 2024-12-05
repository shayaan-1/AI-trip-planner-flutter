import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner_app/data/models/trip.dart';
import 'package:trip_planner_app/core/theme/app_theme.dart';
import '../../data/providers/trip_provider.dart';
import 'package:trip_planner_app/data/services/unsplash_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/weather_packaging_widget.dart';

class GeneratedTripScreen extends ConsumerStatefulWidget {
  const GeneratedTripScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GeneratedTripScreen> createState() => _GeneratedTripScreenState();
}

class _GeneratedTripScreenState extends ConsumerState<GeneratedTripScreen> {
  late Future<Trip> _tripFuture;
  int _selectedTabIndex = 0;
  List<Hotel> _selectedHotels = [];
  List<Restaurant> _selectedRestaurants = [];
  late Trip tripState;

  @override
  void initState() {
    super.initState();
    final currentTrip = ref.read(currentTripProvider);
    if (currentTrip == null) {
      throw Exception("No trip details found in the currentTripProvider.");
    }
    final numberOfDays =
        currentTrip.endDate.difference(currentTrip.startDate).inDays + 1;
    _tripFuture = ref
        .read(geminiServiceProvider)
        .generateTripPlan(
      destination: currentTrip.destination,
      travelGroup: currentTrip.travelGroup,
      budget: currentTrip.budget,
      numberOfDays: numberOfDays,
    );
  }

// New method to show customization bottom sheet
  void _showCustomizationBottomSheet(BuildContext context, Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => ListView(
            controller: scrollController,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Customize Your Trip',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildCustomizableSection(
                title: 'Hotels',
                items: trip.hotels,
                selectedItems: _selectedHotels,
                onItemToggle: (hotel) {
                  setModalState(() {
                    if (_selectedHotels.contains(hotel)) {
                      _selectedHotels.remove(hotel);
                    } else {
                      _selectedHotels.add(hotel);
                    }
                  });
                },
              ),
              _buildCustomizableSection(
                title: 'Restaurants',
                items: trip.restaurants,
                selectedItems: _selectedRestaurants,
                onItemToggle: (restaurant) {
                  setModalState(() {
                    if (_selectedRestaurants.contains(restaurant)) {
                      _selectedRestaurants.remove(restaurant);
                    } else {
                      _selectedRestaurants.add(restaurant);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomizableSection<T>({
    required String title,
    required List<T> items,
    required List<T> selectedItems,
    required Function(T) onItemToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selectedItems.contains(item);
              return _buildCustomizableItemTile<T>(
                item: item,
                isSelected: isSelected,
                onToggle: (bool? value) {
                  onItemToggle(item);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizableItemTile<T>({
    required T item,
    required bool isSelected,
    required void Function(bool?) onToggle,
  }) {
    return ListTile(
      title: Text(
        (item as dynamic).name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        (item is Hotel) ? item.address ?? 'No address' : (item as dynamic).address ?? 'No address',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: Checkbox(
        value: isSelected,
        activeColor: AppTheme.primaryColor,
        onChanged: onToggle,
      ),
    );
  }

  // Updated _buildTripDetailsView to include a customization button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: FutureBuilder<Trip>(
          future: _tripFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else if (!snapshot.hasData) {
              return _buildNoDataState();
            } else {
              final trip = snapshot.data!;
              tripState = trip;
              return Stack(
                children: [
                  _buildTripDetailsView(trip),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 30,  // You can increase the size for better visibility
                      ),
                      onPressed: () => _showCustomizationBottomSheet(context, trip),
                      padding: const EdgeInsets.all(10),  // Adds padding around the icon
                      splashColor: Colors.blue.withOpacity(0.3),  // Splash effect color
                      highlightColor: Colors.blue.withOpacity(0.5),  // Highlight color on press
                      iconSize: 35,  // Larger icon size
                      constraints: const BoxConstraints(),  // Removes any default constraints to allow free size
                      splashRadius: 20,  // Controls the size of the splash effect
                      tooltip: 'Customize Trip',  // Tooltip to show when hovered or tapped
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: () {
                        _saveCustomSelections();
                      },
                      child: const Icon(Icons.save, color: Colors.white,),
                      backgroundColor: AppTheme.primaryColor,
                      tooltip: 'Save Customizations',
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void _saveCustomSelections() async {
    try {
      // Get the current trip from the provider
      final currentTrip = ref.read(currentTripProvider);
      if (currentTrip == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No trip found to save')),
        );
        return;
      }
      // Create a new trip object with selected hotels and restaurants
      final customTrip = Trip(
        cityImageUrl: tripState.cityImageUrl,
        destination: tripState.destination,
        travelGroup: tripState.travelGroup,
        budget: tripState.budget,
        dayPlans: tripState.dayPlans,
        hotels: _selectedHotels,
        restaurants: _selectedRestaurants,
        id: tripState.id,
        startDate: tripState.startDate,
        endDate: tripState.endDate,
        weatherForecast: currentTrip.weatherForecast
      );

      // Get current user's UID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');

      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('trips')
          .add(customTrip.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip saved successfully!')),
      );

      Navigator.popAndPushNamed(context, "/trips");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save trip: ${e.toString()}')),
      );
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Text(
        'Error: $error',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildNoDataState() {
    return const Center(
      child: Text(
        'No Trip Data Available',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildTripDetailsView(Trip trip) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              _buildCityImage(trip.destination),
              _buildTabView(trip),
            ],
          ),
        ),
        _buildTabBar(),
      ],
    );
  }

  Widget _buildCityImage(String destination) {
    return FutureBuilder<String>(
      future: UnsplashService.fetchImage(destination),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(color: AppTheme.secondaryColor);
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Container(color: AppTheme.secondaryColor);
        } else {
          tripState.cityImageUrl = snapshot.data;
          return Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
          );
        }
      },
    );
  }

  Widget _buildTabBar() {
    return BottomNavigationBar(
      currentIndex: _selectedTabIndex,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'Overview',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.hotel),
          label: 'Hotels',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: 'Restaurants',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.cloud),
          label: 'Weather',
        ),
      ],
    );
  }

  Widget _buildTabView(Trip trip) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.35,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: IndexedStack(
          index: _selectedTabIndex,
          children: [
            _buildOverviewTab(trip),
            _buildHotelsTab(trip.hotels),
            _buildRestaurantsTab(trip.restaurants),
            _buildWeatherAndPackingTab(trip),
          ],
        ),
      ),
    );
  }
  // New method to build Weather and Packing tab
  Widget _buildWeatherAndPackingTab(Trip trip) {
    return WeatherAndPackingDialog(trip: trip);
  }

  Widget _buildOverviewTab(Trip trip) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTripOverviewCard(trip),
        const SizedBox(height: 16),
        _buildItinerarySection(trip),
      ],
    );
  }

  Widget _buildHotelsTab(List<Hotel> hotels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Hotels',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              return _buildHotelOrRestaurantCard(hotel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantsTab(List<Restaurant> restaurants) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Restaurants',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return _buildRestaurantCard(restaurant);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHotelOrRestaurantCard(Hotel hotel) {
    return FutureBuilder<String>(
      future: UnsplashService.fetchImage(hotel.name),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data ?? hotel.imageUrl ?? '';
        hotel.imageUrl = imageUrl;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        height: 250,
                        color: AppTheme.secondaryColor.withOpacity(0.2),
                        child: Center(
                          child: Icon(
                            Icons.hotel,
                            size: 100,
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: hotel.rating != null
                            ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                hotel.rating!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                              ),
                            ],
                          ),
                        )
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hotel.address ?? 'Address not available',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (hotel.priceRange != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Price: ${hotel.priceRange!}',
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            TextButton(
                              onPressed: () {
                                // TODO: Implement hotel details or booking
                              },
                              child: const Text(
                                'View Details',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return FutureBuilder<String>(
      future: UnsplashService.fetchImage(restaurant.name),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data ?? restaurant.imageUrl ?? '';
        restaurant.imageUrl = imageUrl;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        height: 250,
                        color: AppTheme.secondaryColor.withOpacity(0.2),
                        child: Center(
                          child: Icon(
                            Icons.restaurant,
                            size: 100,
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: restaurant.rating != null
                            ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                restaurant.rating!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                              ),
                            ],
                          ),
                        )
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                restaurant.address ?? 'Address not available',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (restaurant.priceRange != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Price: ${restaurant.priceRange!}',
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            TextButton(
                              onPressed: () {
                                // TODO: Implement restaurant details or reservation
                              },
                              child: const Text(
                                'View Menu',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildTripOverviewCard(Trip trip) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOverviewItem(
                  icon: Icons.people,
                  title: 'Travel Group',
                  subtitle: trip.travelGroup,
                ),
                _buildOverviewItem(
                  icon: Icons.attach_money,
                  title: 'Budget',
                  subtitle: trip.budget,
                ),
                _buildOverviewItem(
                  icon: Icons.calendar_today,
                  title: 'Duration',
                  subtitle: '${trip.dayPlans.length} Days',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 30,
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildItinerarySection(Trip trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Itinerary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 16),
        ...trip.dayPlans.map((dayPlan) => _buildDayPlanCard(dayPlan)).toList(),
      ],
    );
  }

  Widget _buildDayPlanCard(DayPlan dayPlan) {
    return FutureBuilder<String>(
      future: UnsplashService.fetchImage(dayPlan.activities.first.name),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data ?? '';
        dayPlan.activities.first.imageUrl = imageUrl;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageUrl.isNotEmpty
                  ? ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                height: 200,
                color: AppTheme.secondaryColor,
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day ${dayPlan.day}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    ...dayPlan.activities.map((activity) => _buildActivityTile(activity)).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTile(Activity activity) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(8),
        child: const Icon(
          Icons.local_activity,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(
        activity.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textColor,
        ),
      ),
      subtitle: Text(
        activity.description,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}