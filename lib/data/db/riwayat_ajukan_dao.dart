// lib/data/db/riwayat_pengajuan_dao.dart
import 'package:pensiunku/model/riwayat_ajukan_model.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RiwayatPengajuanDao {
  static const String _cacheKey = 'riwayat_pengajuan_cache';
  final SharedPreferences _prefs;

  RiwayatPengajuanDao(this._prefs);

  Future<void> cachePengajuanList(List<RiwayatPengajuan> pengajuanList) async {
    print('💾 Menyimpan ${pengajuanList.length} data ke cache');
    final jsonList = pengajuanList.map((p) => p.toJson()).toList();
    await _prefs.setString(_cacheKey, json.encode(jsonList));
  }

  Future<List<RiwayatPengajuan>> getCachedPengajuanList() async {
    print('🔍 Mengambil data dari cache');
    final jsonString = _prefs.getString(_cacheKey);
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((json) => RiwayatPengajuan.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> clearCache() async {
    print('🧹 Membersihkan cache');
    await _prefs.remove(_cacheKey);
  }
}
