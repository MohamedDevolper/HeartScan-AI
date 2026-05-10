import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'profile': 'Profile',
      'personal_information': 'Personal Information',
      'language': 'Language / اللغة',
      'theme': 'Theme / المظهر',
      'help_support': 'Help & Support',
      'logout': 'Log Out',
      'age': 'Age',
      'gender': 'Gender',
      'guest_user': 'Guest User',
      'no_email': 'No Email',
      'close': 'Close',
      // Bottom Nav
      'upload': 'Upload',
      'symptoms': 'Symptoms',
      'history': 'History',
    },
    'ar': {
      'profile': 'الملف الشخصي',
      'personal_information': 'المعلومات الشخصية',
      'language': 'Language / اللغة',
      'theme': 'Theme / المظهر',
      'help_support': 'المساعدة والدعم',
      'logout': 'تسجيل خروج',
      'age': 'العمر',
      'gender': 'الجنس',
      'guest_user': 'مستخدم زائر',
      'no_email': 'لا يوجد بريد',
      'close': 'إغلاق',
      // Bottom Nav
      'upload': 'رفع',
      'symptoms': 'الأعراض',
      'history': 'السجل',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Helper Extension for easy access
extension TranslateExtension on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }
}
