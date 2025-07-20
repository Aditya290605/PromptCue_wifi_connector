import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_connect_app/core/utils/wifi_permission.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifi_iot/wifi_iot.dart';
import '../../../../core/constants/wifi_db.dart';
import 'dart:convert';

class WifiHomePage extends StatefulWidget {
  const WifiHomePage({super.key});

  @override
  State<WifiHomePage> createState() => _WifiHomePageState();
}

class _WifiHomePageState extends State<WifiHomePage> {
  List<WiFiAccessPoint> availableNetworks = [];

  Future<void> scanAndMatchNetworks() async {
    bool hasPermission = await PermissionUtils.requestLocationPermission();
    if (!hasPermission) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Permission Denied"),
          content: Text("Location permission is required to scan WiFi."),
        ),
      );
      final permissionStatus = await Permission.location.status;
      debugPrint("Location status: $permissionStatus");

      return;
    }

    final can = await WiFiScan.instance.canStartScan();
    if (can != CanStartScan.yes) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cannot scan WiFi: $can")));
      return;
    }

    await WiFiScan.instance.startScan();
    final result = await WiFiScan.instance.getScannedResults();
    setState(() {
      availableNetworks = result
          .where((r) => wifiDatabase.any((d) => d['ssid'] == r.ssid))
          .toList();
    });
  }

  void connectToNetwork(String ssid) {
    final match = wifiDatabase.firstWhere((e) => e['ssid'] == ssid);
    final passwordEncoded = match['password_encrypted'];
    final password = utf8.decode(base64.decode(passwordEncoded.toString()));

    WiFiForIoTPlugin.connect(
      ssid,
      password: password,
      security: NetworkSecurity.WPA,
      joinOnce: true,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Connecting to $ssid...")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WiFi Connect App")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: scanAndMatchNetworks,
              child: const Text("Scan & Connect to WiFi"),
            ),
          ),
          const SizedBox(height: 20),
          if (availableNetworks.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: availableNetworks.length,
                itemBuilder: (context, index) {
                  final wifi = availableNetworks[index];
                  return ListTile(
                    title: Text(wifi.ssid),
                    subtitle: Text("Signal: ${wifi.level}"),
                    onTap: () => connectToNetwork(wifi.ssid),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
