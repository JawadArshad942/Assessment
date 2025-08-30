import 'package:hive_flutter/hive_flutter.dart';

class CartLocalDataSource {
  static const String _boxName = 'cartBox';
  static const String _quantitiesKey = 'cart_quantities';
  static const String _countKey = 'cart_count';

  Future<Map<int, int>> readQuantities() async {
    final Box<dynamic> box = Hive.box<dynamic>(_boxName);
    final Map<dynamic, dynamic>? raw = box.get(_quantitiesKey) as Map<dynamic, dynamic>?;
    if (raw == null) return <int, int>{};
    return raw.map<int, int>((dynamic k, dynamic v) => MapEntry<int, int>(k as int, v as int));
  }

  Future<int> readCount() async {
    final Box<dynamic> box = Hive.box<dynamic>(_boxName);
    return (box.get(_countKey) as int?) ?? 0;
  }

  Future<void> write(Map<int, int> quantities) async {
    final Box<dynamic> box = Hive.box<dynamic>(_boxName);
    await box.put(_quantitiesKey, quantities);
    await box.put(_countKey, quantities.length);
  }
}
