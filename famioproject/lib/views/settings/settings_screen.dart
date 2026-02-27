import 'package:flutter/material.dart';
import 'package:famioproject/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Appearance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Font Size",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<double>(
              valueListenable: _settingsService.fontScale,
              builder: (context, scale, child) {
                return Column(
                  children: [
                    Slider(
                      value: scale,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      label: "${(scale * 100).toInt()}%",
                      onChanged: (value) {
                        _settingsService.updateFontScale(value);
                      },
                    ),
                    const SizedBox(height: 20),
                    // Preview Section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Preview Text",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textScaler: TextScaler.linear(
                                1.0,
                              ), // Keep title static or scaled? Let it scale normally
                            ),
                            const Divider(),
                            Text(
                              "This is how your text will look.",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Adjust the slider above to increase or decrease the text size across the app relative to your system settings.",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
