class HospitalService {
  // =====================================================
  // GET NEARBY HOSPITALS
  // फिलहाल demo hospital data use ho raha hai.
  // Baad mein API / Google Places API connect kar sakte hain.
  // =====================================================

  static Future<List<Map<String, dynamic>>> getNearbyHospitals() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      {
        'id': '1',
        'name': 'City Care Hospital',
        'type': 'Multi-Speciality Hospital',
        'address': 'MG Road, City Center',
        'distance': '1.2 km',
        'rating': 4.5,
        'phone': '+91 9876543210',
        'latitude': 28.6139,
        'longitude': 77.2090,
        'isOpen': true,
        'availableBeds': 24,
        'opdAvailable': true,
      },
      {
        'id': '2',
        'name': 'Apollo Health Clinic',
        'type': 'General & Emergency Care',
        'address': 'Main Market, Sector 15',
        'distance': '2.1 km',
        'rating': 4.3,
        'phone': '+91 9876543211',
        'latitude': 28.6219,
        'longitude': 77.2150,
        'isOpen': true,
        'availableBeds': 12,
        'opdAvailable': true,
      },
      {
        'id': '3',
        'name': 'LifeCare Medical Center',
        'type': 'Multi-Speciality Clinic',
        'address': 'Green Park, Near Metro Station',
        'distance': '3.5 km',
        'rating': 4.6,
        'phone': '+91 9876543212',
        'latitude': 28.6129,
        'longitude': 77.2295,
        'isOpen': true,
        'availableBeds': 8,
        'opdAvailable': true,
      },
      {
        'id': '4',
        'name': 'Sunrise Hospital',
        'type': 'Emergency & Trauma Care',
        'address': 'Ring Road, Central Area',
        'distance': '4.0 km',
        'rating': 4.2,
        'phone': '+91 9876543213',
        'latitude': 28.6304,
        'longitude': 77.2177,
        'isOpen': false,
        'availableBeds': 3,
        'opdAvailable': false,
      },
      {
        'id': '5',
        'name': 'HealthFirst Hospital',
        'type': 'General Hospital',
        'address': 'Civil Lines, City',
        'distance': '5.3 km',
        'rating': 4.4,
        'phone': '+91 9876543214',
        'latitude': 28.6350,
        'longitude': 77.2240,
        'isOpen': true,
        'availableBeds': 18,
        'opdAvailable': true,
      },
    ];
  }

  // =====================================================
  // SEARCH HOSPITALS
  // =====================================================

  static Future<List<Map<String, dynamic>>> searchHospitals(
    String query,
  ) async {
    final hospitals = await getNearbyHospitals();

    if (query.trim().isEmpty) {
      return hospitals;
    }

    final searchQuery = query.toLowerCase().trim();

    return hospitals.where((hospital) {
      final name =
          hospital['name'].toString().toLowerCase();

      final type =
          hospital['type'].toString().toLowerCase();

      final address =
          hospital['address'].toString().toLowerCase();

      return name.contains(searchQuery) ||
          type.contains(searchQuery) ||
          address.contains(searchQuery);
    }).toList();
  }
}