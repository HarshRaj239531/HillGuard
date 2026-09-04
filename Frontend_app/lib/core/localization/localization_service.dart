import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  en('en', 'EN', 'English'),
  ne('ne', 'नेपाली', 'Nepali'),
  hi('hi', 'हिन्दी', 'Hindi'),
  bn('bn', 'বাংলা', 'Bengali');

  final String code;
  final String label;
  final String fullName;
  const AppLanguage(this.code, this.label, this.fullName);
}

class LocalizationService extends ChangeNotifier {
  static const String _prefKey = 'hillguard_selected_language';
  AppLanguage _currentLanguage = AppLanguage.en;

  AppLanguage get currentLanguage => _currentLanguage;

  LocalizationService() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null) {
        _currentLanguage = AppLanguage.values.firstWhere(
          (l) => l.code == code,
          orElse: () => AppLanguage.en,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language.code);
    } catch (_) {}
  }

  String t(String key) {
    return _translations[_currentLanguage]?[key] ??
        _translations[AppLanguage.en]?[key] ??
        key;
  }

  static const Map<AppLanguage, Map<String, String>> _translations = {
    AppLanguage.en: {
      'app_title': 'HillGuard',
      'app_subtitle': 'Disaster & Road Intelligence Mesh',
      'offline_stage_mode': '0% SIGNAL • STAGE PROOF',
      'offline_verified': 'AIRPLANE MODE VERIFIED',
      'no_server_calls': 'Zero Server Calls • On-Device Engine Active',
      'get_app': 'Install / APK',
      'tab_feed': 'Field Feed',
      'tab_map': 'Disaster Map',
      'tab_assistant': 'Hills AI',
      'tab_hud': 'Mesh HUD',
      'personas_title': 'Hill Persona Quick Presets',
      'persona_railway': 'DHR Trackman (Tindharia)',
      'persona_railway_sub': 'Inspect NH-55 rail cut slope & tension cracks',
      'persona_passenger': 'Passenger / Driver (NH-55)',
      'persona_passenger_sub': 'Check Pagla Jhora road cut & Rohini bypass',
      'persona_farmer': 'Homestay / Farmer (Mirik)',
      'persona_farmer_sub': 'Cold exposure survival & village shelter',
      'hills_assistant_title': 'Disaster-Ready Hills Assistant (0% Net)',
      'hills_assistant_desc': 'Offline triage, nearest PHC/Hospital geolocation, cold exposure & cloudburst survival.',
      'b1_landslide_title': 'B1 Landslide',
      'b1_landslide_sub': 'Crack scan & safety AI evaluation',
      'b6_road_title': 'B6 Road Mesh',
      'b6_road_sub': 'Report obstacle & relay over phone mesh',
      'route_board': 'Route Board (B6)',
      'relay_alert': 'Relay Alert (B1)',
      'live_feed_header': 'LIVE COMMUNITY HAZARD FEED',
      'new_report_btn': 'New Field Report',
      'safe_haven_nav': 'Nearest Shelter / PHC',
      'sos_beacon': 'Broadcast SOS Beacon',
      'road_status_blocked': '🛑 BLOCKED',
      'road_status_caution': '⚠️ CAUTION',
      'road_status_normal': '🟢 CLEAR',
    },
    AppLanguage.ne: {
      'app_title': 'हिलगार्ड',
      'app_subtitle': 'पहाडी विपद् तथा सडक मेश प्रणाली',
      'offline_stage_mode': 'शून्य नेटवर्क • अफलाइन मोड',
      'offline_verified': 'एरोप्लेन मोड प्रमाणित',
      'no_server_calls': 'कुनै सर्भर कल छैन • उपकरणमै चल्ने एआई',
      'get_app': 'एप स्थापना',
      'tab_feed': 'फिल्ड फिड',
      'tab_map': 'विपद् नक्शा',
      'tab_assistant': 'पहाड एआई',
      'tab_hud': 'मेश हड',
      'personas_title': 'पहाडी समुदाय परिदृश्य (प्रिसेट)',
      'persona_railway': 'रेलवे कर्मचारी (तिनधरिया)',
      'persona_railway_sub': 'NH-55 रेलवे भिरालो र दरार जाँच',
      'persona_passenger': 'यात्रु / ट्याक्सी चालक (NH-55)',
      'persona_passenger_sub': 'पगला झोरा पहिरो र रोहिणी वैकल्पिक बाटो',
      'persona_farmer': 'होमस्टे / कृषक (मिरिक)',
      'persona_farmer_sub': 'अत्यधिक चिसोबाट बच्ने उपाय र आश्रय स्थल',
      'hills_assistant_title': 'पहाडी विपद् सहायक (इन्टरनेट बिना)',
      'hills_assistant_desc': 'पहिरो, बादल फुट्ने र चिसोमा प्राथमिक उपचार, नजिकैको स्वास्थ्य चौकी खोजी।',
      'b1_landslide_title': 'B1 पहिरो रिपोर्टर',
      'b1_landslide_sub': 'दरार स्क्यान तथा जोखिम मूल्यांकन',
      'b6_road_title': 'B6 सडक मेश',
      'b6_road_sub': 'सडक अवरोध रिपोर्ट तथा अफलाइन रिले',
      'route_board': 'मार्ग स्थिति बोर्ड (B6)',
      'relay_alert': 'चेतावनी रिले (B1)',
      'live_feed_header': 'प्रत्यक्ष समुदाय विपद् सूचना',
      'new_report_btn': 'नयाँ फिल्ड रिपोर्ट',
      'safe_haven_nav': 'नजिकैको स्वास्थ्य चौकी / आश्रय',
      'sos_beacon': 'आपतकालीन SOS प्रसारण',
      'road_status_blocked': '🛑 बाटो बन्द',
      'road_status_caution': '⚠️ सावधानी',
      'road_status_normal': '🟢 बाटो खुला',
    },
    AppLanguage.hi: {
      'app_title': 'हिलगार्ड',
      'app_subtitle': 'पर्वतीय आपदा एवं मार्ग मेश नेटवर्क',
      'offline_stage_mode': '0% नेटवर्क • स्टेज प्रूफ',
      'offline_verified': 'एयरप्लेन मोड सत्यापित',
      'no_server_calls': 'शून्य सर्वर कॉल • ऑन-डिवाइस इंजन सक्रिय',
      'get_app': 'ऐप इंस्टॉल / APK',
      'tab_feed': 'फील्ड फीड',
      'tab_map': 'आपदा मानचित्र',
      'tab_assistant': 'पहाड़ AI',
      'tab_hud': 'मेश हड',
      'personas_title': 'पहाड़ी नागरिक परिदृश्य (त्वरित विकल्प)',
      'persona_railway': 'रेलवे ट्रैककर्मी (तीनधरिया)',
      'persona_railway_sub': 'NH-55 रेल ढलान दरार एवं भूस्खलन जांच',
      'persona_passenger': 'यात्री / चालक (NH-55)',
      'persona_passenger_sub': 'पगला झोरा मार्ग अवरोध एवं रोहिणी बाईपास',
      'persona_farmer': 'होमस्टे / कृषक (मिरिक)',
      'persona_farmer_sub': 'शीतदंश / हाइपोथर्मिया से बचाव व सुरक्षित शेल्टर',
      'hills_assistant_title': 'पहाड़ी आपदा सहायक (0% इंटरनेट)',
      'hills_assistant_desc': 'भूस्खलन, बादल फटना एवं अत्यधिक ठंड में चरणबद्ध मार्गदर्शन व निकटतम अस्पताल।',
      'b1_landslide_title': 'B1 भूस्खलन रिपोर्ट',
      'b1_landslide_sub': 'दरार स्कैन एवं ऑन-डिवाइस जोखिम विश्लेषण',
      'b6_road_title': 'B6 मार्ग मेश',
      'b6_road_sub': 'मार्ग अवरोध रिपोर्ट व फोन-टू-फोन रिले',
      'route_board': 'मार्ग स्थिति बोर्ड (B6)',
      'relay_alert': 'अलर्ट रिले करें (B1)',
      'live_feed_header': 'लाइव आपदा एवं सड़क स्थिति',
      'new_report_btn': 'नई फील्ड रिपोर्ट दर्ज करें',
      'safe_haven_nav': 'निकटतम स्वास्थ्य केंद्र / शेल्टर',
      'sos_beacon': 'SOS बीकन प्रसारित करें',
      'road_status_blocked': '🛑 मार्ग बंद',
      'road_status_caution': '⚠️ सावधानी',
      'road_status_normal': '🟢 मार्ग खुला',
    },
    AppLanguage.bn: {
      'app_title': 'হিলগার্ড',
      'app_subtitle': 'পাহাড়ি দুর্যোগ ও সড়ক তথ্য নেটওয়ার্ক',
      'offline_stage_mode': '০% সিগন্যাল • স্টেজ মোড',
      'offline_verified': 'এয়ারপ্লেন মোড ভেরিফাইড',
      'no_server_calls': 'কোনো সার্ভার কল নেই • অন-ডিভাইস ইঞ্জিন',
      'get_app': 'অ্যাপ ইনস্টল / APK',
      'tab_feed': 'ফিল্ড ফিড',
      'tab_map': 'দুর্যোগ মানচিত্র',
      'tab_assistant': 'পাহাড় AI',
      'tab_hud': 'মেশ হাব',
      'personas_title': 'পাহাড়ি মানুষের দৃশ্যপট (কুইক প্রিসেট)',
      'persona_railway': 'রেলওয়ে কর্মী (তিনধারিয়া)',
      'persona_railway_sub': 'NH-55 রেলওয়ে ঢাল ও ফাটল পর্যবেক্ষণ',
      'persona_passenger': 'যাত্রী / চালক (NH-55)',
      'persona_passenger_sub': 'পাগলা ঝোরা ধস ও রোহিণী বিকল্প পথ',
      'persona_farmer': 'হোমস্টে / কৃষক (মিরিক)',
      'persona_farmer_sub': 'তীব্র ঠান্ডা থেকে সুরক্ষা ও নিরাপদ আশ্রয়',
      'hills_assistant_title': 'পাহাড়ি দুর্যোগ সহায়ক (ইন্টারনেট বিহীন)',
      'hills_assistant_desc': 'ধস, মেঘভাঙা বৃষ্টি ও ঠান্ডায় জরুরি পরামর্শ এবং নিকটবর্তী স্বাস্থ্যকেন্দ্র।',
      'b1_landslide_title': 'B1 ধস রিপোর্ট',
      'b1_landslide_sub': 'ফাটল স্ক্যান ও অন-ডিভাইস ঝুঁকি মূল্যায়ন',
      'b6_road_title': 'B6 সড়ক মেশ',
      'b6_road_sub': 'রাস্তার বাধা রিপোর্ট ও ফোন-টু-ফোন রিলে',
      'route_board': 'সড়ক স্থিতি বোর্ড (B6)',
      'relay_alert': 'সতর্কবার্তা রিলে (B1)',
      'live_feed_header': 'লাইভ দুর্যোগ তথ্য তালিকা',
      'new_report_btn': 'নতুন রিপোর্ট তৈরি করুন',
      'safe_haven_nav': 'নিকটবর্তী স্বাস্থ্যকেন্দ্র / আশ্রয়',
      'sos_beacon': 'জরুরি SOS সম্প্রচার',
      'road_status_blocked': '🛑 রাস্তা বন্ধ',
      'road_status_caution': '⚠️ সতর্কতা',
      'road_status_normal': '🟢 রাস্তা খোলা',
    },
  };
}
