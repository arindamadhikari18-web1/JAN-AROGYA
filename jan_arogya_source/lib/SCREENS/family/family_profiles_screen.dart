import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/family_service.dart';

class FamilyProfilesScreen extends StatefulWidget {
  const FamilyProfilesScreen({super.key});

  @override
  State<FamilyProfilesScreen> createState() =>
      _FamilyProfilesScreenState();
}

class _FamilyProfilesScreenState extends State<FamilyProfilesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _familyMembers = [];

  final List<String> _relations = [
    'Father',
    'Mother',
    'Spouse',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Grandfather',
    'Grandmother',
    'Other',
  ];

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  // =====================================================
  // LOAD FAMILY MEMBERS
  // =====================================================

  Future<void> _loadFamilyMembers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final members =
        await FamilyService.getFamilyMembers();

    if (!mounted) return;

    setState(() {
      _familyMembers = members;
      _isLoading = false;
    });
  }

  // =====================================================
  // ADD / EDIT FAMILY MEMBER SHEET
  // =====================================================

  void _showMemberSheet({
    Map<String, dynamic>? member,
  }) {
    final bool isEditing = member != null;

    final nameController = TextEditingController(
      text: member?['name']?.toString() ?? '',
    );

    final ageController = TextEditingController(
      text: member?['age']?.toString() ?? '',
    );

    final cityController = TextEditingController(
      text: member?['city']?.toString() ?? '',
    );

    String selectedRelation =
        member?['relation']?.toString() ?? 'Father';

    String selectedGender =
        member?['gender']?.toString() ?? 'Male';

    String selectedBloodGroup =
        member?['bloodGroup']?.toString() ?? 'Unknown';

    // Prevent DropdownButton error if old data has another value
    if (!_relations.contains(selectedRelation)) {
      selectedRelation = 'Other';
    }

    if (!_genders.contains(selectedGender)) {
      selectedGender = 'Other';
    }

    if (!_bloodGroups.contains(selectedBloodGroup)) {
      selectedBloodGroup = 'Unknown';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 40,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  24,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Text(
                        isEditing
                            ? 'Edit Family Member'
                            : 'Add Family Member',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),

                      const SizedBox(height: 22),

                      // NAME
                      TextField(
                        controller: nameController,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // RELATION
                      DropdownButtonFormField<String>(
                        value: selectedRelation,
                        decoration: const InputDecoration(
                          labelText: 'Relation',
                          prefixIcon: Icon(
                            Icons.family_restroom_rounded,
                          ),
                        ),
                        items: _relations.map((relation) {
                          return DropdownMenuItem(
                            value: relation,
                            child: Text(relation),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setSheetState(() {
                            selectedRelation = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // AGE
                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          prefixIcon: Icon(
                            Icons.cake_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // GENDER
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(
                            Icons.people_outline_rounded,
                          ),
                        ),
                        items: _genders.map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setSheetState(() {
                            selectedGender = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // BLOOD GROUP
                      DropdownButtonFormField<String>(
                        value: selectedBloodGroup,
                        decoration: const InputDecoration(
                          labelText: 'Blood Group',
                          prefixIcon: Icon(
                            Icons.bloodtype_outlined,
                          ),
                        ),
                        items:
                            _bloodGroups.map((bloodGroup) {
                          return DropdownMenuItem(
                            value: bloodGroup,
                            child: Text(bloodGroup),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setSheetState(() {
                            selectedBloodGroup = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // CITY
                      TextField(
                        controller: cityController,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          prefixIcon: Icon(
                            Icons.location_city_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () async {
                            final name =
                                nameController.text.trim();

                            final age =
                                ageController.text.trim();

                            final city =
                                cityController.text.trim();

                            if (name.isEmpty ||
                                age.isEmpty ||
                                city.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill all required fields',
                                  ),
                                ),
                              );
                              return;
                            }

                            bool success;

                            if (isEditing) {
                              success = await FamilyService
                                  .updateFamilyMember(
                                id: member['id'].toString(),
                                name: name,
                                age: age,
                                gender: selectedGender,
                                bloodGroup:
                                    selectedBloodGroup,
                                city: city,
                                relation:
                                    selectedRelation,
                              );
                            } else {
                              success = await FamilyService
                                  .addFamilyMember(
                                name: name,
                                age: age,
                                gender: selectedGender,
                                bloodGroup:
                                    selectedBloodGroup,
                                city: city,
                                relation:
                                    selectedRelation,
                              );
                            }

                            if (!mounted) return;

                            if (success) {
                              Navigator.of(sheetContext).pop();

                              await _loadFamilyMembers();

                              if (!mounted) return;

                              ScaffoldMessenger.of(this.context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? 'Family member updated successfully'
                                        : 'Family member added successfully',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(this.context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Something went wrong. Please try again.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            isEditing
                                ? 'Update Member'
                                : 'Add Member',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =====================================================
  // DELETE FAMILY MEMBER
  // =====================================================

  Future<void> _deleteMember(
    Map<String, dynamic> member,
  ) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Family Member'),
          content: Text(
            'Are you sure you want to remove '
            '${member['name']} from your family profiles?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final success =
        await FamilyService.deleteFamilyMember(
      member['id'].toString(),
    );

    if (!mounted) return;

    if (success) {
      await _loadFamilyMembers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${member['name']} removed successfully',
          ),
        ),
      );
    }
  }

  // =====================================================
  // MEMBER CARD
  // =====================================================

  Widget _buildMemberCard(
    Map<String, dynamic> member,
  ) {
    final String name =
        member['name']?.toString() ?? 'Family Member';

    final String relation =
        member['relation']?.toString() ?? 'Family Member';

    final String age =
        member['age']?.toString() ?? '-';

    final String gender =
        member['gender']?.toString() ?? '-';

    final String bloodGroup =
        member['bloodGroup']?.toString() ?? 'Unknown';

    final String city =
        member['city']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8EDF2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppTheme.primary,
                    size: 28,
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
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w800,
                            ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        relation,
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showMemberSheet(
                        member: member,
                      );
                    }

                    if (value == 'delete') {
                      _deleteMember(member);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                          ),
                          SizedBox(width: 10),
                          Text('Remove'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.cake_outlined,
                    '$age Years',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.people_outline_rounded,
                    gender,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.bloodtype_rounded,
                    bloodGroup,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.location_on_outlined,
                    city,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // INFO ITEM
  // =====================================================

  Widget _buildInfoItem(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
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
          'Family Health Profiles',
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showMemberSheet();
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(
          Icons.person_add_alt_1_rounded,
          color: Colors.white,
        ),
        label: const Text(
          'Add Member',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadFamilyMembers,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                ),
              )
            : _familyMembers.isEmpty
                ? ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 90),

                      Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius:
                                BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.family_restroom_rounded,
                            size: 46,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Center(
                        child: Text(
                          'No Family Members Added',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Center(
                        child: Text(
                          'Add your family members to manage their healthcare profiles in one place.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: () {
                          _showMemberSheet();
                        },
                        icon: const Icon(
                          Icons.add_rounded,
                        ),
                        label: const Text(
                          'Add First Family Member',
                        ),
                      ),
                    ],
                  )
                : ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      100,
                    ),
                    children: [
                      // HEADER CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withOpacity(
                                  0.15,
                                ),
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.family_restroom_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Your Family',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    '${_familyMembers.length} family '
                                    'member${_familyMembers.length == 1 ? '' : 's'} added',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withOpacity(0.85),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      Text(
                        'Family Members',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),

                      const SizedBox(height: 16),

                      ..._familyMembers.map(
                        _buildMemberCard,
                      ),
                    ],
                  ),
      ),
    );
  }
}