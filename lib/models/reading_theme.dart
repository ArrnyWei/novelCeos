import 'package:flutter/material.dart';

/// 預設閱讀主題包：一鍵套用 bg + text + line spacing 組合。
/// 部分主題標記為 Premium，未訂閱者點擊 → 跳訂閱頁。
class ReadingTheme {
  final String id;
  final String label;
  final int backgroundColor;
  final int textColor;
  final double? lineSpacing; // null = 不動目前行距
  final bool isPremium;

  const ReadingTheme({
    required this.id,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.lineSpacing,
    this.isPremium = false,
  });

  Color get bgColor => Color(backgroundColor);
  Color get fgColor => Color(textColor);

  static const List<ReadingTheme> presets = [
    // 免費：對應現有 5 個 bg preset 的「組合版」中性主題
    ReadingTheme(
      id: 'classic',
      label: '經典',
      backgroundColor: 0xFFFFFFFF,
      textColor: 0xFF000000,
    ),
    ReadingTheme(
      id: 'soft',
      label: '柔和',
      backgroundColor: 0xFFF5F5DC,
      textColor: 0xFF333333,
    ),
    // Premium-only 主題
    ReadingTheme(
      id: 'eyecare',
      label: '護眼黃',
      backgroundColor: 0xFFF8E9C9,
      textColor: 0xFF3E2C1C,
      lineSpacing: 1.8,
      isPremium: true,
    ),
    ReadingTheme(
      id: 'parchment',
      label: '羊皮紙',
      backgroundColor: 0xFFEEDEC2,
      textColor: 0xFF4A3A26,
      lineSpacing: 1.7,
      isPremium: true,
    ),
    ReadingTheme(
      id: 'midnight',
      label: '深夜',
      backgroundColor: 0xFF0E1116,
      textColor: 0xFFC9D1D9,
      lineSpacing: 1.9,
      isPremium: true,
    ),
    ReadingTheme(
      id: 'ink',
      label: '灰墨',
      backgroundColor: 0xFF222222,
      textColor: 0xFFD0D0D0,
      lineSpacing: 1.7,
      isPremium: true,
    ),
    ReadingTheme(
      id: 'forest',
      label: '森林',
      backgroundColor: 0xFFD8E8DA,
      textColor: 0xFF1F3326,
      lineSpacing: 1.7,
      isPremium: true,
    ),
  ];

  static ReadingTheme? findById(String? id) {
    if (id == null) return null;
    for (final t in presets) {
      if (t.id == id) return t;
    }
    return null;
  }
}

/// Premium 字體選擇。免費版本只有 default（`null` = 使用全 app 預設 Noto Sans TC）。
/// Premium 解鎖其他選項。所有字體都透過 google_fonts 動態載入。
class ReadingFont {
  final String id;
  final String label;
  final String googleFontName; // 對應 GoogleFonts API 名稱
  final bool isPremium;

  const ReadingFont({
    required this.id,
    required this.label,
    required this.googleFontName,
    this.isPremium = false,
  });

  static const List<ReadingFont> presets = [
    // 免費：預設無襯線
    ReadingFont(
      id: 'noto_sans',
      label: '黑體（Noto Sans）',
      googleFontName: 'Noto Sans TC',
    ),
    // Premium：襯線、楷體、圓體等
    ReadingFont(
      id: 'noto_serif',
      label: '宋體（Noto Serif）',
      googleFontName: 'Noto Serif TC',
      isPremium: true,
    ),
    ReadingFont(
      id: 'long_cang',
      label: '行楷（Long Cang）',
      googleFontName: 'Long Cang',
      isPremium: true,
    ),
    ReadingFont(
      id: 'ma_shan_zheng',
      label: '楷體（Ma Shan Zheng）',
      googleFontName: 'Ma Shan Zheng',
      isPremium: true,
    ),
    ReadingFont(
      id: 'zcool_kuaile',
      label: '圓體（ZCOOL KuaiLe）',
      googleFontName: 'ZCOOL KuaiLe',
      isPremium: true,
    ),
  ];

  static ReadingFont findById(String? id) {
    if (id == null) return presets.first;
    for (final f in presets) {
      if (f.id == id) return f;
    }
    return presets.first;
  }
}
