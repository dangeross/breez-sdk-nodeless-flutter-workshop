import 'package:breez_sdk_nodeless_flutter_workshop/home/home_page.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  static const title = 'Breez SDK Nodeless Demo';

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: App.title,
      theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.white), useMaterial3: true),
      home: HomePage(),
    );
  }
}
