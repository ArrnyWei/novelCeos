import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFF79230),
      surfaceTint: Color(0xFFF79230),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdcc0),
      onPrimaryContainer: Color(0xff6b3b03),
      secondary: Color(0xff735943),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdcc0),
      onSecondaryContainer: Color(0xff5a422d),
      tertiary: Color(0xff5a6238),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffdee8b2),
      onTertiaryContainer: Color(0xff424a23),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff221a14),
      onSurfaceVariant: Color(0xff51443a),
      outline: Color(0xff837469),
      outlineVariant: Color(0xffd5c3b6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff372f28),
      inversePrimary: Color(0xffffb877),
      primaryFixed: Color(0xffffdcc0),
      onPrimaryFixed: Color(0xff2d1600),
      primaryFixedDim: Color(0xffffb877),
      onPrimaryFixedVariant: Color(0xff6b3b03),
      secondaryFixed: Color(0xffffdcc0),
      onSecondaryFixed: Color(0xff291706),
      secondaryFixedDim: Color(0xffe2c0a5),
      onSecondaryFixedVariant: Color(0xff5a422d),
      tertiaryFixed: Color(0xffdee8b2),
      onTertiaryFixed: Color(0xff181e00),
      tertiaryFixedDim: Color(0xffc2cb98),
      onTertiaryFixedVariant: Color(0xff424a23),
      surfaceDim: Color(0xffe6d7cd),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1e8),
      surfaceContainer: Color(0xfffbebe1),
      surfaceContainerHigh: Color(0xfff5e5db),
      surfaceContainerHighest: Color(0xffefe0d5),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff542c00),
      surfaceTint: Color(0xff87521b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff986028),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff47321e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff836851),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff323914),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff697146),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff17100a),
      onSurfaceVariant: Color(0xff40342a),
      outline: Color(0xff5d5046),
      outlineVariant: Color(0xff796a5f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff372f28),
      inversePrimary: Color(0xffffb877),
      primaryFixed: Color(0xff986028),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff7b4912),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff836851),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff69503a),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff697146),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff50592f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd2c4ba),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1e8),
      surfaceContainer: Color(0xfff5e5db),
      surfaceContainerHigh: Color(0xffe9dad0),
      surfaceContainerHighest: Color(0xffdecfc5),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff452400),
      surfaceTint: Color(0xff87521b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6e3d05),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3c2815),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5c442f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff282f0a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff454d25),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff352a21),
      outlineVariant: Color(0xff53473d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff372f28),
      inversePrimary: Color(0xffffb877),
      primaryFixed: Color(0xff6e3d05),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff4f2900),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5c442f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff432e1b),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff454d25),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff2f3610),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc4b6ad),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffeeee3),
      surfaceContainer: Color(0xffefe0d5),
      surfaceContainerHigh: Color(0xffe1d2c8),
      surfaceContainerHighest: Color(0xffd2c4ba),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFFFB877),
      surfaceTint: Color(0xFFFFB877),
      onPrimary: Color(0xff4b2700),
      primaryContainer: Color(0xff6b3b03),
      onPrimaryContainer: Color(0xffffdcc0),
      secondary: Color(0xffe2c0a5),
      onSecondary: Color(0xff412c19),
      secondaryContainer: Color(0xff5a422d),
      onSecondaryContainer: Color(0xffffdcc0),
      tertiary: Color(0xffc2cb98),
      onTertiary: Color(0xff2c340e),
      tertiaryContainer: Color(0xff424a23),
      onTertiaryContainer: Color(0xffdee8b2),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xFF1B1B1B),
      onSurface: Color(0xffefe0d5),
      onSurfaceVariant: Color(0xffd5c3b6),
      outline: Color(0xff9e8e82),
      outlineVariant: Color(0xff51443a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffefe0d5),
      inversePrimary: Color(0xFFF79230),
      primaryFixed: Color(0xffffdcc0),
      onPrimaryFixed: Color(0xff2d1600),
      primaryFixedDim: Color(0xffffb877),
      onPrimaryFixedVariant: Color(0xff6b3b03),
      secondaryFixed: Color(0xffffdcc0),
      onSecondaryFixed: Color(0xff291706),
      secondaryFixedDim: Color(0xffe2c0a5),
      onSecondaryFixedVariant: Color(0xff5a422d),
      tertiaryFixed: Color(0xffdee8b2),
      onTertiaryFixed: Color(0xff181e00),
      tertiaryFixedDim: Color(0xffc2cb98),
      onTertiaryFixedVariant: Color(0xff424a23),
      surfaceDim: Color(0xFF1B1B1B),
      surfaceBright: Color(0xff413730),
      surfaceContainerLowest: Color(0xFF121212),
      surfaceContainerLow: Color(0xFF1B1B1B),
      surfaceContainer: Color(0xFF242424),
      surfaceContainerHigh: Color(0xFF2C2C2C),
      surfaceContainerHighest: Color(0xFF353535),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd4b1),
      surfaceTint: Color(0xffffb877),
      onPrimary: Color(0xff3c1e00),
      primaryContainer: Color(0xffc28348),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfff9d6b9),
      onSecondary: Color(0xff35210f),
      secondaryContainer: Color(0xffa98b72),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffd8e1ac),
      onTertiary: Color(0xff222905),
      tertiaryContainer: Color(0xff8c9566),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff19120c),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffecd9cb),
      outline: Color(0xffc0afa2),
      outlineVariant: Color(0xff9d8d81),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffefe0d5),
      inversePrimary: Color(0xff6c3c04),
      primaryFixed: Color(0xffffdcc0),
      onPrimaryFixed: Color(0xff1f0d00),
      primaryFixedDim: Color(0xffffb877),
      onPrimaryFixedVariant: Color(0xff542c00),
      secondaryFixed: Color(0xffffdcc0),
      onSecondaryFixed: Color(0xff1d0d01),
      secondaryFixedDim: Color(0xffe2c0a5),
      onSecondaryFixedVariant: Color(0xff47321e),
      tertiaryFixed: Color(0xffdee8b2),
      onTertiaryFixed: Color(0xff0e1300),
      tertiaryFixedDim: Color(0xffc2cb98),
      onTertiaryFixedVariant: Color(0xff323914),
      surfaceDim: Color(0xff19120c),
      surfaceBright: Color(0xff4c433b),
      surfaceContainerLowest: Color(0xff0c0603),
      surfaceContainerLow: Color(0xff241c16),
      surfaceContainer: Color(0xff2e2620),
      surfaceContainerHigh: Color(0xff3a312a),
      surfaceContainerHighest: Color(0xff453c35),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffede0),
      surfaceTint: Color(0xffffb877),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xfffab474),
      onPrimaryContainer: Color(0xff160800),
      secondary: Color(0xffffede0),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffdebca1),
      onSecondaryContainer: Color(0xff160800),
      tertiary: Color(0xffecf5bf),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffbec894),
      onTertiaryContainer: Color(0xff090d00),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff19120c),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffede0),
      outlineVariant: Color(0xffd1bfb2),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffefe0d5),
      inversePrimary: Color(0xff6c3c04),
      primaryFixed: Color(0xffffdcc0),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb877),
      onPrimaryFixedVariant: Color(0xff1f0d00),
      secondaryFixed: Color(0xffffdcc0),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffe2c0a5),
      onSecondaryFixedVariant: Color(0xff1d0d01),
      tertiaryFixed: Color(0xffdee8b2),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffc2cb98),
      onTertiaryFixedVariant: Color(0xff0e1300),
      surfaceDim: Color(0xff19120c),
      surfaceBright: Color(0xff584e47),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff261e18),
      surfaceContainer: Color(0xff372f28),
      surfaceContainerHigh: Color(0xff433a33),
      surfaceContainerHighest: Color(0xff4f453e),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.brightness == Brightness.light
              ? const Color(0xFFF79230)
              : colorScheme.surface,
          foregroundColor: colorScheme.brightness == Brightness.light
              ? Colors.white
              : colorScheme.onSurface,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: colorScheme.brightness == Brightness.light
              ? const Color(0xFFF79230).withAlpha(90)
              : colorScheme.primary.withAlpha(90),
        ),
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
