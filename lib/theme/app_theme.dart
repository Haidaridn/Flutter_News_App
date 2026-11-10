import 'package:flutter/material.dart';

/// Kumpulan warna yang dipakai di seluruh aplikasi.
abstract final class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFB91C1C);
  static const Color softBlue = Color(0xFFEFF6FF);
  static const Color imageSurface = Color(0xFFE8EFF8);
  static const Color overlayTop = Color(0x150F172A);
  static const Color overlayBottom = Color(0xD90F172A);
  static const Color onImage = Color(0xFFFFFFFF);
  static const Color featuredBadge = Color(0x660F172A);
}

/// Jarak antarelemen menggunakan kelipatan delapan.
abstract final class AppSpacing {
  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
  static const double extraLarge = 32;
  static const double page = 24;
}

/// Ukuran elemen visual yang dipakai berulang pada layar aplikasi.
abstract final class AppSizes {
  static const double articleImageHeight = 176;
  static const double featuredImageHeight = 288;
  static const double detailImageHeight = 320;
  static const double thumbnail = 112;
  static const double smallThumbnail = 88;
  static const double narrowCardWidth = 360;
  static const double stateIcon = 48;
  static const double cardRadius = 20;
  static const double imageRadius = 18;
  static const double pillRadius = 100;
  static const double pageMaxWidth = 900;
  static const double detailMaxWidth = 760;
  static const double stateMaxWidth = 420;
  static const double borderWidth = 1;
  static const double navigationHeight = 72;
}

/// Aplikasi hanya memakai dua tingkat tipografi: judul dan isi.
abstract final class AppTextStyles {
  static const double displaySize = 30;
  static const double titleSize = 22;
  static const double cardTitleSize = 17;
  static const double bodySize = 14;
  static const double captionSize = 12;

  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: titleSize,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle display = TextStyle(
    color: AppColors.textPrimary,
    fontSize: displaySize,
    fontWeight: FontWeight.w800,
    height: 1.14,
    letterSpacing: -0.9,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: cardTitleSize,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: bodySize,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.textSecondary,
    fontSize: captionSize,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle overline = TextStyle(
    color: AppColors.primary,
    fontSize: captionSize,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
  );

  static const TextStyle onImageTitle = TextStyle(
    color: AppColors.onImage,
    fontSize: titleSize,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle onImageCaption = TextStyle(
    color: AppColors.onImage,
    fontSize: captionSize,
    fontWeight: FontWeight.w600,
    height: 1.4,
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
    ).copyWith(primary: AppColors.primary, onPrimary: AppColors.onImage);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        displaySmall: AppTextStyles.display,
        titleLarge: AppTextStyles.title,
        titleMedium: AppTextStyles.cardTitle,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.caption,
        labelSmall: AppTextStyles.overline,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.title,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.softBlue,
        height: AppSizes.navigationHeight,
        labelTextStyle: const WidgetStatePropertyAll(AppTextStyles.caption),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary,
          );
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          side: const BorderSide(
            color: AppColors.border,
            width: AppSizes.borderWidth,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.pillRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.large,
            vertical: AppSpacing.medium,
          ),
        ),
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
