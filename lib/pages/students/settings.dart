import '../../themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool switchValue = true;
  bool isToggled = false;

  @override
  Widget build(BuildContext context) {
    if (!isToggled) {
      switchValue = Theme.of(context).brightness == Brightness.dark;
      isToggled = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(12)
        ),
        margin: const EdgeInsets.all(25),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Dark Mode"),
            CupertinoSwitch(
              value: switchValue,
              onChanged: (bool value) {Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                setState(() {
                  switchValue = value;
                });
              },
              activeColor: CupertinoColors.activeBlue,
            )
          ],
        ),
      ),
    );
  }
}