import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:santarana/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const _SeederApp());
}

class _SeederApp extends StatelessWidget {
  const _SeederApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _SeederScreen(),
    );
  }
}

class _SeederScreen extends StatefulWidget {
  const _SeederScreen();

  @override
  State<_SeederScreen> createState() => _SeederScreenState();
}

class _SeederScreenState extends State<_SeederScreen> {
  final List<String> _logs = [];
  bool _isRunning = false;
  bool _isDone = false;

  void _log(String msg) {
    setState(() => _logs.add(msg));
    debugPrint(msg);
  }

  Future<void> _runMigrate() async {
    setState(() {
      _isRunning = true;
      _isDone = false;
      _logs.clear();
    });
    try {
      final seeder = WeeklyMissionSeeder(onLog: _log);
      await seeder.migrate();
      setState(() => _isDone = true);
    } catch (e) {
      _log('❌ ERROR: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _runDeleteOld() async {
    setState(() {
      _isRunning = true;
      _isDone = false;
      _logs.clear();
    });
    try {
      final seeder = WeeklyMissionSeeder(onLog: _log);
      await seeder.deleteOldCollections();
      setState(() => _isDone = true);
    } catch (e) {
      _log('❌ ERROR: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Mission Seeder')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Tombol migrate ──────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runMigrate,
                    icon: const Icon(Icons.upload),
                    label: Text(
                      _isRunning
                          ? 'Processing...'
                          : '1. Migrate Template ke weekly_mission_templates',
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Tombol delete old ───────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runDeleteOld,
                    icon: const Icon(Icons.delete),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    label: const Text('2. Hapus Collection Lama'),
                  ),
                ),
              ],
            ),
          ),

          if (_isDone)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '✅ Selesai!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (_, i) =>
                  Text(_logs[i], style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CORE SEEDER
// ============================================================
class WeeklyMissionSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final void Function(String) onLog;

  WeeklyMissionSeeder({required this.onLog});

  // ── Migrate dari daily_mission_templates → weekly_mission_templates ──
  Future<void> migrate() async {
    onLog('📂 Mengambil data dari daily_mission_templates...');

    final snap = await _db
        .collection('daily_mission_templates')
        .where('is_active', isEqualTo: true)
        .orderBy('mission_number')
        .get();

    if (snap.docs.isEmpty) {
      onLog('⚠️  Tidak ada template aktif ditemukan');
      return;
    }

    onLog('✓ Ditemukan ${snap.docs.length} template');

    // Buat dokumen set_1
    final setRef = _db.collection('weekly_mission_templates').doc('set_1');

    await setRef.set({
      'name': 'Set Minggu 1',
      'createdAt': FieldValue.serverTimestamp(),
    });

    onLog('✓ Dokumen set_1 dibuat');

    // Migrate tiap template sebagai subcollection missions
    int day = 1;
    for (final doc in snap.docs) {
      final data = doc.data();
      final dayRef = setRef.collection('missions').doc('day_$day');

      await dayRef.set({
        'day': day,
        'title': data['title'] ?? '',
        'description': data['description'] ?? '',
        'difficulty': data['difficulty'] ?? 'Mudah',
        'reward_points': data['reward_points'] ?? 10,
        'is_special': data['is_special'] ?? false,
        'image_path': data['image_path'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      onLog('   ✓ day_$day → ${data['title']}');
      day++;
    }

    onLog(
      '\n✅ Migrate selesai! ${snap.docs.length} misi berhasil dipindahkan ke weekly_mission_templates/set_1/missions',
    );
  }

  // ── Hapus collection lama ─────────────────────────────────────
  Future<void> deleteOldCollections() async {
    // 1. Hapus daily_mission_templates
    await _deleteCollection('daily_mission_templates');

    // 2. Hapus daily_missions
    await _deleteCollection('daily_missions');

    // 3. Hapus user_mission_completions
    await _deleteCollection('user_mission_completions');

    onLog('\n✅ Semua collection lama berhasil dihapus');
  }

  Future<void> _deleteCollection(String collectionName) async {
    onLog('🗑️  Menghapus $collectionName...');
    int total = 0;

    while (true) {
      final snap = await _db.collection(collectionName).limit(500).get();

      if (snap.docs.isEmpty) break;

      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      total += snap.docs.length;
      onLog('   ✓ $total dokumen dihapus dari $collectionName');
    }

    onLog('   ✅ $collectionName selesai dihapus ($total dokumen)');
  }
}
