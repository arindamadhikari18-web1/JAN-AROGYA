import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/health_record_service.dart';

class AddHealthRecordScreen extends StatefulWidget {
  const AddHealthRecordScreen({super.key});

  @override
  State<AddHealthRecordScreen> createState() =>
      _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  String? _selectedRecordType;
  DateTime? _selectedDate;

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  bool _isSaving = false;

  final List<Map<String, dynamic>> _recordTypes = [
    {
      'name': 'Prescription',
      'icon': Icons.medical_services_rounded,
    },
    {
      'name': 'Test Report',
      'icon': Icons.science_rounded,
    },
    {
      'name': 'X-Ray',
      'icon': Icons.document_scanner_rounded,
    },
    {
      'name': 'Vaccination',
      'icon': Icons.vaccines_rounded,
    },
    {
      'name': 'Medical Certificate',
      'icon': Icons.description_rounded,
    },
    {
      'name': 'Other',
      'icon': Icons.folder_rounded,
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // =====================================================
  // SELECT DATE
  // =====================================================

  Future<void> _selectDate() async {
    final DateTime today = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  String get _formattedDate {
    if (_selectedDate == null) {
      return 'Select record date';
    }

    return '${_selectedDate!.day.toString().padLeft(2, '0')}/'
        '${_selectedDate!.month.toString().padLeft(2, '0')}/'
        '${_selectedDate!.year}';
  }

  // =====================================================
  // SAVE HEALTH RECORD
  // =====================================================

  Future<void> _saveHealthRecord() async {
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();

    if (_selectedRecordType == null ||
        title.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select record type, enter title and select date',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bool isSaved =
        await HealthRecordService.saveHealthRecord(
      recordType: _selectedRecordType!,
      title: title,
      date: _formattedDate,
      description: description,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health record saved successfully'),
        ),
      );

      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save health record. Please try again.',
          ),
        ),
      );
    }
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
          'Add Health Record',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Keep your health information organised',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                'Add your prescriptions, reports and other important medical records.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
              ),

              const SizedBox(height: 28),

              Text(
                'Record Type',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _recordTypes.map((record) {
                  final String name = record['name'] as String;
                  final IconData icon =
                      record['icon'] as IconData;

                  final bool isSelected =
                      _selectedRecordType == name;

                  return ChoiceChip(
                    avatar: Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.grey,
                    ),
                    label: Text(name),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryLight,
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primary
                          : const Color(0xFFE2E8F0),
                    ),
                    onSelected: _isSaving
                        ? null
                        : (selected) {
                            setState(() {
                              _selectedRecordType =
                                  selected ? name : null;
                            });
                          },
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              Text(
                'Record Title',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _titleController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  hintText: 'Example: Blood Test Report',
                  prefixIcon: Icon(
                    Icons.title_rounded,
                    color: AppTheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Record Date',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(height: 10),

              InkWell(
                onTap: _isSaving ? null : _selectDate,
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8EDF2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: AppTheme.primary,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          _formattedDate,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _selectedDate == null
                                ? Colors.grey
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Description (Optional)',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _descriptionController,
                enabled: !_isSaving,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Add notes or important details about this record...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : _saveHealthRecord,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.save_rounded,
                        ),
                  label: Text(
                    _isSaving
                        ? 'Saving Record...'
                        : 'Save Health Record',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}