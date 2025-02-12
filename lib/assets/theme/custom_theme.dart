import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/assets/theme/fonts/custom_fonts.dart';
import 'package:laser_car_battle/utils/constants.dart';

class CustomTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: CustomColors.background,
    primaryColor: CustomColors.mainButton,

    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(196, 79, 0, 0),
      foregroundColor: CustomColors.textPrimary,
      elevation: 4,
      titleTextStyle: CustomFonts.primaryFont.copyWith(
        color: CustomColors.textPrimary,
        fontSize: AppSizes.appBarTitle,
      ),
    ),

    textTheme: TextTheme(
      bodyLarge: CustomFonts.primaryFont.copyWith(
        color: CustomColors.textPrimary,
        fontSize: AppSizes.fontLarge,
      ),
      bodyMedium: CustomFonts.primaryFont.copyWith(
        color: CustomColors.textPrimary,
        fontSize: AppSizes.fontMedium,
      ),
      labelLarge: CustomFonts.primaryFont.copyWith(
        color: CustomColors.buttonText,
        fontSize: AppSizes.fontSmall,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColors.mainButton, // Button color
        foregroundColor: CustomColors.buttonText, // Text color
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: CustomFonts.primaryFont.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: CustomColors.border), // Border color
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CustomColors.buttonText,
        side: const BorderSide(color: CustomColors.border), // Border
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: CustomFonts.primaryFont.copyWith(fontSize: 16),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: CustomColors.actionButton,
      foregroundColor: CustomColors.textPrimary,
    ),

    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: CustomColors.border), // Border color
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: CustomColors.actionButton), // Focus color
      ),
      labelStyle: CustomFonts.primaryFont.copyWith(color: CustomColors.buttonText),
      hintStyle: CustomFonts.primaryFont.copyWith(color: CustomColors.buttonText),
    ),

    dividerColor: CustomColors.border, // Dividers color
  );
}
