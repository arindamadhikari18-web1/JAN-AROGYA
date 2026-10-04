import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/localization/app_strings.dart';
import '../../main.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() =>
      _HealthRecordsScreenState();
}

class _HealthRecordsScreenState
    extends State<HealthRecordsScreen> {
  static const String _storageKey = 'health_records';

  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;

  List<Map<String, dynamic>> _records = [];

  // =====================================================
  // LOCALIZATION
  // =====================================================

  AppStrings get strings {
    final languageCode =
        JanArogyaApp.of(context)?.currentLanguageCode ??
            'en';

    return AppStrings.of(languageCode);
  }

  String t(String key) {
    return strings.get(key);
  }

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  // =====================================================
  // LOAD RECORDS
  // =====================================================

  Future<void> _loadRecords() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final String? savedRecords =
          prefs.getString(_storageKey);

      if (savedRecords != null &&
          savedRecords.isNotEmpty) {
        final List<dynamic> decoded =
            jsonDecode(savedRecords);

        _records = decoded
            .map<Map<String, dynamic>>(
              (record) =>
                  Map<String, dynamic>.from(
                record as Map,
              ),
            )
            .toList();
      } else {
        _records = [];
      }
    } catch (e) {
      debugPrint(
        'Error loading health records: $e',
      );

      _records = [];
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // =====================================================
  // SAVE RECORDS
  // =====================================================

  Future<bool> _saveRecords() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final String encodedRecords =
          jsonEncode(_records);

      return await prefs.setString(
        _storageKey,
        encodedRecords,
      );
    } catch (e) {
      debugPrint(
        'Error saving health records: $e',
      );

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
  // TRANSLATE SAVED RECORD TYPE
  // =====================================================

  String _getTranslatedType(String type) {
    if (type == 'Prescription') {
      return t('prescription');
    }

    if (type == 'Medical Record') {
      return t('medicalRecord');
    }

    return t('labReport');
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
            t('chooseImageError'),
          ),
        ),
      );
    }
  }

  // =====================================================
  // IMAGE OPTIONS
  // =====================================================

  void _showImageOptions(
    Function(String) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
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

                const SizedBox(height: 20),

                Text(
                  t('uploadReportPhoto'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  t('chooseUploadMethod'),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 18),

                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
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
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  title: Text(
                    t('takePhoto'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    t('takePhotoSubtitle'),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    await _pickReportImage(
                      ImageSource.camera,
                      onSelected,
                    );
                  },
                ),

                const SizedBox(height: 8),

                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
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
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  title: Text(
                    t('chooseGallery'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    t('chooseGallerySubtitle'),
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
  // ADD RECORD
  // =====================================================

  void _addRecord() {
    final titleController =
        TextEditingController();

    final subtitleController =
        TextEditingController();

    String selectedType = 'Lab Report';
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
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  14,
                  24,
                  32,
                ),
                decoration: const BoxDecoration(
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
                      Center(
                        child: Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        t('addHealthRecord'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        t('addRecordDescription'),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        t('recordTitle'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText:
                              t('recordTitleHint'),
                          prefixIcon: const Icon(
                            Icons.folder_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        t('description'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: subtitleController,
                        decoration: InputDecoration(
                          hintText:
                              t('descriptionHint'),
                          prefixIcon: const Icon(
                            Icons.notes_rounded,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        t('recordType'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration:
                            const InputDecoration(
                          prefixIcon: Icon(
                            Icons.category_outlined,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Lab Report',
                            child: Text(
                              t('labReport'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Prescription',
                            child: Text(
                              t('prescription'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Medical Record',
                            child: Text(
                              t('medicalRecord'),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setModalState(() {
                            selectedType = value;
                          });
                        },
                      ),

                      const SizedBox(height: 22),

                      Text(
                        t('reportPhoto'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

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
                                const Color(0xFFF8FAFC),
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
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
                                          child: const Icon(
                                            Icons
                                                .add_photo_alternate_rounded,
                                            color:
                                                AppTheme.primary,
                                            size: 28,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 10,
                                        ),

                                        Text(
                                          t('addReportPhoto'),
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                            color: AppTheme
                                                .textPrimary,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 4,
                                        ),

                                        Text(
                                          t(
                                            'tapCameraGallery',
                                          ),
                                          style: TextStyle(
                                            color: Colors
                                                .grey.shade600,
                                            fontSize: 12,
                                          ),
                                          textAlign:
                                              TextAlign.center,
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
                                          child: Material(
                                            color: Colors.white,
                                            shape:
                                                const CircleBorder(),
                                            child: IconButton(
                                              icon: const Icon(
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

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final title =
                                titleController.text.trim();

                            final subtitle =
                                subtitleController.text
                                    .trim();

                            if (title.isEmpty ||
                                subtitle.isEmpty) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    t(
                                      'pleaseFillDetails',
                                    ),
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
                              'icon': _getIconName(
                                selectedType,
                              ),
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
                                    t('couldNotSave'),
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
                                  t('recordAdded'),
                                ),
                              ),
                            );
                          },
                          icon:
                              const Icon(Icons.add_rounded),
                          label: Text(
                            t('addRecord'),
                            style: const TextStyle(
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
  // DELETE RECORD
  // =====================================================

  Future<void> _deleteRecord(int index) async {
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
            t('deleteRecord'),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            '${t('deleteConfirm')}\n\n"${record['title']}"',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(t('cancel')),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(t('delete')),
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
        _records.insert(
          index,
          deletedRecord,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('couldNotDelete'),
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          t('recordDeleted'),
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
            t('reportImageNotAvailable'),
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
              title: Text(
                t('reportPhoto'),
              ),
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
        record['type']?.toString() ?? 'Lab Report';

    final String date =
        record['date']?.toString() ?? 'Today';

    final String translatedDate =
        date == 'Today' ? t('today') : date;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: InkWell(
        onTap: hasImage
            ? () => _viewReportImage(imagePath)
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE8EDF2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.03,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
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

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['title']?.toString() ??
                          t('healthRecord'),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

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

                    const SizedBox(height: 8),

                    Text(
                      '${_getTranslatedType(type)} • $translatedDate',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.grey,
                ),
                onSelected: (value) {
                  if (value == 'view' &&
                      hasImage) {
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
                          const Icon(
                            Icons.visibility_outlined,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            t('viewReport'),
                          ),
                        ],
                      ),
                    ),

                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          t('delete'),
                        ),
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
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 46,
                color: AppTheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              t('noHealthRecords'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              t('noHealthRecordsDescription'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _addRecord,
                icon:
                    const Icon(Icons.add_rounded),
                label: Text(
                  t('addFirstRecord'),
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
    // IMPORTANT:
    // This line creates dependency on _LanguageProvider.
    // Therefore, when language changes, this screen rebuilds.
    final languageCode =
        JanArogyaApp.of(context)?.currentLanguageCode ??
            'en';

    final localizedStrings =
        AppStrings.of(languageCode);

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: Text(
          localizedStrings.get('healthRecords'),
          style: const TextStyle(
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

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _addRecord,
        backgroundColor: AppTheme.primary,
        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),
        label: Text(
          localizedStrings.get('addRecord'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : _records.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRecords,
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      100,
                    ),
                    itemCount: _records.length,
                    itemBuilder:
                        (context, index) {
                      return _buildRecordCard(
                        _records[index],
                        index,
                      );
                    },
                  ),
                ),
    );
  }
}