class Place {
  final String name;
  final String description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  Place({
    required this.name,
    required this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    try {
      return Place(
        name: json['detailsV2']?['names']?['name'] ?? 'Unknown Place',
        description: json['detailsV2']?['names']?['longOnlyHierarchyTypeaheadV2'] ?? '',
        imageUrl: _extractImageUrl(json),
        latitude: json['detailsV2']?['geocode']?['latitude'],
        longitude: json['detailsV2']?['geocode']?['longitude'],
      );
    } catch (e) {
      print('Error parsing place from JSON: $e');
      print('Problematic JSON: $json');
      throw Exception('Failed to parse place: ${e.toString()}');
    }
  }

  static String? _extractImageUrl(Map<String, dynamic> json) {
    try {
      final photoSizes = json['image']?['photo']?['photoSizes'];
      if (photoSizes is List && photoSizes.isNotEmpty) {
        // Return the last (typically largest) image URL
        return photoSizes.last['url'];
      }
      return null;
    } catch (e) {
      print('Error extracting image URL: $e');
      return null;
    }
  }
}




class PlaceDetails {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return PlaceDetails(
      name: json['name'],
      address: json['formatted_address'],
      latitude: location['lat'],
      longitude: location['lng'],
    );
  }
}
