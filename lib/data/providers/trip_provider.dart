import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip.dart';
import '../models/place.dart';
import '../models/weather.dart';
import '../services/gemini_service.dart';
import '../services/places_service.dart';
import '../services/weather_service.dart';

/// Providers for services
final placesServiceProvider = Provider((ref) => PlacesService());
final geminiServiceProvider = Provider((ref) => GeminiService());
final weatherServiceProvider = Provider((ref) => WeatherService());

/// Provider for managing all trips
final tripsProvider = StateNotifierProvider<TripsNotifier, List<Trip>>((ref) {
  return TripsNotifier();
});

class TripsNotifier extends StateNotifier<List<Trip>> {
  TripsNotifier() : super([]);

  void addTrip(Trip trip) {
    state = [...state, trip];
  }

  void removeTrip(String tripId) {
    state = state.where((trip) => trip.id != tripId).toList();
  }
}

/// Provider for managing search results
final searchResultsProvider =
StateNotifierProvider<SearchResultsNotifier, AsyncValue<List<Place>>>((ref) {
  return SearchResultsNotifier(ref.watch(placesServiceProvider));
});

class SearchResultsNotifier extends StateNotifier<AsyncValue<List<Place>>> {
  final PlacesService _placesService;

  SearchResultsNotifier(this._placesService) : super(const AsyncValue.data([]));

  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _placesService.searchPlaces(query));
  }
}

/// Provider for managing the current trip
final currentTripProvider = StateNotifierProvider<CurrentTripNotifier, Trip?>((ref) {
  final weatherService = ref.watch(weatherServiceProvider);
  return CurrentTripNotifier(weatherService);
});

class CurrentTripNotifier extends StateNotifier<Trip?> {
  final WeatherService _weatherService;

  CurrentTripNotifier(this._weatherService) : super(null);

  /// Update the destination of the trip
  void updateDestination(Place place) {
    state = Trip(
      id: DateTime.now().toString(),
      destination: place.name,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      travelGroup: '',
      budget: '',
      hotels: [],
      restaurants: [],
      weatherForecast: null, // Initialize weather forecast as null
    );
  }

  /// Fetch and update the weather forecast and packing recommendations
  Future<void> updateDatesAndWeather(DateTime startDate, DateTime endDate) async {
    // First, update the trip dates
    state = state?.copyWith(startDate: startDate, endDate: endDate);

    // If there's a current trip, refetch the weather forecast
    if (state != null) {
      try {
        final tripDuration = endDate.difference(startDate).inDays + 1;
        final forecast = await _weatherService.fetchWeatherForecast(
            state!.destination,
            tripDuration
        );

        // Generate packing recommendations
        final recommendations = _weatherService.generatePackingRecommendations(
            forecast,
            tripDuration
        );

        // Create an updated forecast with recommendations
        final updatedForecast = forecast.copyWith(
            packingRecommendation: recommendations
        );

        // Update the trip with the new weather forecast
        state = state?.copyWith(
          weatherForecast: updatedForecast,
        );
      } catch (e) {
        print('Error updating weather forecast: $e');
        // Optionally handle the error, perhaps set a default forecast
      }
    }
  }  /// Update the trip dates
  void updateRecommendations(List<PackingRecommendation> recommendations) {
    final currentWeatherForecast = state?.weatherForecast;

    // If packing recommendations are not present, initialize it
    final updatedPackingRecommendations = currentWeatherForecast?.packingRecommendation ?? [];

    // Add or update the packing recommendations
    updatedPackingRecommendations.addAll(recommendations);

    // Update the weather forecast with the new packing recommendations
    final updatedWeatherForecast = currentWeatherForecast?.copyWith(
      packingRecommendation: updatedPackingRecommendations,
    );

    // Update the trip state with the new weather forecast
    state = state?.copyWith(weatherForecast: updatedWeatherForecast);
  }
// Method to update the weather forecast
  void updateWeatherForecast(WeatherForecast weather) {
    // Update the state with the new weather forecast
    state = state?.copyWith(weatherForecast: weather);
  }

  void updateDates(DateTime startDate, DateTime endDate) {
    state = state?.copyWith(startDate: startDate, endDate: endDate);
  }

  /// Update the budget
  void updateBudget(String budget) {
    state = state?.copyWith(budget: budget);
  }

  /// Update the travel group
  void updateTravelGroup(String travelGroup) {
    state = state?.copyWith(travelGroup: travelGroup);
  }

  /// Update the list of hotels and restaurants
  void updateHotelsAndRestaurants(List<Hotel> hotels, List<Restaurant> restaurants) {
    state = state?.copyWith(hotels: hotels, restaurants: restaurants);
  }
  /// Clear the current trip
  void clearTrip() {
    state = null;
  }

}


/// Extension for Trip model to enable `copyWith`
extension TripCopyWith on Trip {
  Trip copyWith({
    String? id,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? travelGroup,
    String? budget,
    List<DayPlan>? dayPlans,
    List<Hotel>? hotels,
    List<Restaurant>? restaurants,
    WeatherForecast? weatherForecast,
  }) {
    return Trip(
      id: id ?? this.id,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      travelGroup: travelGroup ?? this.travelGroup,
      budget: budget ?? this.budget,
      dayPlans: dayPlans ?? this.dayPlans,
      hotels: hotels ?? this.hotels,
      restaurants: restaurants ?? this.restaurants,
      weatherForecast: weatherForecast ?? this.weatherForecast, // Include this
    );
  }

}

