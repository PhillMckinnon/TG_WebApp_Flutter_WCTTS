import 'package:flutter/material.dart';
import 'package:telegram_flutter/voiceminiapp.dart';
import 'package:provider/provider.dart';
import 'Themes/Theme.dart';
import 'Themes/theme_notifier.dart';
void main() async {
  runApp(
    ChangeNotifierProvider(create: (_) => ThemeNotifier(),
    child: MyApp(),
    ),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) 
      {
        return MaterialApp( 
        title: 'Speech App',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeNotifier.themeMode,
        home: VoiceMiniApp(),
        debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
        
      

