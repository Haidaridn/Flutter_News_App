import 'package:flutter/material.dart';

/// Kumpulan warna yang dipakai di seluruh aplikasi.
abstract final class AppColors {
  static const Color primary = Color(0xFF1D4ED8);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color border = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFB91C1C);
}

/// Jarak antarelemen menggunakan kelipatan delapan.
abstract final class AppSpacing {
  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
  static const double extraLarge = 32;
}

/// Ukuran elemen visual yang dipakai berulang pada layar aplikasi.
abstract final class AppSizes {
  static const double articleImageHeight = 176;
  static const double detailImageHeight = 240;
  static const double stateIcon = 48;
}

/// Aplikasi hanya memakai dua tingkat tipografi: judul dan isi.
abstract final class AppTextStyles {
  static const double titleSize = 20;
  static const double bodySize = 14;

  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: titleSize,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: bodySize,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}

/// Tema Material 3 menjadi sumber tampilan untuk seluruh widget aplikasi.
abstract final class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        titleLarge: AppTextStyles.title,
        bodyMedium: AppTextStyles.body,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.title,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        space: AppSpacing.medium,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}
