import 'dart:html' as html;

void redirectToTelegram({Duration delay = const Duration(seconds: 2)}) {
  Future.delayed(delay, () {
    html.window.location.href = 'https://web.telegram.org/';
  });
}