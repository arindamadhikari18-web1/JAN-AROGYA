import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatefulWidget {
  final String emergencyContact;

  const EmergencyScreen({
    super.key,
    required this.emergencyContact,
  });

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  static const Color primary = Color(0xFF00796B);
  static const Color dark = Color(0xFF004D40);
  static const Color red = Color(0xFFD32F2F);
  static const Color redLight = Color(0xFFFFEBEE);
  static const Color background = Color(0xFFF7FAF9);
  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF62758A);
  static const Color border = Color(0xFFE0ECE8);

  bool _sosBusy = false;

  String _t(String en, String hi, String bn) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'hi') return hi;
    if (code == 'bn') return bn;
    return en;
  }

  String _cleanNumber(String value) {
    return value.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  Future<bool> _call(String number) async {
    final cleaned = _cleanNumber(number);
    if (cleaned.isEmpty) {
      if (mounted) {
        _message('No valid phone number is available.');
      }
      return false;
    }

    final uri = Uri(scheme: 'tel', path: cleaned);

    try {
      final ok = await launchUrl(uri);
      if (!ok && mounted) {
        _message('Could not open the phone dialer.');
      }
      return ok;
    } catch (_) {
      if (mounted) {
        _message('Could not open the phone dialer.');
      }
      return false;
    }
  }

  Future<void> _openMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=hospitals+near+me',
    );

    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok && mounted) {
        _message('Could not open Maps.');
      }
    } catch (_) {
      if (mounted) {
        _message('Could not open Maps.');
      }
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmAndCall({
    required String title,
    required String number,
    required String description,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(_t('Cancel', 'रद्द करें', 'বাতিল করুন')),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.call),
              label: const Text('Call'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _call(number);
    }
  }

  Future<void> _activateSos() async {
    if (_sosBusy) return;

    setState(() => _sosBusy = true);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_t('Emergency SOS', 'आपातकालीन SOS', 'জরুরি SOS')),
          content: Text(_t(
            'This will open the emergency call option. Use SOS only when immediate assistance is required.',
            'यह आपातकालीन कॉल विकल्प खोलेगा। केवल तत्काल सहायता की आवश्यकता होने पर SOS का उपयोग करें।',
            'এটি জরুরি কলের বিকল্প খুলবে। তাৎক্ষণিক সহায়তা প্রয়োজন হলে তবেই SOS ব্যবহার করুন।',
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(_t('Cancel', 'रद्द करें', 'বাতিল করুন')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(_t('Continue', 'जारी रखें', 'চালিয়ে যান')),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _call('112');
    }

    if (mounted) {
      setState(() => _sosBusy = false);
    }
  }

  void _showAmbulanceOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _t('Ambulance Assistance', 'एम्बुलेंस सहायता', 'অ্যাম্বুলেন্স সহায়তা'),
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _t('Choose the appropriate ambulance option.', 'उपयुक्त एम्बुलेंस विकल्प चुनें।', 'উপযুক্ত অ্যাম্বুলেন্সের বিকল্প বেছে নিন.'),
                  style: TextStyle(color: textSecondary),
                ),
                const SizedBox(height: 16),
                _ambulanceOption(
                  icon: Icons.local_shipping_outlined,
                  title: 'Government / Emergency Ambulance',
                  subtitle:
                      'Call the emergency service for immediate assistance.',
                  color: red,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmAndCall(
                      title: 'Call Emergency Ambulance',
                      number: '112',
                      description:
                          'This opens the emergency call option. '
                          'Availability depends on your location and service coverage.',
                    );
                  },
                ),
                const SizedBox(height: 10),
                _ambulanceOption(
                  icon: Icons.airport_shuttle_outlined,
                  title: 'Private Ambulance',
                  subtitle:
                      'Use your verified private ambulance provider number.',
                  color: primary,
                  onTap: () {
                    Navigator.pop(context);
                    _showPrivateAmbulanceDialog();
                  },
                ),
                const SizedBox(height: 10),
                _ambulanceOption(
                  icon: Icons.map_outlined,
                  title: 'Find Nearby Ambulance / Hospital',
                  subtitle: 'Open Maps and search nearby emergency facilities.',
                  color: const Color(0xFF2878E8),
                  onTap: () {
                    Navigator.pop(context);
                    _openMaps();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPrivateAmbulanceDialog() {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Private Ambulance'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Provider phone number',
              hintText: '+91 XXXXX XXXXX',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.pop(context);
              },
              child: Text(_t('Cancel', 'रद्द करें', 'বাতিল করুন')),
            ),
            FilledButton.icon(
              onPressed: () async {
                final number = controller.text.trim();
                controller.dispose();
                Navigator.pop(context);
                await _call(number);
              },
              icon: const Icon(Icons.call),
              label: const Text('Call Provider'),
            ),
          ],
        );
      },
    );
  }

  void _showFirstAid() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 620),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: ListView(
              children: [
                Text(
                  _t('Quick First-Aid Guidance', 'त्वरित प्राथमिक उपचार मार्गदर्शन', 'দ্রুত প্রাথমিক চিকিৎসা নির্দেশিকা'),
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 16),
                _AidItem(
                  title: _t('Severe bleeding', 'अधिक रक्तस्राव', 'অতিরিক্ত রক্তপাত'),
                  text: _t('Apply firm direct pressure with clean cloth or dressing and seek emergency help.', 'साफ कपड़े या ड्रेसिंग से सीधे दबाव दें और आपातकालीन सहायता लें।', 'পরিষ্কার কাপড় বা ড্রেসিং দিয়ে সরাসরি চাপ দিন এবং জরুরি সাহায্য নিন।'),
                ),
                _AidItem(
                  title: _t('Breathing difficulty', 'सांस लेने में कठिनाई', 'শ্বাসকষ্ট'),
                  text: _t('Move to a safe position, avoid unnecessary exertion and seek emergency medical help immediately.', 'सुरक्षित स्थिति में जाएं, अनावश्यक मेहनत से बचें और तुरंत आपातकालीन चिकित्सा सहायता लें।', 'নিরাপদ অবস্থানে যান, অপ্রয়োজনীয় পরিশ্রম এড়িয়ে অবিলম্বে জরুরি চিকিৎসা সহায়তা নিন।'),
                ),
                _AidItem(
                  title: _t('Unconscious person', 'बेहोश व्यक्ति', 'অচেতন ব্যক্তি'),
                  text: _t('Call emergency services. Do not give food, drink or medicines to an unconscious person.', 'आपातकालीन सेवाओं को कॉल करें। बेहोश व्यक्ति को भोजन, पानी या दवा न दें।', 'জরুরি পরিষেবায় কল করুন। অচেতন ব্যক্তিকে খাবার, পানি বা ওষুধ দেবেন না।'),
                ),
                _AidItem(
                  title: _t('Chest pain', 'सीने में दर्द', 'বুকে ব্যথা'),
                  text: _t('Treat sudden severe chest pain as an emergency and seek immediate medical care.', 'अचानक तेज सीने के दर्द को आपातकाल मानें और तुरंत चिकित्सा सहायता लें।', 'হঠাৎ তীব্র বুকে ব্যথাকে জরুরি অবস্থা হিসেবে বিবেচনা করে দ্রুত চিকিৎসা নিন।'),
                ),
                _AidItem(
                  title: _t('Stroke warning signs', 'स्ट्रोक के चेतावनी संकेत', 'স্ট্রোকের সতর্কতা লক্ষণ'),
                  text: _t('Sudden facial weakness, arm weakness or speech difficulty requires urgent emergency care.', 'अचानक चेहरे या हाथ में कमजोरी अथवा बोलने में कठिनाई के लिए तुरंत आपातकालीन देखभाल आवश्यक है।', 'হঠাৎ মুখ বা হাত দুর্বল হওয়া কিংবা কথা বলতে সমস্যা হলে জরুরি চিকিৎসা প্রয়োজন।'),
                ),
                _AidItem(
                  title: _t('Seizure', 'दौरा', 'খিঁচুনি'),
                  text: _t('Protect the person from nearby hazards, do not restrain them and do not put anything in their mouth. Seek emergency help when appropriate.', 'व्यक्ति को आसपास के खतरे से बचाएं, उसे न रोकें और मुंह में कुछ न डालें। आवश्यकता होने पर आपातकालीन सहायता लें।', 'ব্যক্তিকে আশপাশের বিপদ থেকে রক্ষা করুন, তাকে চেপে ধরবেন না এবং মুখে কিছু দেবেন না। প্রয়োজনে জরুরি সাহায্য নিন।'),
                ),
                SizedBox(height: 8),
                Text(
                  'This section provides general safety guidance and does not replace professional medical care.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ambulanceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withOpacity(.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(.16)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          _t('Emergency Help', 'आपातकालीन सहायता', 'জরুরি সহায়তা'),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      body: RefreshIndicator(
        color: primary,
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 350));
          if (mounted) setState(() {});
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: red.withOpacity(.20),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emergency_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _t('Emergency Assistance', 'आपातकालीन सहायता', 'জরুরি সহায়তা'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t('Get quick access to emergency calling, ambulance assistance, nearby hospitals and safety guidance.',
                      'आपातकालीन कॉल, एम्बुलेंस, नजदीकी अस्पताल और सुरक्षा मार्गदर्शन तक तुरंत पहुंच पाएं।',
                      'জরুরি কল, অ্যাম্বুলেন্স, কাছাকাছি হাসপাতাল ও নিরাপত্তা নির্দেশিকায় দ্রুত প্রবেশ করুন.'),
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton.icon(
                      onPressed: _sosBusy ? null : _activateSos,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      icon: const Icon(
                        Icons.sos_rounded,
                        size: 28,
                      ),
                      label: Text(
                        _sosBusy ? 'Please wait...' : 'EMERGENCY SOS',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: .4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Text(
              _t('Emergency Contacts', 'आपातकालीन संपर्क', 'জরুরি যোগাযোগ'),
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _actionCard(
              icon: Icons.phone_in_talk_rounded,
              title: 'Emergency Services — 112',
              subtitle: 'Call the national emergency service.',
              color: red,
              onTap: () => _confirmAndCall(
                title: 'Call Emergency Services',
                number: '112',
                description:
                    'Use this for an immediate emergency requiring urgent assistance.',
              ),
            ),

            const SizedBox(height: 10),

            _actionCard(
              icon: Icons.local_police_outlined,
              title: 'Police — 112',
              subtitle: 'Emergency police assistance.',
              color: const Color(0xFF2878E8),
              onTap: () => _confirmAndCall(
                title: 'Call Police',
                number: '112',
                description: 'This opens the emergency call option.',
              ),
            ),

            const SizedBox(height: 10),

            _actionCard(
              icon: Icons.local_fire_department_outlined,
              title: 'Fire & Rescue — 112',
              subtitle: 'Emergency fire and rescue assistance.',
              color: const Color(0xFFEF6C00),
              onTap: () => _confirmAndCall(
                title: 'Call Fire & Rescue',
                number: '112',
                description: 'This opens the emergency call option.',
              ),
            ),

            if (_cleanNumber(widget.emergencyContact).isNotEmpty) ...[
              const SizedBox(height: 10),
              _actionCard(
                icon: Icons.family_restroom_rounded,
                title: 'My Emergency Contact',
                subtitle: widget.emergencyContact,
                color: primary,
                onTap: () => _confirmAndCall(
                  title: 'Call Emergency Contact',
                  number: widget.emergencyContact,
                  description:
                      'Call your saved emergency contact.',
                ),
              ),
            ],

            const SizedBox(height: 24),

            Text(
              _t('Ambulance', 'एम्बुलेंस', 'অ্যাম্বুলেন্স'),
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _actionCard(
              icon: Icons.local_shipping_rounded,
              title: 'Ambulance Assistance',
              subtitle:
                  'Government/emergency, private provider or nearby facility search.',
              color: red,
              onTap: _showAmbulanceOptions,
            ),

            const SizedBox(height: 24),

            Text(
              _t('Find Emergency Care', 'आपातकालीन देखभाल खोजें', 'জরুরি চিকিৎসা খুঁজুন'),
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _actionCard(
              icon: Icons.local_hospital_rounded,
              title: 'Nearby Hospitals',
              subtitle:
                  'Open Maps to find hospitals and emergency facilities near you.',
              color: primary,
              onTap: _openMaps,
            ),

            const SizedBox(height: 10),

            _actionCard(
              icon: Icons.location_on_outlined,
              title: 'Share / Open Emergency Location',
              subtitle:
                  'Use Maps to locate the nearest suitable healthcare facility.',
              color: const Color(0xFF2878E8),
              onTap: _openMaps,
            ),

            const SizedBox(height: 24),

            Text(
              _t('Quick Safety Guidance', 'त्वरित सुरक्षा मार्गदर्शन', 'দ্রুত নিরাপত্তা নির্দেশিকা'),
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _actionCard(
              icon: Icons.medical_information_outlined,
              title: 'First-Aid & Emergency Guidance',
              subtitle:
                  'Quick general guidance for bleeding, breathing difficulty, unconsciousness, stroke and seizures.',
              color: const Color(0xFF7653D6),
              onTap: _showFirstAid,
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: redLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: red.withOpacity(.14),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: red,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'For severe or life-threatening symptoms, contact emergency services immediately. Jan Arogya is an access and coordination tool and does not replace doctors, ambulances or hospitals.',
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AidItem extends StatelessWidget {
  final String title;
  final String text;

  const _AidItem({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Color(0xFF00796B),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF102A43),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF62758A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
