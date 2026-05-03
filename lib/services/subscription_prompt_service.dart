import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'subscription_service.dart';

/// 統籌「升級訂閱」prompt 顯示時機與靜音邏輯。
///
/// 觸發：
/// - 每日首次冷啟動：[tryShowLaunchPrompt]
/// - 插頁廣告關閉、累計第 3 次：[onInterstitialDismissed]
///
/// 靜音：
/// - 已訂閱者完全跳過、不計數
/// - 累計關 3 次 prompt → 該 minor 版本不再顯示
/// - 每次 minor bump 重置（例：v1.4.x → v1.5.x 重置一次）
class SubscriptionPromptService extends GetxService {
  static const _kDismissCount = 'subPrompt.dismissCount';
  static const _kLastResetVersion = 'subPrompt.lastResetVersion';
  static const _kLastShownDate = 'subPrompt.lastShownDate';
  static const _kAdClosedCount = 'subPrompt.adClosedCount';

  static const int _maxDismissals = 3;
  static const int _adClosedThreshold = 3;

  final _storage = GetStorage();

  /// 版本檢查的 Future。所有 should/onXxx 都應該先 await，
  /// 避免 PackageInfo 還沒回來就誤用上次的計數。
  late final Future<void> _ready;

  @override
  void onInit() {
    super.onInit();
    _ready = _resetIfVersionChanged();
  }

  Future<void> _resetIfVersionChanged() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final minor = _toMinorKey(info.version);
      final lastReset = _storage.read<String>(_kLastResetVersion);
      if (lastReset != minor) {
        _storage.write(_kDismissCount, 0);
        _storage.write(_kLastResetVersion, minor);
      }
    } catch (_) {
      // 取不到版本就不重置；保留上次計數較安全
    }
  }

  /// "1.5.0+2026050201" → "1.5"
  String _toMinorKey(String version) {
    final core = version.split('+').first; // 去掉 build 編號
    final parts = core.split('.');
    if (parts.length < 2) return core;
    return '${parts[0]}.${parts[1]}';
  }

  bool get _isSubscribed {
    if (!Get.isRegistered<SubscriptionService>()) return false;
    return Get.find<SubscriptionService>().isSubscribed.value;
  }

  bool get _isSilenced {
    final count = _storage.read<int>(_kDismissCount) ?? 0;
    return count >= _maxDismissals;
  }

  bool get _shownToday {
    final today = _todayKey();
    return _storage.read<String>(_kLastShownDate) == today;
  }

  String _todayKey() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  /// 主入口：app 啟動 / home 第一次渲染後呼叫。
  /// 條件：未訂閱、未靜音、今天還沒顯示過 → 顯示 launch prompt。
  Future<bool> shouldShowLaunchPrompt() async {
    await _ready;
    if (_isSubscribed) return false;
    if (_isSilenced) return false;
    if (_shownToday) return false;
    return true;
  }

  /// 主入口：插頁廣告關閉時呼叫。
  /// 條件：未訂閱、未靜音、累計關閉次數 % 3 == 0 → 顯示 reading prompt。
  Future<bool> onInterstitialDismissed() async {
    await _ready;
    if (_isSubscribed) return false;
    if (_isSilenced) return false;
    final next = ((_storage.read<int>(_kAdClosedCount) ?? 0) + 1);
    _storage.write(_kAdClosedCount, next);
    return next % _adClosedThreshold == 0;
  }

  /// 顯示 prompt 後呼叫，避免今天再顯示 launch prompt。
  void markShownToday() {
    _storage.write(_kLastShownDate, _todayKey());
  }

  /// 使用者關閉 prompt 時呼叫。
  void recordDismissal() {
    final next = (_storage.read<int>(_kDismissCount) ?? 0) + 1;
    _storage.write(_kDismissCount, next);
  }

  /// 使用者點「查看方案」進訂閱頁時，本次不視為「被打擾」，不計入靜音。
  /// 但仍 mark 今日已顯示。
  void recordOpenedSubscriptionPage() {
    // 不增加 dismiss count
  }
}
