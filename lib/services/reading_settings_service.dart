import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/reading_theme.dart';

/// Persistent reading settings — translates Swift's UserDefaults reading prefs.
class ReadingSettingsService extends GetxController {
  final _box = GetStorage();

  late final fontSize = _box.read<double>('fontSize')?.obs ?? 16.0.obs;
  late final lineSpacing = _box.read<double>('lineSpacing')?.obs ?? 1.8.obs;
  late final readingDirection =
      (_box.read<String>('readingDirection') ?? 'vertical').obs;
  late final backgroundColor =
      (_box.read<int>('backgroundColor') ?? Colors.white.toARGB32()).obs;
  late final textColor =
      (_box.read<int>('textColor') ?? Colors.black.toARGB32()).obs;
  late final chineseVariant =
      (_box.read<String>('chineseVariant') ?? 'traditional').obs;

  /// Premium 字體選擇 id（對應 ReadingFont.presets[i].id）。
  /// 預設為 `noto_sans`（免費），切到 Premium 字體會被 UI gating 擋下，
  /// 但 service 自己不做訂閱檢查 — 由 UI 層判斷。
  late final fontFamilyId =
      (_box.read<String>('fontFamilyId') ?? ReadingFont.presets.first.id).obs;

  /// 目前套用的閱讀主題 id（null = 使用者用獨立 bg / text 自訂，未套主題）。
  late final selectedThemeId = Rx<String?>(_box.read<String>('selectedThemeId'));

  void setFontSize(double v) {
    fontSize.value = v;
    _box.write('fontSize', v);
  }

  void setLineSpacing(double v) {
    lineSpacing.value = v;
    _box.write('lineSpacing', v);
  }

  void setReadingDirection(String v) {
    readingDirection.value = v;
    _box.write('readingDirection', v);
  }

  void setBackgroundColor(int v) {
    backgroundColor.value = v;
    _box.write('backgroundColor', v);
    // 手動換顏色 → 取消套用的主題（避免 UI 顯示「主題已套用」與實際顏色不同步）
    if (selectedThemeId.value != null) {
      selectedThemeId.value = null;
      _box.remove('selectedThemeId');
    }
  }

  void setTextColor(int v) {
    textColor.value = v;
    _box.write('textColor', v);
    if (selectedThemeId.value != null) {
      selectedThemeId.value = null;
      _box.remove('selectedThemeId');
    }
  }

  void setChineseVariant(String v) {
    chineseVariant.value = v;
    _box.write('chineseVariant', v);
  }

  void setFontFamilyId(String id) {
    fontFamilyId.value = id;
    _box.write('fontFamilyId', id);
  }

  /// 套用閱讀主題：覆蓋 bg + text + 可選的 lineSpacing。
  /// 不檢查訂閱狀態 — 由 UI 層阻擋 Premium 主題。
  void applyTheme(ReadingTheme theme) {
    backgroundColor.value = theme.backgroundColor;
    textColor.value = theme.textColor;
    _box.write('backgroundColor', theme.backgroundColor);
    _box.write('textColor', theme.textColor);
    if (theme.lineSpacing != null) {
      lineSpacing.value = theme.lineSpacing!;
      _box.write('lineSpacing', theme.lineSpacing);
    }
    selectedThemeId.value = theme.id;
    _box.write('selectedThemeId', theme.id);
  }
}
