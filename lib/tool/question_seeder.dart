/// ============================================================
/// SEEDER SOAL — SantaraNa Quiz
/// ============================================================
/// Cara pakai:
///   1. Pastikan sudah ada file google-services.json di android/app/
///   2. Isi soal di bagian _buildQuestions() sesuai template
///   3. Jalankan: flutter run -t lib/seeder/question_seeder.dart
///   4. Tunggu hingga muncul "✅ Seeder selesai!"
///   5. Hapus/comment file ini setelah selesai
/// ============================================================

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const _SeederScreen(),
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

  Future<void> _runSeeder() async {
    setState(() {
      _isRunning = true;
      _logs.clear();
    });

    try {
      final seeder = QuestionSeeder(onLog: _log);
      await seeder.run();
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
      appBar: AppBar(title: const Text('Question Seeder')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isRunning ? null : _runSeeder,
              child: Text(_isRunning ? 'Sedang upload...' : 'Mulai Seeder'),
            ),
          ),
          if (_isDone)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '✅ Seeder selesai! Kamu bisa close app ini.',
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

class QuestionSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final void Function(String) onLog;

  QuestionSeeder({required this.onLog});

  Future<void> run() async {
    // ── Ambil semua kategori dari Firestore ────────────────────
    onLog('📂 Mengambil daftar kategori...');
    final catSnap = await _db
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .get();

    if (catSnap.docs.isEmpty) {
      onLog('⚠️  Tidak ada kategori aktif. Buat kategori dulu di Firestore.');
      return;
    }

    onLog('📋 Kategori ditemukan: ${catSnap.docs.length}');
    for (final doc in catSnap.docs) {
      onLog('   • ${doc.id} → ${doc['name']}');
    }

    // ── Build semua soal ───────────────────────────────────────
    final allQuestions = _buildQuestions(catSnap.docs);
    onLog('\n📝 Total soal yang akan di-upload: ${allQuestions.length}');

    // ── Upload ke Firestore (batch per 500) ────────────────────
    int uploaded = 0;
    int batchCount = 0;

    while (uploaded < allQuestions.length) {
      final batch = _db.batch();
      final chunk = allQuestions.skip(uploaded).take(500).toList();

      for (final q in chunk) {
        final ref = _db.collection('questions').doc();
        batch.set(ref, q);
      }

      batchCount++;
      onLog('⬆️  Batch $batchCount: upload ${chunk.length} soal...');
      await batch.commit();
      uploaded += chunk.length;
      onLog('   ✓ ${uploaded}/${allQuestions.length} soal terupload');
    }

    onLog('\n✅ Seeder selesai! $uploaded soal berhasil diupload.');
  }

  // ============================================================
  // !! GANTI ISI _buildQuestions() DENGAN SOAL KAMU !!
  // ============================================================
  //
  // PANDUAN FIELD:
  //   categoryId   → ID dokumen kategori di Firestore (cek di console)
  //   categoryName → Nama kategori (harus sama dengan di Firestore)
  //   cardNumber   → Nomor card (1-10)
  //   difficulty   → 'Mudah' (card 1-5) / 'Sedang' (card 6-8) / 'Sulit' (card 9-10)
  //   question     → Teks pertanyaan
  //   options      → 4 pilihan jawaban [A, B, C, D]
  //   correctIndex → Index jawaban benar (0=A, 1=B, 2=C, 3=D)
  //   isActive     → true
  //   imageUrl     → null (atau path aset jika ada gambar)
  //
  // JUMLAH SOAL PER CARD:
  //   Card 01-05 (Mudah)  → masing-masing 10 soal
  //   Card 06-08 (Sedang) → masing-masing 15 soal
  //   Card 09-10 (Sulit)  → masing-masing 20 soal
  //
  // CONTOH STRUKTUR (ganti dengan soal asli):
  // ============================================================

  List<Map<String, dynamic>> _buildQuestions(
    List<QueryDocumentSnapshot> categories,
  ) {
    // ── Buat map nama → id untuk kemudahan referensi ───────────
    final catMap = <String, String>{};
    for (final doc in categories) {
      catMap[doc['name'] as String] = doc.id;
    }

    final questions = <Map<String, dynamic>>[];

    // ──────────────────────────────────────────────────────────
    // KATEGORI: TARIAN TRADISIONAL (contoh)
    // Ganti 'Tarian Tradisional' dengan nama kategori kamu
    // ──────────────────────────────────────────────────────────
    final tarianId = catMap['Tarian Tradisional'] ?? '';

    if (tarianId.isNotEmpty) {
      // ── CARD 01 — Mudah — 10 soal ────────────────────────────
      questions.addAll(_card(
        categoryId: tarianId,
        categoryName: 'Tarian Tradisional',
        cardNumber: 1,
        difficulty: 'Mudah',
        soal: [
          _soal(
            q: 'Tari Saman berasal dari provinsi mana?',
            opts: ['Sumatera Barat', 'Aceh', 'Sumatera Utara', 'Riau'],
            correct: 1, // B = Aceh
          ),
          _soal(
            q: 'Tari Kecak merupakan tarian tradisional dari daerah?',
            opts: ['Lombok', 'Bali', 'Jawa Timur', 'NTT'],
            correct: 1, // B = Bali
          ),
          _soal(
            q: 'Tari Pendet adalah tarian penyambutan dari?',
            opts: ['Bali', 'Jawa', 'Sulawesi', 'Kalimantan'],
            correct: 0, // A = Bali
          ),
          _soal(
            q: 'Tari Jaipong berasal dari daerah?',
            opts: ['Jawa Tengah', 'Jawa Timur', 'Jawa Barat', 'Yogyakarta'],
            correct: 2, // C = Jawa Barat
          ),
          _soal(
            q: 'Tari Tor-Tor merupakan tarian dari suku?',
            opts: ['Batak', 'Minang', 'Dayak', 'Bugis'],
            correct: 0, // A = Batak
          ),
          // ── GANTI 5 SOAL DI BAWAH INI ──────────────────────
          _soalTemplate(cardNumber: 1, soalKe: 6),
          _soalTemplate(cardNumber: 1, soalKe: 7),
          _soalTemplate(cardNumber: 1, soalKe: 8),
          _soalTemplate(cardNumber: 1, soalKe: 9),
          _soalTemplate(cardNumber: 1, soalKe: 10),
        ],
      ));

      // ── CARD 02 — Mudah — 10 soal ────────────────────────────
      questions.addAll(_card(
        categoryId: tarianId,
        categoryName: 'Tarian Tradisional',
        cardNumber: 2,
        difficulty: 'Mudah',
        soal: [
          // ── GANTI SEMUA SOAL INI ────────────────────────────
          _soalTemplate(cardNumber: 2, soalKe: 1),
          _soalTemplate(cardNumber: 2, soalKe: 2),
          _soalTemplate(cardNumber: 2, soalKe: 3),
          _soalTemplate(cardNumber: 2, soalKe: 4),
          _soalTemplate(cardNumber: 2, soalKe: 5),
          _soalTemplate(cardNumber: 2, soalKe: 6),
          _soalTemplate(cardNumber: 2, soalKe: 7),
          _soalTemplate(cardNumber: 2, soalKe: 8),
          _soalTemplate(cardNumber: 2, soalKe: 9),
          _soalTemplate(cardNumber: 2, soalKe: 10),
        ],
      ));

      // ── CARD 03 — Mudah — 10 soal ────────────────────────────
      questions.addAll(_card(
        categoryId: tarianId,
        categoryName: 'Tarian Tradisional',
        cardNumber: 3,
        difficulty: 'Mudah',
        soal: List.generate(
          10,
          (i) => _soalTemplate(cardNumber: 3, soalKe: i + 1),
        ),
      ));

      // ── CARD 04 — Mudah — 10 soal ────────────────────────────
      questions.addAll(_card(
        categoryId: tarianId,
        categoryName: 'Tarian Tradisional',
        cardNumber: 4,
        difficulty: 'Mudah',
        soal: List.generate(
          10,
          (i) => _soalTemplate(cardNumber: 4, soalKe: i + 1),
        ),
      ));

      // ── CARD 05 — Mudah — 10 soal ────────────────────────────
      questions.addAll(_card(
        categoryId: tarianId,
        categoryName: 'Tarian Tradisional',
        cardNumber: 5,
        difficulty: 'Mudah',
        soal: List.generate(
          10,
          (i) => _soalTemplate(cardNumber: 5, soalKe: i + 1),
        ),
      ));

      // ── CARD 06 — Sedang — 15 soal ───────────────────────────
      questions.addAll(_card(
        categoryId: tarianId,
        categoryName: 'Tarian Tradisional',
        cardNumber: 6,
        difficulty: 'Sedang',
        soal: List.generate(
          15,
          (i) => _soalTemplate(cardNumber: 6, soalKe: i + 1),
        ),
      ));

      // ── CARD 07 — Sedang — 15 soal ───────────────────────────
      questions.addAll(_card(
        categoryId: tarianId,
        categoryName: 'Tarian Tradisional',
        cardNumber: 7,
        difficulty: 'Sedang',
        soal: List.generate(
          15,
          (i) => _soalTemplate(cardNumber: 7, soalKe: i + 1),
        ),
      ));

      // ── CARD 08 — Sedang — 15 soal ───────────────────────────
      questions.addAll(_card(
        categoryId: tarianId,
        categoryName: 'Tarian Tradisional',
        cardNumber: 8,
        difficulty: 'Sedang',
        soal: List.generate(
          15,
          (i) => _soalTemplate(cardNumber: 8, soalKe: i + 1),
        ),
      ));

      // ── CARD 09 — Sulit — 20 soal ────────────────────────────
      questions.addAll(_card(
        categoryId: tarianId,
        categoryName: 'Tarian Tradisional',
        cardNumber: 9,
        difficulty: 'Sulit',
        soal: List.generate(
          20,
          (i) => _soalTemplate(cardNumber: 9, soalKe: i + 1),
        ),
      ));

      // ── CARD 10 — Sulit — 20 soal ────────────────────────────
      questions.addAll(_card(
        categoryId: tarianId,
        categoryName: 'Tarian Tradisional',
        cardNumber: 10,
        difficulty: 'Sulit',
        soal: List.generate(
          20,
          (i) => _soalTemplate(cardNumber: 10, soalKe: i + 1),
        ),
      ));
    }

    // ──────────────────────────────────────────────────────────
    // DUPLIKAT BLOK DI ATAS UNTUK KATEGORI LAIN
    // Contoh: 'Pakaian Adat', 'Makanan Tradisional', dst.
    // ──────────────────────────────────────────────────────────
    //
    // final pakaianId = catMap['Pakaian Adat'] ?? '';
    // if (pakaianId.isNotEmpty) {
    //   questions.addAll(_card(
    //     categoryId: pakaianId,
    //     categoryName: 'Pakaian Adat',
    //     cardNumber: 1,
    //     difficulty: 'Mudah',
    //     soal: [ ... ],
    //   ));
    //   ...dst
    // }

    return questions;
  }

  // ============================================================
  // HELPER — jangan diubah
  // ============================================================

  /// Bungkus list soal menjadi list Map dengan field lengkap
  List<Map<String, dynamic>> _card({
    required String categoryId,
    required String categoryName,
    required int cardNumber,
    required String difficulty,
    required List<Map<String, dynamic>> soal,
  }) {
    return soal.map((s) => {
      ...s,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'cardNumber': cardNumber,
      'difficulty': difficulty,
      'isActive': true,
      'imageUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'stats': {'timesAnswered': 0, 'timesWrong': 0, 'wrongRate': 0.0},
    }).toList();
  }

  /// Helper buat satu soal
  Map<String, dynamic> _soal({
    required String q,
    required List<String> opts,
    required int correct,
    String? imageUrl,
  }) {
    assert(opts.length == 4, 'Harus tepat 4 pilihan jawaban');
    assert(correct >= 0 && correct <= 3, 'correctIndex harus 0-3');
    return {
      'question': q,
      'options': opts,
      'correctIndex': correct,
      'imageUrl': imageUrl,
    };
  }

  /// Placeholder soal — GANTI dengan soal asli
  Map<String, dynamic> _soalTemplate({
    required int cardNumber,
    required int soalKe,
  }) {
    return _soal(
      q: '[CARD $cardNumber - SOAL $soalKe] Ganti dengan pertanyaan asli',
      opts: [
        'Jawaban A (ganti)',
        'Jawaban B (ganti)',
        'Jawaban C (ganti)',
        'Jawaban D (ganti)',
      ],
      correct: 0,
    );
  }
}
