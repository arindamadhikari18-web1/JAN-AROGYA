import 'package:flutter/material.dart';

class LabTestsScreen extends StatefulWidget {
  const LabTestsScreen({super.key});

  @override
  State<LabTestsScreen> createState() => _LabTestsScreenState();
}

class _LabTestsScreenState extends State<LabTestsScreen> {
  static const Color primary = Color(0xFF00796B);
  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF62758A);
  static const Color background = Color(0xFFF7FAF9);

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<Map<String, dynamic>> _tests = const [
    {
      'name': 'Complete Blood Count (CBC)',
      'category': 'Blood Test',
      'price': 399,
      'report': '6–12 hours',
      'home': true,
      'icon': Icons.bloodtype_outlined,
    },
    {
      'name': 'Blood Sugar / HbA1c',
      'category': 'Diabetes',
      'price': 499,
      'report': '12–24 hours',
      'home': true,
      'icon': Icons.water_drop_outlined,
    },
    {
      'name': 'Lipid Profile',
      'category': 'Heart Health',
      'price': 699,
      'report': '24 hours',
      'home': true,
      'icon': Icons.favorite_border_rounded,
    },
    {
      'name': 'Thyroid Profile',
      'category': 'Hormones',
      'price': 599,
      'report': '24 hours',
      'home': true,
      'icon': Icons.science_outlined,
    },
    {
      'name': 'Liver Function Test',
      'category': 'Liver',
      'price': 799,
      'report': '24 hours',
      'home': false,
      'icon': Icons.biotech_outlined,
    },
    {
      'name': 'Kidney Function Test',
      'category': 'Kidney',
      'price': 749,
      'report': '24 hours',
      'home': false,
      'icon': Icons.health_and_safety_outlined,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTests {
    if (_query.trim().isEmpty) return _tests;
    final q = _query.toLowerCase().trim();
    return _tests.where((test) {
      return test['name'].toString().toLowerCase().contains(q) ||
          test['category'].toString().toLowerCase().contains(q);
    }).toList();
  }

  void _bookTest(Map<String, dynamic> test) {
    final name = test['name'].toString();
    final price = test['price'];
    final home = test['home'] == true;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Book Lab Test',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 18),
                _optionTile(
                  icon: Icons.home_work_outlined,
                  title: 'Sample collection',
                  subtitle: home
                      ? 'Home collection available'
                      : 'Visit partner lab for collection',
                ),
                const SizedBox(height: 10),
                _optionTile(
                  icon: Icons.currency_rupee_rounded,
                  title: 'Estimated price',
                  subtitle: '₹$price',
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$name booking request created.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirm Booking'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8F6),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tests = _filteredTests;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Lab Tests'),
        backgroundColor: background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: primary,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE6F8F3), Color(0xFFD9F0FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Search • Compare • Book', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                        SizedBox(height: 7),
                        Text('Find common tests, compare estimated prices and request sample collection.', style: TextStyle(height: 1.35, color: textSecondary)),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.biotech_rounded, size: 48, color: primary),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search any lab test',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Available Tests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                const Spacer(),
                Text('${tests.length} tests', style: const TextStyle(color: textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            if (tests.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 48, color: textSecondary),
                    SizedBox(height: 10),
                    Text('No matching test found', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
                  ],
                ),
              )
            else
              ...tests.map(_buildTestCard),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test) {
    final int price = test['price'] as int;
    final bool home = test['home'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE0ECE8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.025), blurRadius: 12, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFCEAF2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(test['icon'] as IconData, color: const Color(0xFFE64A7B)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test['name'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 5),
                Text(test['category'].toString(), style: const TextStyle(fontSize: 12, color: textSecondary)),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 7,
                  runSpacing: 5,
                  children: [
                    _smallTag('₹$price'),
                    _smallTag(test['report'].toString()),
                    if (home) _smallTag('Home collection'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Book test',
            onPressed: () => _bookTest(test),
            icon: const Icon(Icons.arrow_forward_rounded, color: primary),
          ),
        ],
      ),
    );
  }

  Widget _smallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: textSecondary)),
    );
  }
}
