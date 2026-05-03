import 'package:flutter/material.dart';

/// 收藏小說的閱讀狀態。儲存於 `favNovel.status` 欄位（int）。
/// 數字值決定排序（不要隨意改），新增類型請 append 到尾端。
enum ReadingStatus {
  reading(0, '閱讀中', Icons.menu_book),
  completed(1, '已完結', Icons.check_circle_outline),
  paused(2, '暫停', Icons.pause_circle_outline),
  dropped(3, '已棄', Icons.cancel_outlined);

  final int dbValue;
  final String label;
  final IconData icon;
  const ReadingStatus(this.dbValue, this.label, this.icon);

  static ReadingStatus fromDb(int? value) {
    if (value == null) return ReadingStatus.reading;
    for (final s in ReadingStatus.values) {
      if (s.dbValue == value) return s;
    }
    return ReadingStatus.reading;
  }
}
