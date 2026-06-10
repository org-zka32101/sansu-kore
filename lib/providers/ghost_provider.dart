import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _ghostPrefKey = 'ghost_records_v1';

/// ゴーストバトル用レコード：1ステージの問題ごと回答時間
class GhostRecord {
  /// grade * 100 + stageNumber
  final int stageId;

  /// 各問への回答時間（ms）
  final List<int> questionMs;

  final DateTime playedAt;

  const GhostRecord({
    required this.stageId,
    required this.questionMs,
    required this.playedAt,
  });

  int get totalMs => questionMs.fold(0, (s, v) => s + v);

  String get totalTimeStr {
    final sec = (totalMs / 1000).toStringAsFixed(1);
    return '${sec}秒';
  }

  Map<String, dynamic> toJson() => {
        'stageId': stageId,
        'questionMs': questionMs,
        'playedAt': playedAt.toIso8601String(),
      };

  factory GhostRecord.fromJson(Map<String, dynamic> json) => GhostRecord(
        stageId: json['stageId'] as int,
        questionMs: List<int>.from(json['questionMs'] as List),
        playedAt: DateTime.parse(json['playedAt'] as String),
      );

  /// 指定経過時間(ms)でゴーストが何問目まで終わっているかを返す（0〜questionMs.length）
  int completedQuestionsAt(int elapsedMs) {
    int cum = 0;
    int completed = 0;
    for (final t in questionMs) {
      cum += t;
      if (cum <= elapsedMs) {
        completed++;
      } else {
        break;
      }
    }
    return completed;
  }

  /// 進捗 0.0〜1.0
  double progressAt(int elapsedMs) {
    if (questionMs.isEmpty) return 0;
    return completedQuestionsAt(elapsedMs) / questionMs.length;
  }
}

class GhostState {
  /// stageId → 最速レコード
  final Map<int, GhostRecord> records;
  const GhostState({this.records = const {}});

  GhostState copyWith({Map<int, GhostRecord>? records}) =>
      GhostState(records: records ?? this.records);
}

class GhostNotifier extends Notifier<GhostState> {
  @override
  GhostState build() {
    _load();
    return const GhostState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ghostPrefKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final records = <int, GhostRecord>{};
      map.forEach((k, v) {
        final id = int.tryParse(k);
        if (id != null) {
          records[id] = GhostRecord.fromJson(v as Map<String, dynamic>);
        }
      });
      state = state.copyWith(records: records);
    } catch (_) {}
  }

  /// 新しいレコードを保存（最速のみ保持）
  /// 保存後、旧レコードと比較して更新した場合は true を返す
  Future<bool> saveRecord(GhostRecord record) async {
    final existing = state.records[record.stageId];
    final isNewRecord = existing == null || record.totalMs < existing.totalMs;

    final newMap = Map<int, GhostRecord>.from(state.records);
    if (isNewRecord) {
      newMap[record.stageId] = record;
      state = state.copyWith(records: newMap);
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        newMap.map((k, v) => MapEntry(k.toString(), v.toJson())),
      );
      await prefs.setString(_ghostPrefKey, encoded);
    }
    return isNewRecord;
  }

  GhostRecord? getRecord(int stageId) => state.records[stageId];
}

final ghostProvider = NotifierProvider<GhostNotifier, GhostState>(GhostNotifier.new);
