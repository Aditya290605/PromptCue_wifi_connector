// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:wifi_connect_app/feature/wifi_connect/presentation/pages/home_page.dart';

void main() {
  runApp(const WifiConnectApp());
}

class WifiConnectApp extends StatelessWidget {
  const WifiConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Connect App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const WifiHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
