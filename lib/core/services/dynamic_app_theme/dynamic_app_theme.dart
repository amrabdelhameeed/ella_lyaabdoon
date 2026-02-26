import 'package:flutter/material.dart';

import '../app_services_database_provider.dart';

class DynamicAppTheme {
  static const List<Color> defaultColors = [
    Color(0xFF2E7D32), // Green (Default)
    Color(0xFF1976D2), // Blue
    Color(0xFFC2185B), // Pink
    Color(0xFFF57C00), // Orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFF00796B), // Teal
  ];

  static Color get currentSeedColor =>
      Color(AppServicesDBprovider.getAppColor());
}
