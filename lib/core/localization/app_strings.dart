class AppStrings {
  final String languageCode;

  AppStrings(this.languageCode);

  static AppStrings of(String languageCode) {
    return AppStrings(languageCode);
  }

  final Map<String, Map<String, String>> _strings = {
    'en': {
      'goodMorning': 'Good Morning 👋',
      'welcome': 'Welcome',
      'refreshDashboard': 'Refresh Dashboard',

      'blood': 'Blood',
      'healthPriority': 'Your health,\nour priority.',
      'healthDescription':
          'Manage appointments, medicines and healthcare services from one place.',

      'healthOverview': 'Health Overview',
      'upcomingAppointments': 'Upcoming\nAppointments',
      'totalMedicines': 'Total\nMedicines',
      'medicinesTaken': 'Medicines\nTaken',
      'pendingMedicines': 'Pending\nMedicines',

      'medicineProgress': 'Medicine Progress',
      'noMedicines': 'No medicines added yet.',
      'medicinesMarked': 'medicines marked as taken.',

      'upcomingAppointment': 'Upcoming Appointment',
      'nextAppointment': 'Next Appointment',
      'viewAll': 'View All',
      'noUpcomingAppointments': 'No Upcoming Appointments',
      'bookAppointmentMessage':
          'Book an appointment with a doctor to manage your healthcare.',
      'bookNow': 'Book Now',

      'doctor': 'Doctor',
      'general': 'General',
      'healthcareCenter': 'Healthcare Center',
      'dateNotAvailable': 'Date not available',
      'timeNotAvailable': 'Time not available',

      'quickServices': 'Quick Services',
      'healthTip': 'Health Tip of the Day',

      'bookAppointment': 'Book\nAppointment',
      'myAppointments': 'My\nAppointments',
      'healthRecords': 'Health\nRecords',
      'medicineReminder': 'Medicine\nReminder',
      'aiHealthAssistant': 'AI Health\nAssistant',
      'familyHealthProfile': 'Family Health\nProfile',
      'emergencyHelp': 'Emergency\nHelp',
      'myProfile': 'My\nProfile',

      'stayHydrated': 'Stay Hydrated',
      'hydratedMessage':
          'Drinking enough water throughout the day helps your body stay healthy and active.',

      'medicineReminderTip': 'Medicine Reminder',
      'medicinePending': 'medicine still pending. Remember to take them as prescribed.',

      'appointmentReminder': 'Appointment Reminder',
      'appointmentUpcoming':
          'upcoming appointment. Check your schedule before the visit.',

      'featureComingSoon': 'feature coming soon',

      'home': 'Home',
      'appointments': 'Appointments',
      'records': 'Records',
      'profile': 'Profile',
    },

    'hi': {
      'goodMorning': 'सुप्रभात 👋',
      'welcome': 'स्वागत है',
      'refreshDashboard': 'डैशबोर्ड रीफ्रेश करें',

      'blood': 'ब्लड ग्रुप',
      'healthPriority': 'आपका स्वास्थ्य,\nहमारी प्राथमिकता।',
      'healthDescription':
          'एक ही जगह से अपॉइंटमेंट, दवाइयाँ और स्वास्थ्य सेवाएँ प्रबंधित करें।',

      'healthOverview': 'स्वास्थ्य विवरण',
      'upcomingAppointments': 'आने वाले\nअपॉइंटमेंट',
      'totalMedicines': 'कुल\nदवाइयाँ',
      'medicinesTaken': 'ली गई\nदवाइयाँ',
      'pendingMedicines': 'बाकी\nदवाइयाँ',

      'medicineProgress': 'दवा प्रगति',
      'noMedicines': 'अभी कोई दवा नहीं जोड़ी गई है।',
      'medicinesMarked': 'दवाइयाँ ली गई हैं।',

      'upcomingAppointment': 'आने वाला अपॉइंटमेंट',
      'nextAppointment': 'अगला अपॉइंटमेंट',
      'viewAll': 'सभी देखें',
      'noUpcomingAppointments': 'कोई आने वाला अपॉइंटमेंट नहीं',
      'bookAppointmentMessage':
          'अपने स्वास्थ्य को बेहतर तरीके से प्रबंधित करने के लिए डॉक्टर के साथ अपॉइंटमेंट बुक करें।',
      'bookNow': 'अभी बुक करें',

      'doctor': 'डॉक्टर',
      'general': 'सामान्य',
      'healthcareCenter': 'स्वास्थ्य केंद्र',
      'dateNotAvailable': 'तारीख उपलब्ध नहीं है',
      'timeNotAvailable': 'समय उपलब्ध नहीं है',

      'quickServices': 'त्वरित सेवाएँ',
      'healthTip': 'आज का स्वास्थ्य सुझाव',

      'bookAppointment': 'अपॉइंटमेंट\nबुक करें',
      'myAppointments': 'मेरे\nअपॉइंटमेंट',
      'healthRecords': 'स्वास्थ्य\nरिकॉर्ड',
      'medicineReminder': 'दवा\nरिमाइंडर',
      'aiHealthAssistant': 'AI स्वास्थ्य\nसहायक',
      'familyHealthProfile': 'परिवार स्वास्थ्य\nप्रोफाइल',
      'emergencyHelp': 'आपातकालीन\nसहायता',
      'myProfile': 'मेरी\nप्रोफाइल',

      'stayHydrated': 'पानी पीते रहें',
      'hydratedMessage':
          'दिनभर पर्याप्त पानी पीने से आपका शरीर स्वस्थ और सक्रिय रहता है।',

      'medicineReminderTip': 'दवा रिमाइंडर',
      'medicinePending':
          'दवा अभी बाकी है। उन्हें डॉक्टर के निर्देश के अनुसार लेना याद रखें।',

      'appointmentReminder': 'अपॉइंटमेंट रिमाइंडर',
      'appointmentUpcoming':
          'आने वाला अपॉइंटमेंट है। जाने से पहले अपना शेड्यूल देखें।',

      'featureComingSoon': 'फीचर जल्द उपलब्ध होगा',

      'home': 'होम',
      'appointments': 'अपॉइंटमेंट',
      'records': 'रिकॉर्ड',
      'profile': 'प्रोफाइल',
    },

    'bn': {
      'goodMorning': 'সুপ্রভাত 👋',
      'welcome': 'স্বাগতম',
      'refreshDashboard': 'ড্যাশবোর্ড রিফ্রেশ করুন',

      'blood': 'রক্তের গ্রুপ',
      'healthPriority': 'আপনার স্বাস্থ্য,\nআমাদের অগ্রাধিকার।',
      'healthDescription':
          'এক জায়গা থেকে অ্যাপয়েন্টমেন্ট, ওষুধ এবং স্বাস্থ্যসেবা পরিচালনা করুন।',

      'healthOverview': 'স্বাস্থ্য পর্যালোচনা',
      'upcomingAppointments': 'আসন্ন\nঅ্যাপয়েন্টমেন্ট',
      'totalMedicines': 'মোট\nওষুধ',
      'medicinesTaken': 'নেওয়া\nওষুধ',
      'pendingMedicines': 'বাকি\nওষুধ',

      'medicineProgress': 'ওষুধের অগ্রগতি',
      'noMedicines': 'এখনও কোনো ওষুধ যোগ করা হয়নি।',
      'medicinesMarked': 'টি ওষুধ নেওয়া হয়েছে।',

      'upcomingAppointment': 'আসন্ন অ্যাপয়েন্টমেন্ট',
      'nextAppointment': 'পরবর্তী অ্যাপয়েন্টমেন্ট',
      'viewAll': 'সব দেখুন',
      'noUpcomingAppointments': 'কোনো আসন্ন অ্যাপয়েন্টমেন্ট নেই',
      'bookAppointmentMessage':
          'আপনার স্বাস্থ্য পরিচালনার জন্য একজন ডাক্তারের সঙ্গে অ্যাপয়েন্টমেন্ট বুক করুন।',
      'bookNow': 'এখনই বুক করুন',

      'doctor': 'ডাক্তার',
      'general': 'সাধারণ',
      'healthcareCenter': 'স্বাস্থ্য কেন্দ্র',
      'dateNotAvailable': 'তারিখ পাওয়া যায়নি',
      'timeNotAvailable': 'সময় পাওয়া যায়নি',

      'quickServices': 'দ্রুত পরিষেবা',
      'healthTip': 'আজকের স্বাস্থ্য পরামর্শ',

      'bookAppointment': 'অ্যাপয়েন্টমেন্ট\nবুক করুন',
      'myAppointments': 'আমার\nঅ্যাপয়েন্টমেন্ট',
      'healthRecords': 'স্বাস্থ্য\nরেকর্ড',
      'medicineReminder': 'ওষুধ\nরিমাইন্ডার',
      'aiHealthAssistant': 'AI স্বাস্থ্য\nসহায়ক',
      'familyHealthProfile': 'পরিবারের স্বাস্থ্য\nপ্রোফাইল',
      'emergencyHelp': 'জরুরি\nসাহায্য',
      'myProfile': 'আমার\nপ্রোফাইল',

      'stayHydrated': 'পর্যাপ্ত পানি পান করুন',
      'hydratedMessage':
          'সারাদিন পর্যাপ্ত পানি পান করলে শরীর সুস্থ ও সক্রিয় থাকে।',

      'medicineReminderTip': 'ওষুধ রিমাইন্ডার',
      'medicinePending':
          'টি ওষুধ এখনও বাকি আছে। নির্দেশ অনুযায়ী ওষুধ নিতে ভুলবেন না।',

      'appointmentReminder': 'অ্যাপয়েন্টমেন্ট রিমাইন্ডার',
      'appointmentUpcoming':
          'টি আসন্ন অ্যাপয়েন্টমেন্ট আছে। যাওয়ার আগে আপনার সময়সূচি দেখে নিন।',

      'featureComingSoon': 'ফিচার শীঘ্রই আসছে',

      'home': 'হোম',
      'appointments': 'অ্যাপয়েন্টমেন্ট',
      'records': 'রেকর্ড',
      'profile': 'প্রোফাইল',
    },
  };

  String get(String key) {
    return _strings[languageCode]?[key] ??
        _strings['en']?[key] ??
        key;
  }
}