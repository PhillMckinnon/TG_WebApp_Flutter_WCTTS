  String isoToEmoji(String isoCode) {
     final overrides = {
    'en': '🇬🇧', 
    'zh': '🇨🇳', 
  };

   if (overrides.containsKey(isoCode.toLowerCase())) {
    return overrides[isoCode.toLowerCase()]!;
  }

  return isoCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'), (match) {
    return String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397);
  });
}