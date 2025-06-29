import 'to_emoji.dart';

class LanguageData {
  final String isoCode;
  final String name;
  String get emojiFlag => isoToEmoji(isoCode);

  const LanguageData({required this.isoCode, required this.name});

}

const List<LanguageData> supportedLanguages = [
  LanguageData(isoCode: 'ar', name: 'Arabic'),
  LanguageData(isoCode: 'cz', name: 'Czech'),
  LanguageData(isoCode: 'nl', name: 'Dutch'),
  LanguageData(isoCode: 'de', name: 'Deutsch'),
  LanguageData(isoCode: 'en', name: 'English'),
  LanguageData(isoCode: 'fr', name: 'Français'),
  LanguageData(isoCode: 'es', name: 'Español'),
  LanguageData(isoCode: 'it', name: 'Italiano'),
  LanguageData(isoCode: 'pt', name: 'Portuguese'),
  LanguageData(isoCode: 'pl', name: 'Polish'),
  LanguageData(isoCode: 'tr', name: 'Turkish'),
  LanguageData(isoCode: 'hu', name: 'Hungarian'),
  LanguageData(isoCode: 'ru', name: 'Русский'),
  LanguageData(isoCode: 'zh', name: '中文'),
];



