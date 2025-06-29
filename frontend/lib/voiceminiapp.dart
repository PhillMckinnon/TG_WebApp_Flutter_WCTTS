// dart imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';

//telegram imports
import 'package:telegram_flutter/telegram_js.dart';
// web imports
import 'dart:html' as html;
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:telegram_flutter/env.dart';
// theme imports
import 'package:telegram_flutter/Themes/Theme.dart';
import 'package:telegram_flutter/language_data/language_selector.dart';
import 'package:telegram_flutter/language_data/language_data.dart';
import 'Themes/theme_notifier.dart';

// function imports
import 'functions/play_ready.dart';
import 'functions/redirect_user.dart';


class VoiceMiniApp extends StatelessWidget {
  const VoiceMiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Speech App',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          debugShowCheckedModeBanner: false,
          home: HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int usage = 0;
  int limit = 3;
  late String rawInitData;
  @override
  void initState() {
    super.initState();
    ready();
    rawInitData = initData;
    // print('Telegram WebApp version: $version');
    // print(initDataUnsafe);
    final user = initDataUnsafe.user;
    if (user != null)
    {
    // print('User ID: ${user.id}, Name: ${user.first_name}, Username: ${user.username}');
    showAlert("Welcome to the app ${user.first_name}!");
    markUserActive(user.id.toString(), user.username);
    fetchUsage();
    }
    else {
    showAlert("Please open this app on Telegram!");
    redirectToTelegram();
    // print('no user data found');
    }
  }
  Future<void> fetchUsage() async {
  try {
    final userId = initDataUnsafe.user?.id;
    if (userId == null || rawInitData == null) {
      // print('User ID or initData not available');
      return;
    }

    final uri = Uri.parse('${env.API_URL}/api/usage/$userId');
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json',
                'X-Telegram-InitData': rawInitData, 
                'ngrok-skip-browser-warning': 'true',
                 "User-Agent": "MyCustomClient/1.0"
                },
      
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        usage = data['usage'] ?? 0;
        limit = data['limit'] ?? 3;
      });
    } else {
      throw Exception('Failed to load usage data');
    }
  } catch (e) {
    showAlert("Error, please reload the page.");
    // print("Error fetching usage: $e");
  }
}

Future<void> markUserActive(String userId, String username) async {
  try {
    if (rawInitData == null) {
      // print("No initData for auth");
      return;
    }
    final uri = Uri.parse('${env.API_URL}/api/mark_active');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json',
                'X-Telegram-InitData': rawInitData,
                'ngrok-skip-browser-warning': "1",
                 "User-Agent": "MyCustomClient/1.0"
                },
      body: jsonEncode({                      
        'user_id': userId,
        'username': username,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      // print('User marked active successfully.');
    } else {
      // print('Failed to mark user active: ${response.statusCode}');
    }
  } catch (e) {
    showAlert("Error, please reload the page.");
    // print('Error marking user active: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Menu')),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose an Option',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            NiceButtons(
              startColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.deepPurple
                      : const Color.fromARGB(255, 47, 212, 149),
              endColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.purple
                      : const Color.fromARGB(255, 121, 255, 203),
              borderColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : const Color.fromARGB(255, 0, 0, 0),
              progress: false,
              stretch: false,
              onTap:
                  (value) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TranscribeScreen(rawInitData: rawInitData)),
                  ),
              child: const Text('Transcribe Audio'),
            ),
            const SizedBox(height: 25),
            NiceButtons(
              startColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.deepPurple
                      : const Color.fromARGB(255, 47, 212, 149),
              endColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.purple
                      : const Color.fromARGB(255, 121, 255, 203),
              borderColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : const Color.fromARGB(255, 0, 0, 0),
              stretch: false,
              onTap:
                  (value) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SynthesizeScreen(rawInitData: rawInitData)),
                  ),
              child: const Text('Synthesize Voice'),
            ),
            const SizedBox(height: 25),
            IconButton(
              onPressed: () {
                ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(
                  context,
                  listen: false,
                );
                if (themeNotifier.themeMode == ThemeMode.light) {
                  themeNotifier.setTheme(ThemeMode.dark);
                } else {
                  themeNotifier.setTheme(ThemeMode.light);
                }
              },
              icon: const Icon(CupertinoIcons.brightness),
            ),
            SizedBox(height: 20),
            Text("You've used $usage out of $limit"),
          ],
        ),
      ),
    );
  }
}

class TranscribeScreen extends StatefulWidget {
  final String rawInitData;
  const TranscribeScreen({super.key, required this.rawInitData});

  @override
  State<TranscribeScreen> createState() => _TranscribeScreenState();
}

