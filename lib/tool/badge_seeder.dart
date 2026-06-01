import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:santarana/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const _BadgeSeederApp());
}

class _BadgeSeederApp extends StatelessWidget {
  const _BadgeSeederApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _BadgeSeederScreen(),
    );
  }
}

class _BadgeSeederScreen extends StatefulWidget {
  const _BadgeSeederScreen();

  @override
  State<_BadgeSeederScreen> createState() => _BadgeSeederScreenState();
}

class _BadgeSeederScreenState extends State<_BadgeSeederScreen> {
  final List<String> _logs = [];
  bool _isRunning = false;
  bool _isDone = false;

  void _log(String msg) {
    setState(() => _logs.add(msg));
    debugPrint(msg);
  }

  Future<void> _runSeeder() async {
    setState(() {
      _isRunning = true;
      _isDone = false;
      _logs.clear();
    });

    try {
      final seeder = BadgeSeeder(onLog: _log);
      await seeder.run();
      setState(() => _isDone = true);
    } catch (e) {
      _log('❌ ERROR: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _deleteAll() async {
    setState(() {
      _isRunning = true;
      _isDone = false;
      _logs.clear();
    });

    try {
      _log('🗑️  Menghapus semua badge...');
      final snap = await FirebaseFirestore.instance
          .collection('medals')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      _log('✅ Semua badge berhasil dihapus (${snap.docs.length} dokumen)');
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
      appBar: AppBar(title: const Text('Badge Seeder')),
      body: Column(
        children: [
          // ── Tombol aksi ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runSeeder,
                    icon: const Icon(Icons.upload),
                    label: Text(
                      _isRunning ? 'Uploading...' : 'Upload Semua Badge',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _deleteAll,
                    icon: const Icon(Icons.delete),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    label: const Text('Hapus Semua Badge'),
                  ),
                ),
              ],
            ),
          ),

          // ── Status ───────────────────────────────────────────
          if (_isDone)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '✅ Selesai! Kamu bisa close app ini.',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // ── Log output ───────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (_, i) => Text(
                _logs[i],
                style: const TextStyle(fontSize: 12),
              ),
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

class BadgeSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final void Function(String) onLog;

  BadgeSeeder({required this.onLog});

  Future<void> run() async {
    // ── Ambil semua categoryId dari Firestore ─────────────────
    onLog('📂 Mengambil daftar kategori...');
    final catSnap = await _db
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .get();

    if (catSnap.docs.isEmpty) {
      onLog('⚠️  Tidak ada kategori aktif di Firestore.');
      return;
    }

    // Buat map nama kategori → id dokumen
    final catMap = <String, String>{};
    for (final doc in catSnap.docs) {
      catMap[doc['name'] as String] = doc.id;
      onLog('   • ${doc.id} → ${doc['name']}');
    }

    // ── Build semua badge ─────────────────────────────────────
    final badges = _buildBadges(catMap);
    onLog('\n📝 Total badge yang akan di-upload: ${badges.length}');

    // ── Upload ke Firestore ───────────────────────────────────
    int uploaded = 0;
    for (final badge in badges) {
      final docId = badge['id'] as String;
      final data = Map<String, dynamic>.from(badge)..remove('id');

      await _db.collection('medals').doc(docId).set(data);
      uploaded++;
      onLog('   ✓ [$uploaded/${badges.length}] $docId → berhasil');
    }

    onLog('\n✅ Seeder selesai! $uploaded badge berhasil diupload.');
  }

  // ============================================================
  // !! TAMBAHKAN BADGE BARU DI SINI !!
  // ============================================================
  //
  // PANDUAN FIELD:
  //   id            → ID unik dokumen di Firestore (gunakan snake_case)
  //   name          → Nama badge yang tampil di UI
  //   description   → Deskripsi singkat kondisi mendapat badge
  //   imagePath     → Path asset Flutter (harus ada di pubspec.yaml)
  //   conditionType → Pilih salah satu:
  //                   'streak'             = 7 hari streak misi
  //                   'first_quiz'         = quiz pertama yang pernah dimainkan
  //                   'category_card1'     = selesaikan card 1 kategori tertentu
  //                   'category_all_cards' = selesaikan semua card kategori tertentu
  //                   'none'               = belum ada kondisi
  //   categoryName  → Nama kategori di Firestore (harus sama persis)
  //                   Isi null jika badge tidak terkait kategori
  //   isActive      → true = aktif, false = belum bisa didapat
  //
  // CONTOH TAMBAH BADGE BARU:
  //   _badge(
  //     id: 'badge_tarian_lvl1',
  //     name: 'Penjelajah Tarian',
  //     description: 'Selesaikan card pertama kategori Tarian Tradisional',
  //     imagePath: 'assets/images/badge_tarian_lvl1.png',
  //     conditionType: 'category_card1',
  //     categoryName: 'Tarian Tradisional',
  //     catMap: catMap,
  //   ),
  // ============================================================

  List<Map<String, dynamic>> _buildBadges(Map<String, String> catMap) {
    return [
      // ── Badge Global ────────────────────────────────────────
      // _badge(
      //   id: 'badge_master',
      //   name: 'Master Streak',
      //   description: 'Selesaikan misi 7 hari berturut-turut',
      //   imagePath: 'assets/images/badge_master.png',
      //   conditionType: 'streak',
      //   categoryName: null,
      //   catMap: catMap,
      //   isActive: true,
      // ),

      // ── Badge Makanan Nusantara ──────────────────────────────
      _badge(
        id: 'badge_makanan_lvl1',
        name: 'Penjelajah Makanan',
        description: 'Selesaikan card pertama kategori Makanan Nusantara',
        imagePath: 'assets/images/badge_makanan_nusantara_lvl1.png',
        conditionType: 'category_card1',
        categoryName: 'Makanan Nusantara',
        catMap: catMap,
        isActive: true,
      ),
      _badge(
        id: 'badge_makanan_lvl2',
        name: 'Ahli Makanan',
        description: 'Selesaikan semua card kategori Makanan Nusantara',
        imagePath: 'assets/images/badge_makanan_nusantara_lvl2.png',
        conditionType: 'category_all_cards',
        categoryName: 'Makanan Nusantara',
        catMap: catMap,
        isActive: true,
      ),
      _badge(
        id: 'badge_makanan_lvl3',
        name: 'Legenda Makanan',
        description: 'Medali spesial kategori Makanan Nusantara',
        imagePath: 'assets/images/badge_makanan_nusantara_lvl3.png',
        conditionType: 'none',
        categoryName: 'Makanan Nusantara',
        catMap: catMap,
        isActive: false,
      ),

      // ── Badge Pakaian Adat ───────────────────────────────────
      _badge(
        id: 'badge_pakaian_lvl1',
        name: 'Penjelajah Pakaian',
        description: 'Selesaikan card pertama kategori Pakaian Adat Nusantara',
        imagePath: 'assets/images/badge_pakaian_nusantara_lvl1.png',
        conditionType: 'category_card1',
        categoryName: 'Pakaian Adat Nusantara',
        catMap: catMap,
        isActive: true,
      ),
      _badge(
        id: 'badge_pakaian_lvl2',
        name: 'Ahli Pakaian',
        description: 'Selesaikan semua card kategori Pakaian Adat Nusantara',
        imagePath: 'assets/images/badge_pakaian_nusantara_lvl2.png',
        conditionType: 'category_all_cards',
        categoryName: 'Pakaian Adat Nusantara',
        catMap: catMap,
        isActive: true,
      ),
      _badge(
        id: 'badge_pakaian_lvl3',
        name: 'Legenda Pakaian',
        description: 'Medali spesial kategori Pakaian Adat Nusantara',
        imagePath: 'assets/images/badge_pakaian_nusantara_lvl3.png',
        conditionType: 'none',
        categoryName: 'Pakaian Adat Nusantara',
        catMap: catMap,
        isActive: false,
      ),

      // ── Tambahkan badge baru di bawah sini ──────────────────
      // contoh:
      // _badge(
      //   id: 'badge_tarian_lvl1',
      //   name: 'Penjelajah Tarian',
      //   description: 'Selesaikan card pertama kategori Tarian Tradisional',
      //   imagePath: 'assets/images/badge_tarian_lvl1.png',
      //   conditionType: 'category_card1',
      //   categoryName: 'Tarian Tradisional',
      //   catMap: catMap,
      //   isActive: true,
      // ),
    ];
  }

  // ── Helper builder ────────────────────────────────────────────
  Map<String, dynamic> _badge({
    required String id,
    required String name,
    required String description,
    required String imagePath,
    required String conditionType,
    required String? categoryName,
    required Map<String, String> catMap,
    required bool isActive,
  }) {
    // Validasi asset path
    if (!imagePath.startsWith('assets/')) {
      onLog('⚠️  WARNING: imagePath "$imagePath" tidak dimulai dengan assets/');
    }

    // Resolve categoryId dari nama kategori
    String? categoryId;
    if (categoryName != null) {
      categoryId = catMap[categoryName];
      if (categoryId == null) {
        onLog(
          '⚠️  WARNING: kategori "$categoryName" tidak ditemukan di Firestore',
        );
      }
    }

    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'conditionType': conditionType,
      'categoryId': categoryId,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}