import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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
  }

  void setTextColor(int v) {
    textColor.value = v;
    _box.write('textColor', v);
  }

  void setChineseVariant(String v) {
    chineseVariant.value = v;
    _box.write('chineseVariant', v);
  }
}
