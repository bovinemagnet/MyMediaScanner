import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'master_detail_split_ratio';
const _defaultRatio = 0.45;

class SplitRatioNotifier extends Notifier<double> {
  @override
  double build() {
    _loadFromPrefs();
    return _defaultRatio;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_prefKey);
    if (stored != null && ref.mounted) {
      state = stored;
    }
  }

  void setRatio(double ratio) {
    state = ratio;
    _persistToPrefs();
  }

  Future<void> _persistToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefKey, state);
  }
}

final splitRatioProvider =
    NotifierProvider<SplitRatioNotifier, double>(
        () => SplitRatioNotifier());
