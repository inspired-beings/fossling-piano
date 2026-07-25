import 'package:flutter/material.dart';

/// Shared with the accessibility tests so contrast is checked against the shipped colors.
ThemeData buildAppTheme() => ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: const Color(0xFF0C1A4B),
      useMaterial3: true,
    );
