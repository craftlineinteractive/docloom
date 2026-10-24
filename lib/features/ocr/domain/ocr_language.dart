class OcrLanguage {
  const OcrLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.sizeMb,
    required this.isIndian,
    this.isBundled = false,
  });

  final String code;
  final String name;
  final String nativeName;
  final double sizeMb;
  final bool isIndian;
  final bool isBundled;

  static const OcrLanguage defaultLanguage = OcrLanguage(
    code: 'eng',
    name: 'English',
    nativeName: 'English',
    sizeMb: 4.1,
    isIndian: false,
    isBundled: true,
  );

  static const List<OcrLanguage> all = [
    // Default Bundled
    defaultLanguage,

    // Indian Languages
    OcrLanguage(code: 'hin', name: 'Hindi', nativeName: 'हिन्दी', sizeMb: 1.1, isIndian: true),
    OcrLanguage(code: 'guj', name: 'Gujarati', nativeName: 'ગુજરાતી', sizeMb: 1.4, isIndian: true),
    OcrLanguage(code: 'mar', name: 'Marathi', nativeName: 'मराठी', sizeMb: 2.1, isIndian: true),
    OcrLanguage(code: 'tam', name: 'Tamil', nativeName: 'தமிழ்', sizeMb: 3.2, isIndian: true),
    OcrLanguage(code: 'tel', name: 'Telugu', nativeName: 'తెలుగు', sizeMb: 2.8, isIndian: true),
    OcrLanguage(code: 'kan', name: 'Kannada', nativeName: 'ಕನ್ನಡ', sizeMb: 3.6, isIndian: true),
    OcrLanguage(code: 'mal', name: 'Malayalam', nativeName: 'മലയാളം', sizeMb: 5.3, isIndian: true),
    OcrLanguage(code: 'ben', name: 'Bengali', nativeName: 'বাংলা', sizeMb: 0.9, isIndian: true),
    OcrLanguage(code: 'pan', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', sizeMb: 0.5, isIndian: true),
    OcrLanguage(code: 'ori', name: 'Odia', nativeName: 'ଓଡ଼ିଆ', sizeMb: 1.5, isIndian: true),
    OcrLanguage(code: 'asm', name: 'Assamese', nativeName: 'অসমীয়া', sizeMb: 2.0, isIndian: true),
    OcrLanguage(code: 'urd', name: 'Urdu', nativeName: 'اردو', sizeMb: 1.4, isIndian: true),
    OcrLanguage(code: 'san', name: 'Sanskrit', nativeName: 'संस्कृतम्', sizeMb: 12.4, isIndian: true),

    // International Languages
    OcrLanguage(code: 'spa', name: 'Spanish', nativeName: 'Español', sizeMb: 2.3, isIndian: false),
    OcrLanguage(code: 'fra', name: 'French', nativeName: 'Français', sizeMb: 1.1, isIndian: false),
    OcrLanguage(code: 'deu', name: 'German', nativeName: 'Deutsch', sizeMb: 1.5, isIndian: false),
    OcrLanguage(code: 'ara', name: 'Arabic', nativeName: 'العربية', sizeMb: 1.4, isIndian: false),
    OcrLanguage(code: 'por', name: 'Portuguese', nativeName: 'Português', sizeMb: 2.0, isIndian: false),
    OcrLanguage(code: 'rus', name: 'Russian', nativeName: 'Русский', sizeMb: 3.9, isIndian: false),
    OcrLanguage(code: 'ita', name: 'Italian', nativeName: 'Italiano', sizeMb: 2.7, isIndian: false),
    OcrLanguage(code: 'tur', name: 'Turkish', nativeName: 'Türkçe', sizeMb: 4.6, isIndian: false),
    OcrLanguage(code: 'ind', name: 'Indonesian', nativeName: 'Bahasa Indonesia', sizeMb: 1.1, isIndian: false),
    OcrLanguage(code: 'vie', name: 'Vietnamese', nativeName: 'Tiếng Việt', sizeMb: 0.5, isIndian: false),
    OcrLanguage(code: 'chi_sim', name: 'Chinese (Simplified)', nativeName: '简体中文', sizeMb: 10.5, isIndian: false),
    OcrLanguage(code: 'jpn', name: 'Japanese', nativeName: '日本語', sizeMb: 14.8, isIndian: false),
    OcrLanguage(code: 'kor', name: 'Korean', nativeName: '한국어', sizeMb: 7.8, isIndian: false),
  ];

  static OcrLanguage fromCode(String code) {
    return all.firstWhere((l) => l.code == code, orElse: () => defaultLanguage);
  }
}