class _TranscribeScreenState extends State<TranscribeScreen> {
    late String rawInitData;
    @override
    void initState() {
    super.initState();
    rawInitData = widget.rawInitData;
}
  TextEditingController textController = TextEditingController();
  bool isLoading = false;
  MediaType _getMediaTypeFromFileName(String filename) {
  if (filename.endsWith('.wav')) return MediaType('audio', 'wav');
  if (filename.endsWith('.mp3')) return MediaType('audio', 'mpeg');
  if (filename.endsWith('.ogg')) return MediaType('audio', 'ogg');
  return MediaType('application', 'octet-stream');
}
Future<void> pickFile() async {
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'audio/*';
  uploadInput.click();

  uploadInput.onChange.listen((e) async {
    final file = uploadInput.files?.first;
    if (file == null) return;

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);

reader.onLoadEnd.listen((event) async {
  if (!mounted) return;

  setState(() => isLoading = true);
  Uint8List data;
  if (reader.result is ByteBuffer) {
    data = (reader.result as ByteBuffer).asUint8List();
  } else if (reader.result is Uint8List) {
    data = reader.result as Uint8List;
  } else {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unsupported file data type")),
    );
    return;
  }

  final uri = Uri.parse('${env.API_URL}/api/transcribe');
  final request = http.MultipartRequest('POST', uri)
    ..files.add(http.MultipartFile.fromBytes(
      'file',
      data,
      filename: file.name,
      contentType: _getMediaTypeFromFileName(file.name),
    ));
  request.headers['ngrok-skip-browser-warning'] = '1';
  request.headers["User-Agent"] = "MyCustomClient/1.0";
  request.headers['X-Telegram-InitData'] = rawInitData;
  try {
    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    // print('Response raw data: $responseData');

    final jsonResponse = json.decode(responseData);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      playAlertSound_Good();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transcription complete")),
      );
      if (!mounted) return;
      setState(() => textController.text = jsonResponse['text']);
    } else {
      playAlertSound_Bad();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed")),
      );
      if (!mounted) return;
      setState(() => textController.text = 'Error: ${jsonResponse['error']}');
    }
  } catch (e) {
    if (!mounted) return;
    setState(() => isLoading = false);
    playAlertSound_Bad();
    // print('Error during JSON decode or network: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
});
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transcribe Audio')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              isLoading
                  ? Container()
                  : NiceButtons(
                    startColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.deepPurple
                            : const Color.fromARGB(255, 47, 212, 149),
                    endColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.purple
                            : const Color.fromARGB(255, 121, 255, 203),
                    borderColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : const Color.fromARGB(255, 0, 0, 0),
                    stretch: false,
                    onTap: (value) => pickFile(),
                    child: const Text('Upload Audio'),
                  ),
              SizedBox(height: 20),
              isLoading 
              ? CircularProgressIndicator() 
              : TextField(
                controller: textController,
                readOnly: true,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Upload audio to transcribe...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SynthesizeScreen extends StatefulWidget {
  final String rawInitData;
  const SynthesizeScreen({super.key, required this.rawInitData});

  @override
  State<SynthesizeScreen> createState() => _SynthesizeScreenState();
}

class _SynthesizeScreenState extends State<SynthesizeScreen> {
  late String rawInitData;

@override
void initState()   {
      super.initState();
    rawInitData = widget.rawInitData;
  player.onPlayerStateChanged.listen((PlayerState state) {

    
    if (!mounted) return;
    setState(() {
      playerState = state;
    });
  });

    textController.addListener(() {
      if (textController.text.length >= maxChars) {
        if (!mounted) return;
        setState(() {
          warningMessage = 'You have reached the $maxChars character limit!';
        });
      } else {
        if (!mounted) return;
        setState(() {
          warningMessage = null;
        });
      }
    });
  }
  

  MediaType _getMediaTypeFromFileName(String filename) {
  final ext = filename.toLowerCase().split('.').last;
  switch (ext) {
    case 'wav':
      return MediaType('audio', 'wav');
    case 'mp3':
      return MediaType('audio', 'mpeg');
    case 'ogg':
      return MediaType('audio', 'ogg');
    default:
      return MediaType('application', 'octet-stream');
  }
}
  TextEditingController textController = TextEditingController();
  Uint8List? audioBytes;
  String? audioFileName;
  Uint8List? outputAudioBytes;
  LanguageData? selectedlanguage;
  LanguageData? detectedlang;
  
  AudioPlayer player = AudioPlayer();
  PlayerState playerState = PlayerState.stopped;
  bool isLoading = false;

  void handleuploadresponse(String resultIsoCode) {
    if (!mounted) return;
    setState(() {
      detectedlang = supportedLanguages.firstWhere(
        (lang) => lang.isoCode == resultIsoCode,
        orElse: () => supportedLanguages.first,
      );
    });
  }

  Future<void> detectlanguage(Uint8List audio, String filename) async {
    var request = http.MultipartRequest(
    'POST',
    Uri.parse('${env.API_URL}/api/detect'),
  )..files.add(
      http.MultipartFile.fromBytes(
        'file',
        audio,
        filename: filename,
        contentType: _getMediaTypeFromFileName(filename),
      ),
    );
    request.headers['ngrok-skip-browser-warning'] = '1';
    request.headers["User-Agent"] = "MyCustomClient/1.0";
    request.headers['X-Telegram-InitData'] = initData;

  try {
    var response = await request.send();
    final respString = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResp = jsonDecode(respString);
      handleuploadresponse(jsonResp['language']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Detected Language: ${jsonResp['language']}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $respString')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed: $e')),
    );
  }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null && result.files.single.path != null) {
    audioBytes = result.files.single.bytes;
    audioFileName = result.files.single.name;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Voice sample loading")),
    );
    await detectlanguage(audioBytes!, audioFileName!);
    }
  }
  Future<void> pickFilesynth() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.audio,
    withData: true, 
  );
  if (result != null && result.files.single.bytes != null) {
    audioBytes = result.files.single.bytes;
    audioFileName = result.files.single.name;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Voice sample loaded")),
    );
    await detectlanguage(audioBytes!, audioFileName!);
  }
}
  Future<void> synthesize() async {
    if (audioBytes == null || textController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Upload a file and enter text")),
    );
    return;
  }

  setState(() => isLoading = true);

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('${env.API_URL}/api/synthesize'),
  )
    ..files.add(
      http.MultipartFile.fromBytes(
        'file',
        audioBytes!,
        filename: audioFileName!,
        contentType: _getMediaTypeFromFileName(audioFileName!),
      ),
    )
    ..fields['text'] = textController.text;
    request.headers['ngrok-skip-browser-warning'] = '1';
    request.headers["User-Agent"] = "MyCustomClient/1.0";
    request.headers['X-Telegram-InitData'] = initData;


  try {
    var response = await request.send();

    if (response.statusCode == 200) {
      outputAudioBytes = await response.stream.toBytes();
      // await SystemSound.play(SystemSoundType.alert);
      playAlertSound_Good();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Synthesis complete")),
      );
    } else {
      final resp = await response.stream.bytesToString();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $resp")),
      );
    }
  } catch (e) {
    playAlertSound_Bad();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed: $e")),
    );
  } finally {
    if (!mounted) return;
    setState(() => isLoading = false);
  }
  }

