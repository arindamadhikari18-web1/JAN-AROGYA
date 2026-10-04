import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import '../services/hospital_service.dart';

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() =>
      _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _hospitals = [];
  List<Map<String, dynamic>> _filteredHospitals = [];

  bool _isLoading = true;
  String _errorMessage = '';

  String _selectedBedType = 'All';

  final List<String> _bedTypes = [
    'All',
    'General',
    'ICU',
    'Emergency',
    'HDU',
    'NICU',
    'Isolation',
  ];

  // ============================================================
  // DEMO BED DATA
  // ============================================================

  final Map<String, Map<String, Map<String, int>>> _demoBedData = {
    'JAN AROGYA Medical Centre': {
      'General': {'available': 18, 'total': 40},
      'ICU': {'available': 4, 'total': 10},
      'Emergency': {'available': 3, 'total': 8},
      'HDU': {'available': 5, 'total': 10},
      'NICU': {'available': 2, 'total': 6},
      'Isolation': {'available': 4, 'total': 8},
    },
    'City Care Hospital': {
      'General': {'available': 12, 'total': 30},
      'ICU': {'available': 2, 'total': 12},
      'Emergency': {'available': 1, 'total': 6},
      'HDU': {'available': 3, 'total': 8},
      'NICU': {'available': 1, 'total': 5},
      'Isolation': {'available': 2, 'total': 7},
    },
    'Government General Hospital': {
      'General': {'available': 0, 'total': 50},
      'ICU': {'available': 0, 'total': 12},
      'Emergency': {'available': 2, 'total': 10},
      'HDU': {'available': 1, 'total': 10},
      'NICU': {'available': 0, 'total': 8},
      'Isolation': {'available': 3, 'total': 12},
    },
    'LifeCare Multispeciality Hospital': {
      'General': {'available': 9, 'total': 25},
      'ICU': {'available': 3, 'total': 8},
      'Emergency': {'available': 2, 'total': 5},
      'HDU': {'available': 2, 'total': 6},
      'NICU': {'available': 2, 'total': 5},
      'Isolation': {'available': 1, 'total': 6},
    },
    'Sunrise Hospital': {
      'General': {'available': 5, 'total': 20},
      'ICU': {'available': 1, 'total': 6},
      'Emergency': {'available': 0, 'total': 4},
      'HDU': {'available': 1, 'total': 5},
      'NICU': {'available': 0, 'total': 4},
      'Isolation': {'available': 2, 'total': 5},
    },
  };

  // ============================================================
  // TRANSLATION
  // ============================================================

  String _t(String en, String hi, String bn) {
    final languageCode =
        Localizations.localeOf(context).languageCode.toLowerCase();

    if (languageCode == 'hi') {
      return hi;
    }

    if (languageCode == 'bn') {
      return bn;
    }

    return en;
  }

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  // ============================================================
  // LOAD HOSPITALS
  // ============================================================

  Future<void> _loadHospitals() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final hospitals = await HospitalService.getNearbyHospitals();

      if (!mounted) return;

      setState(() {
        _hospitals = hospitals;
        _filteredHospitals = hospitals;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _t(
          'Could not load nearby hospitals. Please try again.',
          'नजदीकी अस्पताल लोड नहीं हो सके। कृपया फिर प्रयास करें।',
          'কাছাকাছি হাসপাতাল লোড করা যায়নি। আবার চেষ্টা করুন।',
        );
      });
    }
  }

  // ============================================================
  // BED DATA
  // ============================================================

  Map<String, Map<String, int>> _getBedsForHospital(
    Map<String, dynamic> hospital,
  ) {
    final name = hospital['name']?.toString() ?? '';

    if (_demoBedData.containsKey(name)) {
      return _demoBedData[name]!;
    }

    // Fallback demo data for hospitals coming from API/OSM.
    return {
      'General': {'available': 14, 'total': 35},
      'ICU': {'available': 3, 'total': 10},
      'Emergency': {'available': 2, 'total': 7},
      'HDU': {'available': 3, 'total': 8},
      'NICU': {'available': 1, 'total': 5},
      'Isolation': {'available': 2, 'total': 6},
    };
  }

  Map<String, int> _getBed(
    Map<String, dynamic> hospital,
    String type,
  ) {
    final beds = _getBedsForHospital(hospital);

    return beds[type] ??
        {
          'available': 0,
          'total': 0,
        };
  }

  int _totalAvailable(Map<String, dynamic> hospital) {
    final beds = _getBedsForHospital(hospital);

    return beds.values.fold(
      0,
      (sum, bed) => sum + (bed['available'] ?? 0),
    );
  }

  int _totalBeds(Map<String, dynamic> hospital) {
    final beds = _getBedsForHospital(hospital);

    return beds.values.fold(
      0,
      (sum, bed) => sum + (bed['total'] ?? 0),
    );
  }

  // ============================================================
  // BED FILTER
  // ============================================================

  void _selectBedType(String type) {
    setState(() {
      _selectedBedType = type;
    });

    _applyFilters();
  }

  void _applyFilters() {
    final searchQuery = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredHospitals = _hospitals.where((hospital) {
        final name = hospital['name']?.toString().toLowerCase() ?? '';
        final type = hospital['type']?.toString().toLowerCase() ?? '';
        final address =
            hospital['address']?.toString().toLowerCase() ?? '';

        final matchesSearch = searchQuery.isEmpty ||
            name.contains(searchQuery) ||
            type.contains(searchQuery) ||
            address.contains(searchQuery);

        if (!matchesSearch) {
          return false;
        }

        if (_selectedBedType == 'All') {
          return true;
        }

        final bed = _getBed(hospital, _selectedBedType);

        return (bed['available'] ?? 0) > 0;
      }).toList();
    });
  }

  void _searchHospitals(String query) {
    _applyFilters();
  }

  // ============================================================
  // CALL
  // ============================================================

  Future<void> _callHospital(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      final launched = await launchUrl(phoneUri);

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                'Could not open phone dialer',
                'फोन डायलर नहीं खुल सका',
                'ফোন ডায়ালার খোলা যায়নি',
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Could not open phone dialer',
              'फोन डायलर नहीं खुल सका',
              'ফোন ডায়ালার খোলা যায়নি',
            ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // MAP
  // ============================================================

  Future<void> _openMap(Map<String, dynamic> hospital) async {
    final latitude = (hospital['latitude'] as num?)?.toDouble() ?? 0;
    final longitude = (hospital['longitude'] as num?)?.toDouble() ?? 0;

    final hospitalName =
        hospital['name']?.toString() ?? 'Hospital';

    final Uri mapUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=$latitude,$longitude',
    );

    try {
      final launched = await launchUrl(
        mapUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                'Could not open location for $hospitalName',
                'इस अस्पताल का स्थान नहीं खुल सका',
                'এই হাসপাতালের অবস্থান খোলা যায়নি',
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Could not open Google Maps',
              'Google Maps नहीं खुल सका',
              'Google Maps খোলা যায়নি',
            ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // BED STATUS
  // ============================================================

  Color _bedStatusColor(int available, int total) {
    if (total <= 0 || available <= 0) {
      return Colors.red;
    }

    final percentage = available / total;

    if (percentage <= 0.20) {
      return Colors.orange.shade700;
    }

    return Colors.green.shade600;
  }

  String _bedStatusText(int available, int total) {
    if (total <= 0 || available <= 0) {
      return _t(
        'Full',
        'भरा हुआ',
        'পূর্ণ',
      );
    }

    final percentage = available / total;

    if (percentage <= 0.20) {
      return _t(
        'Limited',
        'सीमित',
        'সীমিত',
      );
    }

    return _t(
      'Available',
      'उपलब्ध',
      'উপলব্ধ',
    );
  }

  IconData _bedIcon(String type) {
    switch (type) {
      case 'ICU':
        return Icons.monitor_heart_rounded;
      case 'Emergency':
        return Icons.emergency_rounded;
      case 'HDU':
        return Icons.health_and_safety_rounded;
      case 'NICU':
        return Icons.child_care_rounded;
      case 'Isolation':
        return Icons.medical_information_rounded;
      default:
        return Icons.bed_rounded;
    }
  }

  // ============================================================
  // BED CHIP
  // ============================================================

  Widget _buildBedChip(
    Map<String, dynamic> hospital,
    String type,
  ) {
    final bed = _getBed(hospital, type);

    final available = bed['available'] ?? 0;
    final total = bed['total'] ?? 0;

    final color = _bedStatusColor(
      available,
      total,
    );

    return Container(
      width: 145,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _bedIcon(type),
                size: 18,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  type,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '$available / $total',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _bedStatusText(
              available,
              total,
            ),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BED AVAILABILITY SECTION
  // ============================================================

  Widget _buildBedAvailability(
    Map<String, dynamic> hospital,
  ) {
    final types = _selectedBedType == 'All'
        ? _bedTypes.skip(1).toList()
        : [_selectedBedType];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        Row(
          children: [
            const Icon(
              Icons.bed_rounded,
              size: 20,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                _t(
                  'Bed Availability',
                  'बेड उपलब्धता',
                  'বেডের প্রাপ্যতা',
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Text(
              _t(
                'Demo Data',
                'डेमो डेटा',
                'ডেমো ডেটা',
              ),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.orange.shade800,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: types.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 9),
            itemBuilder: (context, index) {
              return _buildBedChip(
                hospital,
                types[index],
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HOSPITAL DETAILS
  // ============================================================

  void _showHospitalDetails(
    Map<String, dynamic> hospital,
  ) {
    final name =
        hospital['name']?.toString() ?? 'Hospital';

    final type =
        hospital['type']?.toString() ?? '';

    final address =
        hospital['address']?.toString() ?? '';

    final distance =
        hospital['distance']?.toString() ?? '';

    final phone =
        hospital['phone']?.toString() ?? '';

    final rating =
        (hospital['rating'] as num?)?.toDouble() ?? 0;

    final isOpen =
        hospital['isOpen'] as bool? ?? false;

    final beds = _getBedsForHospital(hospital);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxHeight: 0.90 * 900,
            ),
            padding: const EdgeInsets.fromLTRB(
              24,
              12,
              24,
              32,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.local_hospital_rounded,
                          color: AppTheme.primary,
                          size: 32,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.w800,
                                color:
                                    AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type,
                              style: TextStyle(
                                color:
                                    Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  _buildDetailRow(
                    Icons.location_on_outlined,
                    address.isEmpty
                        ? _t(
                            'Address unavailable',
                            'पता उपलब्ध नहीं है',
                            'ঠিকানা পাওয়া যায়নি',
                          )
                        : address,
                  ),

                  const SizedBox(height: 14),

                  _buildDetailRow(
                    Icons.directions_walk_rounded,
                    distance.isEmpty
                        ? _t(
                            'Distance unavailable',
                            'दूरी उपलब्ध नहीं है',
                            'দূরত্ব পাওয়া যায়নি',
                          )
                        : '$distance ${_t('away', 'दूर', 'দূরে')}',
                  ),

                  const SizedBox(height: 14),

                  _buildDetailRow(
                    Icons.phone_outlined,
                    phone.isEmpty
                        ? _t(
                            'Phone unavailable',
                            'फोन उपलब्ध नहीं है',
                            'ফোন নম্বর পাওয়া যায়নি',
                          )
                        : phone,
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rating > 0
                            ? rating.toStringAsFixed(1)
                            : '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOpen
                              ? _t(
                                  'Open Now',
                                  'अभी खुला है',
                                  'এখন খোলা',
                                )
                              : _t(
                                  'Closed',
                                  'बंद',
                                  'বন্ধ',
                                ),
                          style: TextStyle(
                            color: isOpen
                                ? Colors.green
                                : Colors.red,
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // DEMO WARNING
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.orange.shade200,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.orange.shade800,
                          size: 20,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            _t(
                              'Bed availability shown here is demo data and is not real-time hospital information.',
                              'यहां दिखाई गई बेड उपलब्धता डेमो डेटा है और अस्पताल की वास्तविक समय की जानकारी नहीं है।',
                              'এখানে দেখানো বেডের প্রাপ্যতা ডেমো ডেটা এবং হাসপাতালের রিয়েল-টাইম তথ্য নয়।',
                            ),
                            style: TextStyle(
                              color:
                                  Colors.orange.shade900,
                              fontSize: 11.5,
                              height: 1.35,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    _t(
                      'Bed Availability',
                      'बेड उपलब्धता',
                      'বেডের প্রাপ্যতা',
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...beds.entries.map(
                    (entry) {
                      final available =
                          entry.value['available'] ?? 0;

                      final total =
                          entry.value['total'] ?? 0;

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: _buildDetailedBedRow(
                          entry.key,
                          available,
                          total,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              phone.trim().isEmpty
                                  ? null
                                  : () =>
                                      _callHospital(phone),
                          icon: const Icon(
                            Icons.call_outlined,
                          ),
                          label: Text(
                            _t(
                              'Call',
                              'कॉल',
                              'কল',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _openMap(hospital),
                          icon: const Icon(
                            Icons.map_outlined,
                          ),
                          label: Text(
                            _t(
                              'Directions',
                              'दिशा',
                              'দিকনির্দেশ',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _buildDetailRow(
    IconData icon,
    String text,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.primary,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DETAILED BED ROW
  // ============================================================

  Widget _buildDetailedBedRow(
    String type,
    int available,
    int total,
  ) {
    final color =
        _bedStatusColor(available, total);

    final percentage = total == 0
        ? 0.0
        : available / total;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _bedIcon(type),
                size: 21,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  type,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                '$available / $total',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor:
                  Colors.grey.shade200,
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOSPITAL CARD
  // ============================================================

  Widget _buildHospitalCard(
    Map<String, dynamic> hospital,
  ) {
    final name =
        hospital['name']?.toString() ?? 'Hospital';

    final type =
        hospital['type']?.toString() ?? '';

    final address =
        hospital['address']?.toString() ?? '';

    final distance =
        hospital['distance']?.toString() ?? '';

    final phone =
        hospital['phone']?.toString() ?? '';

    final rating =
        (hospital['rating'] as num?)?.toDouble() ?? 0;

    final isOpen =
        hospital['isOpen'] as bool? ?? false;

    final totalAvailable =
        _totalAvailable(hospital);

    final totalBeds =
        _totalBeds(hospital);

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        borderRadius:
            BorderRadius.circular(24),
        child: InkWell(
          onTap: () =>
              _showHospitalDetails(hospital),
          borderRadius:
              BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE8EDF2),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset:
                      const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ------------------------------------------
                // HOSPITAL HEADER
                // ------------------------------------------

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color:
                            AppTheme.primaryLight,
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .local_hospital_rounded,
                        color:
                            AppTheme.primary,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type.isEmpty
                                ? _t(
                                    'Healthcare facility',
                                    'स्वास्थ्य सुविधा',
                                    'স্বাস্থ্যসেবা কেন্দ্র',
                                  )
                                : type,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color:
                                  Colors.amber,
                              size: 19,
                            ),
                            const SizedBox(
                                width: 3),
                            Text(
                              rating > 0
                                  ? rating
                                      .toStringAsFixed(
                                          1)
                                  : '—',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isOpen
                              ? _t(
                                  'Open',
                                  'खुला',
                                  'খোলা',
                                )
                              : _t(
                                  'Closed',
                                  'बंद',
                                  'বন্ধ',
                                ),
                          style: TextStyle(
                            color: isOpen
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ------------------------------------------
                // ADDRESS
                // ------------------------------------------

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.primary,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address.isEmpty
                            ? _t(
                                'Address unavailable',
                                'पता उपलब्ध नहीं है',
                                'ঠিকানা পাওয়া যায়নি',
                              )
                            : address,
                        maxLines: 3,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ------------------------------------------
                // BED SUMMARY
                // ------------------------------------------

                Container(
                  padding:
                      const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFF7FAFC),
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color:
                          Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.bed_rounded,
                            size: 20,
                            color:
                                AppTheme.primary,
                          ),
                          const SizedBox(
                              width: 7),
                          Expanded(
                            child: Text(
                              _t(
                                'Bed Availability',
                                'बेड उपलब्धता',
                                'বেডের প্রাপ্যতা',
                              ),
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w900,
                                fontSize: 14,
                                color:
                                    AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .orange
                                  .shade50,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                8,
                              ),
                            ),
                            child: Text(
                              _t(
                                'DEMO',
                                'डेमो',
                                'ডেমো',
                              ),
                              style: TextStyle(
                                color: Colors
                                    .orange
                                    .shade800,
                                fontSize: 9,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '$totalAvailable / $totalBeds ${_t('beds available', 'बेड उपलब्ध', 'বেড উপলব্ধ')}',
                        style: TextStyle(
                          color:
                              totalAvailable == 0
                                  ? Colors.red
                                  : AppTheme
                                      .primary,
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: 86,
                        child:
                            ListView.separated(
                          scrollDirection:
                              Axis.horizontal,
                          itemCount:
                              _selectedBedType ==
                                      'All'
                                  ? 6
                                  : 1,
                          separatorBuilder:
                              (_, __) =>
                                  const SizedBox(
                                      width: 8),
                          itemBuilder:
                              (context, index) {
                            final type =
                                _selectedBedType ==
                                        'All'
                                    ? _bedTypes[
                                        index + 1]
                                    : _selectedBedType;

                            final bed =
                                _getBed(
                              hospital,
                              type,
                            );

                            final available =
                                bed['available'] ??
                                    0;

                            final total =
                                bed['total'] ?? 0;

                            final color =
                                _bedStatusColor(
                              available,
                              total,
                            );

                            return Container(
                              width: 112,
                              padding:
                                  const EdgeInsets
                                      .all(10),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                                border:
                                    Border.all(
                                  color: Colors
                                      .grey
                                      .shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _bedIcon(
                                            type),
                                        size: 16,
                                        color:
                                            AppTheme
                                                .primary,
                                      ),
                                      const SizedBox(
                                          width: 5),
                                      Expanded(
                                        child:
                                            Text(
                                          type,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                10,
                                            fontWeight:
                                                FontWeight
                                                    .w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: 7),
                                  Text(
                                    '$available/$total',
                                    style:
                                        TextStyle(
                                      color:
                                          color,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _t(
                          'Demo data • Not real-time availability',
                          'डेमो डेटा • वास्तविक समय की उपलब्धता नहीं',
                          'ডেমো ডেটা • রিয়েল-টাইম প্রাপ্যতা নয়',
                        ),
                        style: TextStyle(
                          color:
                              Colors.grey.shade500,
                          fontSize: 9.5,
                          fontStyle:
                              FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ------------------------------------------
                // ACTION ROW
                // ------------------------------------------

                const Divider(),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons
                          .directions_walk_rounded,
                      size: 18,
                      color:
                          Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        distance.isEmpty
                            ? _t(
                                'Distance unavailable',
                                'दूरी उपलब्ध नहीं है',
                                'দূরত্ব পাওয়া যায়নি',
                              )
                            : distance,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              Colors.grey.shade700,
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed:
                          phone.trim().isEmpty
                              ? null
                              : () =>
                                  _callHospital(
                                      phone),
                      icon: const Icon(
                        Icons.call_outlined,
                        color:
                            AppTheme.primary,
                      ),
                      tooltip: _t(
                        'Call Hospital',
                        'अस्पताल को कॉल करें',
                        'হাসপাতালে কল করুন',
                      ),
                    ),

                    IconButton(
                      onPressed: () =>
                          _openMap(hospital),
                      icon: const Icon(
                        Icons
                            .directions_outlined,
                        color:
                            AppTheme.primary,
                      ),
                      tooltip: _t(
                        'Get Directions',
                        'दिशा प्राप्त करें',
                        'দিকনির্দেশ পান',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color:
                    AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppTheme.primary,
                size: 44,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              _t(
                'No Hospitals Found',
                'कोई अस्पताल नहीं मिला',
                'কোনও হাসপাতাল পাওয়া যায়নি',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.w800,
                color:
                    AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              _t(
                'Try searching with a different hospital name or speciality.',
                'किसी दूसरे अस्पताल के नाम या विशेषज्ञता से खोजें।',
                'অন্য হাসপাতালের নাম বা বিশেষত্ব দিয়ে খুঁজুন।',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 54,
            ),

            const SizedBox(height: 16),

            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                    AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _loadHospitals,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: Text(
                _t(
                  'Try Again',
                  'फिर प्रयास करें',
                  'আবার চেষ্টা করুন',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BED FILTER BAR
  // ============================================================

  Widget _buildBedFilter() {
    return SizedBox(
      height: 43,
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        scrollDirection:
            Axis.horizontal,
        itemCount: _bedTypes.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type =
              _bedTypes[index];

          final selected =
              _selectedBedType == type;

          return ChoiceChip(
            selected: selected,
            label: Text(
              type == 'All'
                  ? _t(
                      'All Beds',
                      'सभी बेड',
                      'সব বেড',
                    )
                  : type,
            ),
            selectedColor:
                AppTheme.primary,
            backgroundColor:
                Colors.white,
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : AppTheme.textPrimary,
              fontWeight:
                  FontWeight.w700,
              fontSize: 12,
            ),
            side: BorderSide(
              color: selected
                  ? AppTheme.primary
                  : Colors.grey.shade300,
            ),
            onSelected: (_) =>
                _selectBedType(type),
          );
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: Text(
          _t(
            'Nearby Hospitals',
            'नजदीकी अस्पताल',
            'কাছাকাছি হাসপাতাল',
          ),
          style: const TextStyle(
            fontWeight:
                FontWeight.w800,
            color:
                AppTheme.textPrimary,
          ),
        ),
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        iconTheme:
            const IconThemeData(
          color:
              AppTheme.textPrimary,
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ------------------------------------------
            // SEARCH
            // ------------------------------------------

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                10,
              ),
              child: TextField(
                controller:
                    _searchController,
                onChanged:
                    _searchHospitals,
                decoration:
                    InputDecoration(
                  hintText: _t(
                    'Search hospitals, clinics or speciality',
                    'अस्पताल, क्लिनिक या विशेषज्ञता खोजें',
                    'হাসপাতাল, ক্লিনিক বা বিশেষত্ব খুঁজুন',
                  ),
                  prefixIcon:
                      const Icon(
                    Icons.search_rounded,
                    color:
                        AppTheme.primary,
                  ),
                  suffixIcon:
                      _searchController
                              .text
                              .isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController
                                    .clear();
                                _searchHospitals(
                                    '');
                                setState(() {});
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .clear_rounded,
                              ),
                            )
                          : null,
                  filled: true,
                  fillColor:
                      Colors.white,
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                    borderSide:
                        BorderSide(
                      color: Colors
                          .grey.shade200,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          AppTheme.primary,
                      width: 1.3,
                    ),
                  ),
                ),
              ),
            ),

            // ------------------------------------------
            // DEMO WARNING
            // ------------------------------------------

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                4,
                20,
                8,
              ),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  11,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.orange.shade50,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                  border:
                      Border.all(
                    color:
                        Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color:
                          Colors.orange.shade800,
                    ),
                    const SizedBox(
                        width: 8),
                    Expanded(
                      child: Text(
                        _t(
                          'Bed availability is demo data and is not real-time.',
                          'बेड उपलब्धता डेमो डेटा है और वास्तविक समय की जानकारी नहीं है।',
                          'বেডের প্রাপ্যতা ডেমো ডেটা এবং রিয়েল-টাইম নয়।',
                        ),
                        style:
                            TextStyle(
                          color: Colors
                              .orange
                              .shade900,
                          fontSize: 10.5,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ------------------------------------------
            // BED FILTER
            // ------------------------------------------

            Padding(
              padding:
                  const EdgeInsets.only(
                top: 5,
                bottom: 9,
              ),
              child:
                  _buildBedFilter(),
            ),

            // ------------------------------------------
            // COUNT
            // ------------------------------------------

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                2,
                20,
                12,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .location_on_rounded,
                    color:
                        AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(
                      width: 8),
                  Expanded(
                    child: Text(
                      '${_filteredHospitals.length} ${_t(
                        'healthcare facilities nearby',
                        'नजदीकी स्वास्थ्य सुविधाएं',
                        'কাছাকাছি স্বাস্থ্যসেবা কেন্দ্র',
                      )}',
                      style: TextStyle(
                        color:
                            Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------------
            // CONTENT
            // ------------------------------------------

            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            AppTheme.primary,
                      ),
                    )
                  : _errorMessage
                          .isNotEmpty
                      ? _buildErrorState()
                      : _filteredHospitals
                              .isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh:
                                  _loadHospitals,
                              color:
                                  AppTheme.primary,
                              child:
                                  ListView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(
                                  parent:
                                      BouncingScrollPhysics(),
                                ),
                                padding:
                                    const EdgeInsets
                                        .fromLTRB(
                                  20,
                                  0,
                                  20,
                                  32,
                                ),
                                itemCount:
                                    _filteredHospitals
                                        .length,
                                itemBuilder:
                                    (context,
                                        index) {
                                  return _buildHospitalCard(
                                    _filteredHospitals[
                                        index],
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}