import 'package:flutter/material.dart';

// Colors
const Color primaryColor = Color(0xFFFE4030);
const Color secondaryColor = Color(0xFF6D737B);
const Color secondaryColorMuted = Color(0x8C6D737B);
const Color neutralIconColor = Color(0xFF666666);

// Base text styles
const TextStyle baseTextStyle = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w400,
  color: secondaryColor,
);

const TextStyle buttonTextStyle = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w600,
  fontSize: 16,
  color: Colors.white,
);

// Link text widget builder
Text linkTextStyleBuilder(String text, {bool underline = true}) => Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: primaryColor,
        fontSize: 14,
      ),
);

// Reusable rounded input border
OutlineInputBorder buildInputBorder15() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0x33000000)),
);