String createBlobUrl(Uint8List bytes) {
  final blob = html.Blob([bytes]);
  return html.Url.createObjectUrlFromBlob(blob);
}
  Future<void> saveFile() async {
     if (outputAudioBytes == null) return;

  final blob = html.Blob([outputAudioBytes!]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "synthesized.wav")
    ..click();

  html.Url.revokeObjectUrl(url);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Download started")),
  );
  }


Widget buildAudioControls() {
  if (outputAudioBytes == null) return const SizedBox();

  return Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow,
          ),
          iconSize: 32,
          onPressed: () async {
            if (playerState == PlayerState.playing) {
              await player.pause();
            } else {
              final blobUrl = createBlobUrl(outputAudioBytes!);
              await player.play(UrlSource(blobUrl));
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: saveFile,
        ),
      ],
    ),
    const SizedBox(height: 8),
    const Text('Downloading is not available on mobile'),
  ],
);
}

  final int maxChars = 500;
  String? warningMessage;
  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Synthesize Voice')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              isLoading 
              ? Container()
              : NiceButtons(
                startColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.deepPurple
                        : const Color.fromARGB(255, 47, 212, 149),
                endColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.purple
                        : const Color.fromARGB(255, 121, 255, 203),
                borderColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 0, 0, 0)
                        : const Color.fromARGB(255, 0, 0, 0),
                stretch: false,
                onTap: (value) => pickFile(),
                child: const Text('Upload Sample Voice'),
              ),
              const SizedBox(height: 20),
              isLoading 
              ? CircularProgressIndicator()
              : TextField(
                maxLength: maxChars,
                controller: textController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Enter text to synthesize...',
                  border: OutlineInputBorder(),
                  errorText: warningMessage,
                ),
              ),

              const SizedBox(height: 20),
              isLoading
                  ? Container()
                  : NiceButtons(
                    startColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.deepPurple
                            : const Color.fromARGB(255, 47, 212, 149),
                    endColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.purple
                            : const Color.fromARGB(255, 121, 255, 203),
                    borderColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : const Color.fromARGB(255, 0, 0, 0),
                    stretch: false,
                    onTap: (value) => synthesize(),
                    child: const Text('Synthesize'),
                  ),
              const SizedBox(height: 30),
 if (detectedlang != null)
               isLoading ? Container() 
              : LanguageSelector(
                  detectedLang: detectedlang == null
    ? ""
    : '${detectedlang!.emojiFlag} ${detectedlang!.name} (${detectedlang!.isoCode})',
                  selectedOutputLang: selectedlanguage ?? detectedlang,
                  onOutputLangChanged: (lang) {
                    if (!mounted) return;
                    setState(() {
                      selectedlanguage = lang;
                    });
                  },
                ),
                  const SizedBox(height: 20),
                  isLoading ? Container()
                 : buildAudioControls(),
            ],
          ),
        ),
      ),
    );
  }
}
