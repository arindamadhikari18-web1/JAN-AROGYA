import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../services/hospital_service.dart';

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() =>
      _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState
    extends State<NearbyHospitalsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  List<Map<String, dynamic>> _hospitals = [];
  List<Map<String, dynamic>> _filteredHospitals = [];

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  // =====================================================
  // LOAD HOSPITALS
  // =====================================================

  Future<void> _loadHospitals() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final hospitals =
          await HospitalService.getNearbyHospitals();

      if (!mounted) return;

      setState(() {
        _hospitals = hospitals;
        _filteredHospitals = hospitals;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Could not load nearby hospitals. Please try again.';
      });
    }
  }

  // =====================================================
  // SEARCH HOSPITALS
  // =====================================================

  void _searchHospitals(String query) {
    final searchQuery = query.toLowerCase().trim();

    setState(() {
      if (searchQuery.isEmpty) {
        _filteredHospitals = _hospitals;
        return;
      }

      _filteredHospitals = _hospitals.where((hospital) {
        final name =
            hospital['name']?.toString().toLowerCase() ?? '';

        final type =
            hospital['type']?.toString().toLowerCase() ?? '';

        final address =
            hospital['address']?.toString().toLowerCase() ?? '';

        return name.contains(searchQuery) ||
            type.contains(searchQuery) ||
            address.contains(searchQuery);
      }).toList();
    });
  }

  // =====================================================
  // CALL HOSPITAL
  // =====================================================

  Future<void> _callHospital(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      final bool launched =
          await launchUrl(phoneUri);

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open phone dialer'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open phone dialer'),
        ),
      );
    }
  }

  // =====================================================
  // OPEN GOOGLE MAPS
  // =====================================================

  Future<void> _openMap(
    Map<String, dynamic> hospital,
  ) async {
    final double latitude =
        (hospital['latitude'] as num?)?.toDouble() ?? 0;

    final double longitude =
        (hospital['longitude'] as num?)?.toDouble() ?? 0;

    final String hospitalName =
        hospital['name']?.toString() ?? 'Hospital';

    final Uri mapUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=$latitude,$longitude',
    );

    try {
      final bool launched = await launchUrl(
        mapUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open location for $hospitalName',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Google Maps'),
        ),
      );
    }
  }

  // =====================================================
  // SHOW HOSPITAL DETAILS
  // =====================================================

  void _showHospitalDetails(
    Map<String, dynamic> hospital,
  ) {
    final String name =
        hospital['name']?.toString() ?? 'Hospital';

    final String type =
        hospital['type']?.toString() ?? '';

    final String address =
        hospital['address']?.toString() ?? '';

    final String distance =
        hospital['distance']?.toString() ?? '';

    final String phone =
        hospital['phone']?.toString() ?? '';

    final double rating =
        (hospital['rating'] as num?)?.toDouble() ?? 0;

    final bool isOpen =
        hospital['isOpen'] as bool? ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          width: double.infinity,
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
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            type,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildDetailRow(
                  Icons.location_on_outlined,
                  address,
                ),

                const SizedBox(height: 16),

                _buildDetailRow(
                  Icons.directions_walk_rounded,
                  '$distance away',
                ),

                const SizedBox(height: 16),

                _buildDetailRow(
                  Icons.phone_outlined,
                  phone,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 22,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      '$rating Rating',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(width: 24),

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
                        isOpen ? 'Open Now' : 'Closed',
                        style: TextStyle(
                          color: isOpen
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: phone.isEmpty
                            ? null
                            : () {
                                _callHospital(phone);
                              },
                        icon: const Icon(
                          Icons.call_outlined,
                        ),
                        label: const Text('Call'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _openMap(hospital);
                        },
                        icon: const Icon(
                          Icons.map_outlined,
                        ),
                        label: const Text('Directions'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // DETAIL ROW
  // =====================================================

  Widget _buildDetailRow(
    IconData icon,
    String text,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  // =====================================================
  // HOSPITAL CARD
  // =====================================================

  Widget _buildHospitalCard(
    Map<String, dynamic> hospital,
  ) {
    final String name =
        hospital['name']?.toString() ?? 'Hospital';

    final String type =
        hospital['type']?.toString() ?? '';

    final String address =
        hospital['address']?.toString() ?? '';

    final String distance =
        hospital['distance']?.toString() ?? '';

    final String phone =
        hospital['phone']?.toString() ?? '';

    final double rating =
        (hospital['rating'] as num?)?.toDouble() ?? 0;

    final bool isOpen =
        hospital['isOpen'] as bool? ?? false;

    return InkWell(
      onTap: () {
        _showHospitalDetails(hospital);
      },
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE8EDF2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    color: AppTheme.primary,
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
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        type,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
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
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 19,
                        ),

                        const SizedBox(width: 3),

                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        color: isOpen
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

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
                    address,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.directions_walk_rounded,
                  size: 18,
                  color: Colors.grey.shade600,
                ),

                const SizedBox(width: 6),

                Text(
                  distance,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),

                const Spacer(),

                IconButton(
                  onPressed: phone.isEmpty
                      ? null
                      : () {
                          _callHospital(phone);
                        },
                  icon: const Icon(
                    Icons.call_outlined,
                    color: AppTheme.primary,
                  ),
                  tooltip: 'Call Hospital',
                ),

                IconButton(
                  onPressed: () {
                    _openMap(hospital);
                  },
                  icon: const Icon(
                    Icons.directions_outlined,
                    color: AppTheme.primary,
                  ),
                  tooltip: 'Get Directions',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================

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
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppTheme.primary,
                size: 44,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No Hospitals Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Try searching with a different hospital name or speciality.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
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
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _loadHospitals,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
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

  // =====================================================
  // MAIN UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Nearby Hospitals',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppTheme.textPrimary,
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // =====================================================
            // SEARCH BAR
            // =====================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                10,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchHospitals,
                decoration: InputDecoration(
                  hintText:
                      'Search hospitals, clinics or speciality',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.primary,
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _searchHospitals('');
                              },
                              icon: const Icon(
                                Icons.clear_rounded,
                              ),
                            )
                          : null,
                ),
              ),
            ),

            // =====================================================
            // HEADER
            // =====================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                16,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      '${_filteredHospitals.length} healthcare facilities nearby',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: _loadHospitals,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // CONTENT
            // =====================================================

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                      ),
                    )
                  : _errorMessage.isNotEmpty
                      ? _buildErrorState()
                      : _filteredHospitals.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadHospitals,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  32,
                                ),
                                itemCount:
                                    _filteredHospitals.length,
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  return _buildHospitalCard(
                                    _filteredHospitals[index],
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
}