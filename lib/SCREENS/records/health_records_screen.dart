import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../services/app_text.dart';

class HealthRecordsScreen extends StatefulWidget {
  HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {

  String _t(String en, String hi, String bn) => AppText.t(context, en, hi, bn);
  static String _storageKey = 'health_records';

  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;

  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  // =====================================================
  // LOAD RECORDS FROM SHARED PREFERENCES
  // =====================================================

  Future<void> _loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? savedRecords =
          prefs.getString(_storageKey);

      if (savedRecords != null && savedRecords.isNotEmpty) {
        final List<dynamic> decoded =
            jsonDecode(savedRecords);

        _records = decoded
            .map<Map<String, dynamic>>(
              (record) =>
                  Map<String, dynamic>.from(record as Map),
            )
            .toList();
      } else {
        _records = [];
      }
    } catch (e) {
      debugPrint('Error loading health records: $e');

      _records = [];
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // =====================================================
  // SAVE RECORDS PERMANENTLY
  // =====================================================

  Future<bool> _saveRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String encodedRecords =
          jsonEncode(_records);

      return await prefs.setString(
        _storageKey,
        encodedRecords,
      );
    } catch (e) {
      debugPrint('Error saving health records: $e');
      return false;
    }
  }

  // =====================================================
  // GET ICON NAME
  // =====================================================

  String _getIconName(String type) {
    if (type == 'Prescription') {
      return 'prescription';
    }

    if (type == 'Medical Record') {
      return 'medical';
    }

    return 'lab';
  }

  // =====================================================
  // GET RECORD ICON
  // =====================================================

  IconData _getRecordIcon(String type) {
    if (type == 'Prescription') {
      return Icons.description_rounded;
    }

    if (type == 'Medical Record') {
      return Icons.health_and_safety_rounded;
    }

    return Icons.science_rounded;
  }

  // =====================================================
  // PICK IMAGE
  // =====================================================

  Future<void> _pickReportImage(
    ImageSource source,
    Function(String) onSelected,
  ) async {
    try {
      final XFile? image =
          await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        onSelected(image.path);
      }
    } catch (e) {
      debugPrint('Image picker error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t('Could not select image. Please try again.', 'रिपोर्ट चुन नहीं सके। कृपया फिर प्रयास करें।', 'রিপোর্ট নির্বাচন করা যায়নি। আবার চেষ্টা করুন।'),
          ),
        ),
      );
    }
  }

  // =====================================================
  // CAMERA / GALLERY OPTIONS
  // =====================================================

  void _showImageOptions(
    Function(String) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  _t('Upload Report Photo', 'रिपोर्ट की फोटो अपलोड करें', 'রিপোর্টের ছবি আপলোড করুন'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  _t('Choose how you want to add your report.', 'रिपोर्ट कैसे जोड़ना चाहते हैं चुनें।', 'রিপোর্ট কীভাবে যোগ করবেন তা বেছে নিন।'),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 18),

                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  title: Text(
                    _t('Take Photo', 'फोटो लें', 'ছবি তুলুন'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    _t('Use your camera to scan the report', 'रिपोर्ट स्कैन करने के लिए कैमरे का उपयोग करें', 'রিপোর্ট স্ক্যান করতে ক্যামেরা ব্যবহার করুন'),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    await _pickReportImage(
                      ImageSource.camera,
                      onSelected,
                    );
                  },
                ),

                SizedBox(height: 8),

                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  title: Text(
                    _t('Choose from Gallery', 'गैलरी से चुनें', 'গ্যালারি থেকে বেছে নিন'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    _t('Select an existing report image', 'मौजूदा रिपोर्ट फोटो चुनें', 'আগের রিপোর্টের ছবি বেছে নিন'),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    await _pickReportImage(
                      ImageSource.gallery,
                      onSelected,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // ADD HEALTH RECORD
  // =====================================================

  void _addRecord() {
    final titleController =
        TextEditingController();

    final subtitleController =
        TextEditingController();

    String selectedType = _t('Lab Report', 'लैब रिपोर्ट', 'ল্যাব রিপোর্ট');
    String? selectedImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 30,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  24,
                  14,
                  24,
                  32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // DRAG HANDLE
                      Center(
                        child: Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      Text(
                        _t('Add Health Record', 'स्वास्थ्य रिकॉर्ड जोड़ें', 'স্বাস্থ্য রেকর্ড যোগ করুন'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        _t('Add important details and upload your health report.', 'महत्वपूर्ण जानकारी जोड़ें और स्वास्थ्य रिपोर्ट अपलोड करें।', 'গুরুত্বপূর্ণ তথ্য যোগ করুন এবং স্বাস্থ্য রিপোর্ট আপলোড করুন।'),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: 24),

                      // RECORD TITLE
                      Text(
                        _t('Record Title', 'रिकॉर्ड का शीर्षक', 'রেকর্ডের শিরোনাম'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      SizedBox(height: 8),

                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText:
                              _t('Example: Blood Test Report', 'उदाहरण: ब्लड टेस्ट रिपोर्ट', 'উদাহরণ: ব্লাড টেস্ট রিপোর্ট'),
                          prefixIcon: Icon(
                            Icons.folder_outlined,
                          ),
                        ),
                      ),

                      SizedBox(height: 18),

                      // DESCRIPTION
                      Text(
                        _t('Description', 'विवरण', 'বিবরণ'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      SizedBox(height: 8),

                      TextField(
                        controller: subtitleController,
                        decoration: InputDecoration(
                          hintText:
                              _t('Example: Complete Blood Count', 'उदाहरण: कम्प्लीट ब्लड काउंट', 'উদাহরণ: কমপ্লিট ব্লাড কাউন্ট'),
                          prefixIcon: Icon(
                            Icons.notes_rounded,
                          ),
                        ),
                      ),

                      SizedBox(height: 18),

                      // RECORD TYPE
                      Text(
                        _t('Record Type', 'रिकॉर्ड प्रकार', 'রেকর্ডের ধরন'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.category_outlined,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: _t('Lab Report', 'लैब रिपोर्ट', 'ল্যাব রিপোর্ট'),
                            child: Text(_t('Lab Report', 'लैब रिपोर्ट', 'ল্যাব রিপোর্ট')),
                          ),
                          DropdownMenuItem(
                            value: 'Prescription',
                            child: Text('Prescription'),
                          ),
                          DropdownMenuItem(
                            value: 'Medical Record',
                            child: Text('Medical Record'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setModalState(() {
                            selectedType = value;
                          });
                        },
                      ),

                      SizedBox(height: 22),

                      // REPORT PHOTO
                      Text(
                        _t('Report Photo', 'रिपोर्ट फोटो', 'রিপোর্টের ছবি'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      SizedBox(height: 10),

                      InkWell(
                        onTap: () {
                          _showImageOptions(
                            (imagePath) {
                              setModalState(() {
                                selectedImagePath =
                                    imagePath;
                              });
                            },
                          );
                        },
                        borderRadius:
                            BorderRadius.circular(18),
                        child: Container(
                          width: double.infinity,
                          height:
                              selectedImagePath == null
                                  ? 130
                                  : 220,
                          decoration: BoxDecoration(
                            color:
                                Color(0xFFF8FAFC),
                            borderRadius:
                                BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  AppTheme.primaryLight,
                            ),
                          ),
                          child:
                              selectedImagePath == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration:
                                              BoxDecoration(
                                            color: AppTheme
                                                .primaryLight,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              15,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons
                                                .add_photo_alternate_rounded,
                                            color:
                                                AppTheme.primary,
                                            size: 28,
                                          ),
                                        ),

                                        SizedBox(
                                          height: 10,
                                        ),

                                        Text(
                                          _t('Add Report Photo', 'रिपोर्ट फोटो जोड़ें', 'রিপোর্টের ছবি যোগ করুন'),
                                          style: TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                            color: AppTheme
                                                .textPrimary,
                                          ),
                                        ),

                                        SizedBox(
                                          height: 4,
                                        ),

                                        Text(
                                          _t('Tap to choose Camera or Gallery', 'कैमरा या गैलरी चुनने के लिए टैप करें', 'ক্যামেরা বা গ্যালারি বেছে নিতে ট্যাপ করুন'),
                                          style: TextStyle(
                                            color:
                                                Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            17,
                                          ),
                                          child: Image.file(
                                            File(
                                              selectedImagePath!,
                                            ),
                                            fit:
                                                BoxFit.cover,
                                          ),
                                        ),

                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child:
                                              Material(
                                            color:
                                                Colors.white,
                                            shape:
                                                CircleBorder(),
                                            child: IconButton(
                                              icon:
                                                  Icon(
                                                Icons.close_rounded,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                setModalState(
                                                  () {
                                                    selectedImagePath =
                                                        null;
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),

                      SizedBox(height: 28),

                      // ADD BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final title =
                                titleController.text.trim();

                            final subtitle =
                                subtitleController.text.trim();

                            if (title.isEmpty ||
                                subtitle.isEmpty) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _t('Please fill all record details', 'कृपया सभी रिकॉर्ड विवरण भरें', 'অনুগ্রহ করে সব রেকর্ডের তথ্য পূরণ করুন'),
                                  ),
                                ),
                              );
                              return;
                            }

                            final newRecord =
                                <String, dynamic>{
                              'id': DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              'title': title,
                              'subtitle': subtitle,
                              'date': 'Today',
                              'type': selectedType,
                              'icon':
                                  _getIconName(selectedType),
                              'imagePath':
                                  selectedImagePath ?? '',
                            };

                            setState(() {
                              _records.insert(
                                0,
                                newRecord,
                              );
                            });

                            final success =
                                await _saveRecords();

                            if (!mounted) return;

                            if (!success) {
                              setState(() {
                                _records.removeWhere(
                                  (record) =>
                                      record['id'] ==
                                      newRecord['id'],
                                );
                              });

                              ScaffoldMessenger.of(
                                this.context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _t('Could not save record. Please try again.', 'रिकॉर्ड सेव नहीं हो सका। कृपया फिर प्रयास करें।', 'রেকর্ড সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।'),
                                  ),
                                ),
                              );
                              return;
                            }

                            Navigator.of(
                              sheetContext,
                            ).pop();

                            ScaffoldMessenger.of(
                              this.context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _t('Health record added successfully', 'स्वास्थ्य रिकॉर्ड सफलतापूर्वक जोड़ा गया', 'স্বাস্থ্য রেকর্ড সফলভাবে যোগ হয়েছে'),
                                ),
                              ),
                            );
                          },
                          icon:
                              Icon(Icons.add_rounded),
                          label: Text(
                            _t('Add Record', 'रिकॉर्ड जोड़ें', 'রেকর্ড যোগ করুন'),
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w700,
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
  // DELETE RECORD PERMANENTLY
  // =====================================================

  Future<void> _deleteRecord(
    int index,
  ) async {
    final record = _records[index];

    final bool? shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            _t('Delete Record?', 'रिकॉर्ड हटाएं?', 'রেকর্ড মুছবেন?'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${record['title']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(_t('Cancel', 'रद्द करें', 'বাতিল করুন')),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(_t('Delete', 'हटाएं', 'মুছুন')),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final deletedRecord = record;

    setState(() {
      _records.removeAt(index);
    });

    final success = await _saveRecords();

    if (!mounted) return;

    if (!success) {
      setState(() {
        _records.insert(index, deletedRecord);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t('Could not delete record. Please try again.', 'रिकॉर्ड हटाया नहीं जा सका। फिर प्रयास करें।', 'রেকর্ড মুছতে পারেনি। আবার চেষ্টা করুন।'),
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _t('Health record deleted permanently', 'स्वास्थ्य रिकॉर्ड स्थायी रूप से हटा दिया गया', 'স্বাস্থ্য রেকর্ড স্থায়ীভাবে মুছে ফেলা হয়েছে'),
        ),
      ),
    );
  }

  // =====================================================
  // VIEW REPORT IMAGE
  // =====================================================

  void _viewReportImage(String imagePath) {
    if (imagePath.isEmpty) return;

    final imageFile = File(imagePath);

    if (!imageFile.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t('Report image is no longer available.', 'रिपोर्ट की फोटो अब उपलब्ध नहीं है।', 'রিপোর্টের ছবি আর পাওয়া যাচ্ছে না।'),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: Text(_t('Report Photo', 'रिपोर्ट फोटो', 'রিপোর্টের ছবি')),
            ),
            body: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // RECORD CARD
  // =====================================================

  Widget _buildRecordCard(
    Map<String, dynamic> record,
    int index,
  ) {
    final String imagePath =
        record['imagePath']?.toString() ?? '';

    final bool hasImage =
        imagePath.isNotEmpty &&
            File(imagePath).existsSync();

    final String type =
        record['type']?.toString() ?? _t('Lab Report', 'लैब रिपोर्ट', 'ল্যাব রিপোর্ট');

    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: hasImage
            ? () => _viewReportImage(imagePath)
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0xFFE8EDF2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // IMAGE OR ICON
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasImage
                    ? Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        _getRecordIcon(type),
                        color: AppTheme.primary,
                        size: 28,
                      ),
              ),

              SizedBox(width: 14),

              // DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['title']?.toString() ??
                          _t('Health Record', 'स्वास्थ्य रिकॉर्ड', 'স্বাস্থ্য রেকর্ড'),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      record['subtitle']?.toString() ??
                          '',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      '$type • ${record['date'] ?? 'Today'}',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // MENU
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.grey,
                ),
                onSelected: (value) {
                  if (value == 'view' && hasImage) {
                    _viewReportImage(imagePath);
                  }

                  if (value == 'delete') {
                    _deleteRecord(index);
                  }
                },
                itemBuilder: (context) => [
                  if (hasImage)
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined),
                          SizedBox(width: 10),
                          Text(_t('View Report', 'रिपोर्ट देखें', 'রিপোর্ট দেখুন')),
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
                        Text(_t('Delete', 'हटाएं', 'মুছুন')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 46,
                color: AppTheme.primary,
              ),
            ),

            SizedBox(height: 24),

            Text(
              _t('No Health Records', 'कोई स्वास्थ्य रिकॉर्ड नहीं', 'কোনও স্বাস্থ্য রেকর্ড নেই'),
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),

            SizedBox(height: 10),

            Text(
              _t('Add your medical reports, prescriptions and other health records here.', 'अपनी मेडिकल रिपोर्ट, प्रिस्क्रिप्शन और अन्य स्वास्थ्य रिकॉर्ड यहां जोड़ें।', 'আপনার মেডিকেল রিপোর্ট, প্রেসক্রিপশন ও অন্যান্য স্বাস্থ্য রেকর্ড এখানে যোগ করুন।'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _addRecord,
                icon:
                    Icon(Icons.add_rounded),
                label: Text(
                  _t('Add Your First Record', 'अपना पहला रिकॉर्ड जोड़ें', 'আপনার প্রথম রেকর্ড যোগ করুন'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // MAIN UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final int prescriptions = _records.where((r) => r['type'] == 'Prescription').length;
    final int labs = _records.where((r) => r['type'] == _t('Lab Report', 'लैब रिपोर्ट', 'ল্যাব রিপোর্ট')).length;

    return Scaffold(
      backgroundColor: Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Color(0xFFF7FAF9),
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t('Health Records', 'स्वास्थ्य रिकॉर्ड', 'স্বাস্থ্য রেকর্ড'), style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            SizedBox(height: 2),
            Text(_t('Your reports, prescriptions & history', 'आपकी रिपोर्ट, प्रिस्क्रिप्शन और इतिहास', 'আপনার রিপোর্ট, প্রেসক্রিপশন ও ইতিহাস'), style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          IconButton(onPressed: _loadRecords, icon: Icon(Icons.refresh_rounded)),
          SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        backgroundColor: AppTheme.primary,
        icon: Icon(Icons.add_rounded, color: Colors.white),
        label: Text(_t('Add Record', 'रिकॉर्ड जोड़ें', 'রেকর্ড যোগ করুন'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _loadRecords,
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 8, 20, 110),
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFFE8F8F4), Color(0xFFF3FBF9)]),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Color(0xFFD7EEE9)),
                    ),
                    child: Row(children: [
                      Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)), child: Icon(Icons.folder_copy_rounded, color: AppTheme.primary, size: 28)),
                      SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_t('Care history in one place', 'आपकी स्वास्थ्य जानकारी एक जगह', 'স্বাস্থ্য ইতিহাস এক জায়গায়'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)), SizedBox(height: 4), Text(_t('Keep important medical documents ready whenever you need them.', 'जरूरत पड़ने पर महत्वपूर्ण मेडिकल दस्तावेज तैयार रखें।', 'প্রয়োজনের সময় গুরুত্বপূর্ণ মেডিকেল নথি প্রস্তুত রাখুন।'), style: TextStyle(fontSize: 12, height: 1.4, color: AppTheme.textSecondary))])),
                    ]),
                  ),
                  SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _summaryCard(_t('Total', 'कुल', 'মোট'), '${_records.length}', Icons.folder_rounded, Color(0xFFEAF2FF), Color(0xFF2878E8))),
                    SizedBox(width: 10),
                    Expanded(child: _summaryCard(_t('Prescriptions', 'प्रिस्क्रिप्शन', 'প্রেসক্রিপশন'), '$prescriptions', Icons.description_rounded, Color(0xFFF2EDFF), Color(0xFF7653D6))),
                    SizedBox(width: 10),
                    Expanded(child: _summaryCard(_t('Lab reports', 'लैब रिपोर्ट', 'ল্যাব রিপোর্ট'), '$labs', Icons.science_rounded, Color(0xFFFFF3E1), Color(0xFFEF8B17))),
                  ]),
                  SizedBox(height: 22),
                  Row(children: [
                    Expanded(child: Text(_t('Recent records', 'हाल के रिकॉर्ड', 'সাম্প্রতিক রেকর্ড'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppTheme.textPrimary))),
                    Text('${_records.length} saved', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ]),
                  SizedBox(height: 12),
                  if (_records.isEmpty) _buildEmptyState() else ...List.generate(_records.length, (index) => _buildRecordCard(_records[index], index)),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color bg, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Color(0xFFE5ECEA))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 18)),
        SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
        SizedBox(height: 2),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, color: AppTheme.textSecondary)),
      ]),
    );
  }
}