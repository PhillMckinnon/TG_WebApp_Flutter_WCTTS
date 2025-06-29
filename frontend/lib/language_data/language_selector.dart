import 'package:flutter/material.dart';
import 'language_data.dart';

class LanguageSelector extends StatelessWidget {
  final String detectedLang;
  final LanguageData? selectedOutputLang;
  final ValueChanged<LanguageData> onOutputLangChanged;

  const LanguageSelector({
    super.key,
    required this.detectedLang,
    required this.selectedOutputLang,
    required this.onOutputLangChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Detected Language 
        TextFormField(
          readOnly: true,
          controller: TextEditingController(text: detectedLang),
          decoration: const InputDecoration(
            labelText: "Detected Language",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Output Language
        DropdownButtonFormField<LanguageData>(
          decoration: const InputDecoration(
            labelText: "Output Language",
            border: OutlineInputBorder(),
          ),
          value: selectedOutputLang,
          items: supportedLanguages.map((lang) {
            return DropdownMenuItem<LanguageData>(
              value: lang,
              child: Text('${lang.emojiFlag} ${lang.name}'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onOutputLangChanged(value);
          },
        ),
      ],
    );
  }
}
