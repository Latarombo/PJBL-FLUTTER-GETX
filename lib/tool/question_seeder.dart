/// ============================================================
/// SEEDER SOAL — SantaraNa Quiz
/// ============================================================
/// Cara pakai:
///   1. Pastikan sudah ada file google-services.json di android/app/
///   2. Isi soal di bagian _buildQuestions() sesuai template
///   3. Jalankan: flutter run -t lib/tool/question_seeder.dart
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

class QuestionSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final void Function(String) onLog;

  QuestionSeeder({required this.onLog});

  Future<void> run() async {
    // ── Ambil semua kategori dari Firestore ────────────────────
    await _deleteAllQuestions();
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

  // Tambahkan method ini di dalam class QuestionSeeder
  Future<void> _deleteAllQuestions() async {
    onLog('🗑️  Menghapus semua soal lama...');

    int totalDeleted = 0;
    int batchCount = 0;

    while (true) {
      // Firestore batch delete maksimal 500 per batch
      final snapshot = await _db.collection('questions').limit(500).get();

      if (snapshot.docs.isEmpty) break;

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      batchCount++;
      onLog(
        '🗑️  Batch delete $batchCount: ${snapshot.docs.length} dokumen...',
      );
      await batch.commit();
      totalDeleted += snapshot.docs.length;
      onLog('   ✓ Total terhapus: $totalDeleted dokumen');
    }

    onLog('✅ Semua soal lama berhasil dihapus ($totalDeleted dokumen).\n');
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
    final catMap = <String, String>{};
    for (final doc in categories) {
      catMap[doc['name'] as String] = doc.id;
    }

    final questions = <Map<String, dynamic>>[];

    final makananId = catMap['Makanan Nusantara'] ?? '';
    if (makananId.isNotEmpty) {
      questions.addAll(
        _card(
          categoryId: makananId,
          categoryName: 'Makanan Nusantara',
          cardNumber: 1,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Makanan khas dari Sumatra Barat yang berbahan dasar daging sapi dan kaya rempah ini adalah...',
              opts: ['Gudeg', 'Rawon', 'Rendang', 'Coto Makassar'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_01.png',
            ),
            _soal(
              q: 'Kuliner khas Palembang yang disajikan dengan kuah cuka asam pedas (cuko) adalah...',
              opts: ['Batagor', 'Pempek', 'Siomay', 'Bakso'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_02.png',
            ),
            _soal(
              q: 'Makanan khas Yogyakarta berwarna cokelat manis yang terbuat dari nangka muda adalah...',
              opts: ['Sayur Asem', 'Lodeh', 'Opor', 'Gudeg'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_03.png',
            ),
            _soal(
              q: 'Sajian potongan daging yang ditusuk, dibakar, dan disiram bumbu kacang khas Jawa Timur ini bernama...',
              opts: [
                'Sate Lilit',
                'Sate Padang',
                'Sate Madura',
                'Sate Maranggi',
              ],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_04.jpg',
            ),
            _soal(
              q: 'Sup daging dengan kuah hitam pekat khas Jawa Timur yang menggunakan kluwek adalah...',
              opts: ['Rawon', 'Soto Lamongan', 'Sop Konro', 'Bakso Malang'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_05.jpg',
            ),
            _soal(
              q: 'Apa nama bahan utama pembuat cita rasa hitam pada kuah Rawon?',
              opts: ['Kunyit', 'Jinten', 'Kluwek (Keluwak)', 'Ketumbar'],
              correct: 2,
            ),
            _soal(
              q: 'Dari daerah manakah kuliner sate yang bumbunya menggunakan kuah kuning kental berempah pedas?',
              opts: ['Madura', 'Betawi', 'Ponorogo', 'Padang'],
              correct: 3,
            ),
            _soal(
              q: 'Sambal khas Bali yang dibuat dari irisan bawang merah, cabai rawit, serai, dan disiram minyak panas dinamakan...',
              opts: [
                'Sambal Terasi',
                'Sambal Ijo',
                'Sambal Matah',
                'Sambal Bajak',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Soto khas Jakarta yang kuahnya menggunakan campuran santan dan susu adalah...',
              opts: [
                'Soto Lamongan',
                'Soto Kudus',
                'Soto Banjar',
                'Soto Betawi',
              ],
              correct: 3,
            ),
            _soal(
              q: 'Kudapan berupa tahu goreng yang diisi sayuran lalu dibalut tepung renyah disebut...',
              opts: [
                'Tahu Isi / Gehu',
                'Tahu Bakso',
                'Tahu Petis',
                'Tahu Gejrot',
              ],
              correct: 0,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: makananId,
          categoryName: 'Makanan Nusantara',
          cardNumber: 2,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Makanan sejuta umat berbahan dasar nasi yang diaduk dengan kecap manis dan bumbu ini adalah...',
              opts: ['Nasi Uduk', 'Nasi Liwet', 'Nasi Kuning', 'Nasi Goreng'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_06.jpg',
            ),
            _soal(
              q: 'Kuliner berbentuk bola daging yang disajikan dengan kuah kaldu hangat, mi, dan tahu adalah...',
              opts: ['Bakso', 'Cilok', 'Batagor', 'Pempek'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_07.jpg',
            ),
            _soal(
              q: '"Salad" khas Indonesia yang berisi sayuran rebus dan disiram saus kacang ini adalah...',
              opts: ['Karedok', 'Gado-Gado', 'Pecel', 'Lotek'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_08.jpg',
            ),
            _soal(
              q: 'Sate khas Bali yang dagingnya dicincang, dicampur kelapa parut, lalu dililitkan pada batang serai adalah...',
              opts: [
                'Sate Lilit',
                'Sate Madura',
                'Sate Padang',
                'Sate Maranggi',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_09.jpg',
            ),
            _soal(
              q: 'Jenis pempek Palembang yang ukurannya besar dan berisi telur utuh di dalamnya adalah...',
              opts: [
                'Pempek Lenjer',
                'Pempek Adaan',
                'Pempek Kulit',
                'Pempek Kapal Selam',
              ],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_10.',
            ),
            _soal(
              q: 'Makanan khas Jawa Barat yang singkatannya berasal dari "Aci Dicolok" adalah...',
              opts: ['Cimol', 'Cireng', 'Cilok', 'Cilung'],
              correct: 2,
            ),
            _soal(
              q: 'Sayuran khas Sunda yang mirip dengan gado-gado namun semua sayurannya disajikan mentah adalah...',
              opts: ['Pecel', 'Karedok', 'Lotek', 'Urap'],
              correct: 1,
            ),
            _soal(
              q: 'Kuliner khas Cirebon yang disajikan di dalam piring tanah liat dengan kuah santan bumbu kuning dan daging sapi adalah...',
              opts: ['Sup Konro', 'Rawon', 'Tongseng', 'Empal Gentong'],
              correct: 3,
            ),
            _soal(
              q: 'Daerah di Indonesia yang sangat terkenal sebagai penghasil utama buah durian dan oleh-oleh Bika Ambon adalah...',
              opts: ['Palembang', 'Padang', 'Medan', 'Lampung'],
              correct: 2,
            ),
            _soal(
              q: 'Makanan ringan khas Bandung yang terbuat dari tepung kanji goreng dan biasanya disiram saus bumbu kacang adalah...',
              opts: ['Cireng', 'Pempek', 'Batagor', 'Bakso tahu'],
              correct: 2,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: makananId,
          categoryName: 'Makanan Nusantara',
          cardNumber: 3,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Makanan khas Betawi yang terbuat dari beras ketan, telur, dan ditaburi serundeng serta ebi adalah...',
              opts: ['Serabi', 'Kerak Telor', 'Kue Cucur', 'Jalangkote'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_11.',
            ),
            _soal(
              q: 'Bubur khas Sulawesi Utara yang dicampur dengan labu kuning, kangkung, bayam, dan jagung adalah...',
              opts: [
                'Bubur Ayam',
                'Bubur Sumsum',
                'Bubur Manado (Tinutuan)',
                'Bubur Kacang Hijau',
              ],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_12.jpg',
            ),
            _soal(
              q: 'Jajanan khas Semarang yang berisi rebung, telur, dan daging ayam/udang yang dibungkus kulit tipis adalah...',
              opts: ['Lumpia', 'Risoles', 'Pastel', 'Martabak'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_13.jpg',
            ),
            _soal(
              q: 'Soto khas Jawa Timur yang terkenal dengan ciri khas taburan bubuk koya di atasnya adalah...',
              opts: [
                'Soto Betawi',
                'Soto Banjar',
                'Soto Kudus',
                'Soto Lamongan',
              ],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_14.jpg',
            ),
            _soal(
              q: 'Nasi yang dimasak dengan santan dan bumbu aromatik, sering disajikan dengan semur jengkol dan bihun khas Jakarta adalah...',
              opts: ['Nasi Kuning', 'Nasi Liwet', 'Nasi Uduk', 'Nasi Kebuli'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_15.jpg',
            ),
            _soal(
              q: 'Apa nama minuman manis khas Jawa Barat yang berisi serutan kelapa, nangka, dan disiram santan serta gula merah?',
              opts: [
                'Es Teler',
                'Es Cendol / Dawet',
                'Es Pisang Ijo',
                'Es Doger',
              ],
              correct: 3,
            ),
            _soal(
              q: 'Nasi kuning sering kali dibentuk mengerucut ke atas untuk acara syukuran. Bentuk nasi ini disebut...',
              opts: ['Nasi Liwet', 'Nasi Uduk', 'Nasi Berkat', 'Nasi Tumpeng'],
              correct: 3,
            ),
            _soal(
              q: 'Kerupuk putih berbentuk mawar melingkar yang sering dijadikan pelengkap wajib saat makan bakso atau soto adalah kerupuk...',
              opts: [
                'Kerupuk Kaleng / Kemplang',
                'Kerupuk Kulit',
                'Kerupuk Udang',
                'Kerupuk Kuku Macan',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Kudapan manis legendaris dari Yogyakarta yang terbuat dari kacang hijau dibalut tepung dan dipanggang adalah...',
              opts: ['Yangko', 'Bakpia', 'Geplak', 'Wingko Babat'],
              correct: 1,
            ),
            _soal(
              q: 'Pempek yang dimasak dengan cara dipanggang atau dibakar, bukan digoreng atau direbus, dinamakan...',
              opts: [
                'Pempek Kapal Selam',
                'Pempek Adaan',
                'Pempek Tunu (Panggang)',
                'Pempek Keriting',
              ],
              correct: 2,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: makananId,
          categoryName: 'Makanan Nusantara',
          cardNumber: 4,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Olahan ayam utuh bumbu pedas khas Bali yang dimasak dengan cara dipanggang atau direbus dalam waktu lama adalah...',
              opts: [
                'Ayam Taliwang',
                'Ayam Goreng Kalasan',
                'Ayam Tangtang',
                'Ayam Betutu',
              ],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_16.jpg',
            ),
            _soal(
              q: 'Makanan pokok khas Papua dan Maluku yang terbuat dari sagu dan bertekstur kenyal seperti lem adalah...',
              opts: ['Papeda', 'Kapurung', 'Tiwul', 'Gatot'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_17.png',
            ),
            _soal(
              q: 'Kue berwarna kuning, berongga-rongga, dan memiliki aroma daun jeruk yang khas dari Medan adalah...',
              opts: ['Kue Lapis', 'Bolu Meranti', 'Bika Ambon', 'Kue Lumpur'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_18.jpg',
            ),
            _soal(
              q: 'Jajanan pasar populer berbentuk bulat tebal yang diberi topping cokelat, keju, atau kacang adalah...',
              opts: [
                'Serabi',
                'Martabak Manis/Terang Bulan',
                'Pancake',
                'Kue Pukis',
              ],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_19.jpg',
            ),
            _soal(
              q: 'Hidangan mi tebal pedas khas ujung barat Indonesia yang dimasak dengan bumbu kari kental adalah...',
              opts: ['Mie Celor', 'Mie Bangka', 'Mie Aceh', 'Mie Ongklok'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_20.jpg',
            ),
            _soal(
              q: 'Hidangan berkuah dari Solo yang mirip selat (bistik) dengan kuah manis encer, potongan daging sapi, telur, dan sayuran disebut...',
              opts: ['Timlo Solo', 'Tengkleng', 'Gudeg', 'Selat Solo'],
              correct: 3,
            ),
            _soal(
              q: 'Makanan khas Banjarmasin yang menggunakan soun, perkedel kentang, dan telur bebek dalam sajian sotonya adalah...',
              opts: [
                'Soto Kudus',
                'Soto Banjar',
                'Soto Makassar',
                'Soto Betawi',
              ],
              correct: 1,
            ),
            _soal(
              q: 'Kuliner khas Lombok yang terkenal dengan rasa ayam bakar super pedas berbumbu cabai dan terasi adalah...',
              opts: [
                'Ayam Taliwang',
                'Ayam Betutu',
                'Ayam Tangtang',
                'Ayam Geprek',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Jajanan pasar berbentuk bulat, berwarna hijau dari daun suji, berisi gula merah cair, dan dibalut kelapa parut adalah...',
              opts: ['Onde-onde', 'Kue Putu', 'Lupis', 'Klepon'],
              correct: 3,
            ),
            _soal(
              q: 'Bahan dasar utama dalam pembuatan jajanan tradisional "Getuk" khas Jawa Tengah adalah...',
              opts: ['Singkong', 'Pisang', 'Ketan', 'Ubi Jalar'],
              correct: 0,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: makananId,
          categoryName: 'Makanan Nusantara',
          cardNumber: 5,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Jajanan pasar dari tepung beras dan santan yang dimasak di wajan tanah liat kecil, terkenal tipis dan renyah di pinggirnya adalah...',
              opts: ['Kue Cucur', 'Kue Ape', 'Serabi Solo', 'Kue Lekker'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_21.jpg',
            ),
            _soal(
              q: 'Hidangan berkuah santan putih/kuning berisi ayam yang sangat identik dengan perayaan Hari Raya Idulfitri adalah...',
              opts: ['Gulai Ayam', 'Soto Ayam', 'Kare Ayam', 'Opor Ayam'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_22.jpg',
            ),
            _soal(
              q: 'Kudapan segar khas Makassar berupa pisang yang dibalut adonan hijau, disajikan dengan bubur sumsum dan sirup merah adalah...',
              opts: ['Es Doger', 'Es Teler', 'Es Pallubasa', 'Es Pisang Ijo'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_23.jpg',
            ),
            _soal(
              q: 'Kuliner berkuah kaldu sapi kental dari Sulawesi Selatan yang biasanya dimakan bersama ketupat atau buras adalah...',
              opts: [
                'Sop Konro',
                'Pallubasa',
                'Coto Makassar',
                'Empal Gentong',
              ],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_24.jpg',
            ),
            _soal(
              q: 'Makanan berbahan dasar ikan tenggiri yang dibungkus daun pisang lalu dibakar dan dicocol sambal kacang adalah...',
              opts: ['Otak-Otak', 'Pempek', 'Siomay', 'Sate Lilit'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/makanan_tradisional/makanan_25.jpg',
            ),
            _soal(
              q: 'Sup iga sapi berkuah cokelat kehitaman asal Makassar yang menggunakan rempah ketumbar dan kluwek adalah...',
              opts: [
                'Sop Konro',
                'Coto Makassar',
                'Pallubasa',
                'Rawon Nguling',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Makanan khas Palembang berbahan dasar mi yang disiram kuah kaldu udang kental yang gurih dinamakan...',
              opts: ['Mie Aceh', 'Mie Ongklok', 'Mie Celor', 'Mie Bangka'],
              correct: 2,
            ),
            _soal(
              q: 'Lauk pelengkap nasi tumpeng berupa potongan tempe yang digoreng kering dan dibumbui manis pedas disebut...',
              opts: [
                'Tempe Bacem',
                'Tempe Mendoan',
                'Orek Tempe / Kering Tempe',
                'Tempe Krispi',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Jajanan khas Purwokerto/Banyumas berupa tempe lebar yang digoreng setengah matang dengan tepung berbumbu daun bawang melimpah adalah...',
              opts: [
                'Tempe Mendoan',
                'Tempe Bacem',
                'Tempe Orek',
                'Keripik Tempe',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Sambal khas Manado yang terbuat dari campuran cabai, bawang, jahe, dan jeruk nipis yang sangat cocok untuk pendamping ikan bakar adalah...',
              opts: [
                'Sambal Matah',
                'Sambal Dabu-dabu',
                'Sambal Roa',
                'Sambal Bajak',
              ],
              correct: 1,
            ),
          ],
        ),
      );
    }

    final pakaianId = catMap['Pakaian Adat Nusantara'] ?? '';
    if (pakaianId.isNotEmpty) {
      questions.addAll(
        _card(
          categoryId: pakaianId,
          categoryName: 'Pakaian Adat Nusantara',
          cardNumber: 1,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Pakaian adat Ulos yang didominasi warna hitam, merah, dan putih seperti pada gambar berasal dari provinsi...',
              opts: ['Sumatera Utara', 'Sumatera Barat', 'Riau', 'Aceh'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_01.jpg',
            ),
            _soal(
              q: 'Gambar tersebut menunjukkan pakaian adat Kebaya Encim yang khas dari daerah...',
              opts: ['Jawa Barat', 'DKI Jakarta', 'Banten', 'Jawa Tengah'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_02.webp',
            ),
            _soal(
              q: 'Pakaian adat King Baba untuk pria dan King Bibinge untuk wanita pada gambar di atas merupakan pakaian khas suku Dayak dari pulau...',
              opts: ['Sulawesi', 'Papua', 'Kalimantan', 'Sumatra'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_03.jpg',
            ),
            _soal(
              q: 'Berdasarkan gambar, pakaian adat yang dilengkapi dengan penutup kepala khas berbentuk tanduk kerbau (Tengkuluk) ini bernama...',
              opts: [
                'Baju Kurung',
                'Baju Bodo',
                'Baju Bundo Kanduang',
                'Baju Cele',
              ],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_04.jpg',
            ),
            _soal(
              q: 'Kain jarik motif batik dan kebaya kutubaru yang anggun pada gambar di atas merupakan pakaian adat dari daerah...',
              opts: ['Jawa Tengah', 'Bali', 'DI Yogyakarta', 'Jawa Timur'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_05.jpg',
            ),
            _soal(
              q: 'Pakaian adat tradisional Indonesia yang diakui secara internasional dan sering dipakai oleh wanita pada acara resmi nasional adalah...',
              opts: ['Baju Bodo', 'Kebaya', 'Baju Cele', 'Kain Ulos'],
              correct: 1,
            ),
            _soal(
              q: 'Penutup kepala khas pria dalam pakaian adat masyarakat Jawa yang terbuat dari kain batik disebut...',
              opts: ['Udeng', 'Tanjak', 'Blangkon', 'Siger'],
              correct: 2,
            ),
            _soal(
              q: 'Pakaian tradisional khas dari daerah DKI Jakarta yang sering dikenakan oleh para pria Betawi saat acara santai atau festival budaya dinamakan...',
              opts: ['Baju Sadariah', 'Baju Pangsi', 'Beskap', 'Baju Surjan'],
              correct: 0,
            ),
            _soal(
              q: 'Suku Dayak di Kalimantan memiliki pakaian adat yang sangat khas. Bahan utama pembuat pakaian adat tradisional mereka pada zaman dahulu memanfaatkan...',
              opts: [
                'Kulit kayu dan serat alam',
                'Kain sutra impor',
                'Kulit hewan buas saja',
                'Kain katun modern',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Setiap pakaian adat Nusantara memiliki keunikan. Pakaian adat dari daerah Minangkabau terkenal dengan penutup kepala wanitanya yang menyerupai...',
              opts: [
                'Menara masjid',
                'Tanduk kerbau',
                'Mahkota bunga',
                'Burung garuda',
              ],
              correct: 1,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: pakaianId,
          categoryName: 'Pakaian Adat Nusantara',
          cardNumber: 2,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Gambar berikut menunjukkan pakaian adat tradisional bernama Baju Cele yang dipadukan dengan kain sarung bergaris-garis emas. Pakaian ini berasal dari...',
              opts: ['NTT', 'Maluku', 'NTB', 'Papua'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_06.jpg',
            ),
            _soal(
              q: 'Perhatikan gambar pakaian adat Bali ini. Nama kain ikat pinggang yang dipakai oleh wanita pada gambar tersebut adalah...',
              opts: ['Selendang/Sabed', 'Kamen', 'Udeng', 'Saput'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_07.jpg',
            ),
            _soal(
              q: 'Pakaian adat berbahan kain tenun khas dengan corak geometris yang indah pada gambar berasal dari provinsi Nusa Tenggara Timur (NTT), yaitu...',
              opts: [
                'Pakaian Adat Amarasi',
                'Pakaian Adat Sasak',
                'Pakaian Adat Lambung',
                'Pakaian Adat Karawang',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_08.jpg',
            ),
            _soal(
              q: 'Gambar di atasmemperlihatkan pakaian adat berbahan beludru hitam dengan sulaman benang emas bernama Beskap dan Kebaya Jawa. Daerah asalnya adalah...',
              opts: ['Jawa Barat', 'Jawa Tengah', 'DKI Jakarta', 'Banten'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_09.jpeg',
            ),
            _soal(
              q: 'Pakaian adat dengan ciri rok rumbai yang terbuat dari bahan-bahan alam pada gambar di diatas merupakan pakaian tradisional dari daerah...',
              opts: ['NTT', 'Maluku', 'Sulawesi Utara', 'Papua'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_10.jpeg',
            ),
            _soal(
              q: 'Kain tradisional khas Sumatra Utara yang sering dijadikan komponen utama dalam pakaian adat suku Batak adalah...',
              opts: [
                'Kain Songket',
                'Kain Batik',
                'Kain Sasirangan',
                'Kain Ulos',
              ],
              correct: 3,
            ),
            _soal(
              q: 'Senjata tradisional yang diselipkan di bagian pinggang belakang pada pakaian adat pria Jawa (Beskap) sebagai lambang kesatrian adalah...',
              opts: ['Kujang', 'Mandau', 'Keris', 'Rencong'],
              correct: 2,
            ),
            _soal(
              q: 'Pakaian adat "Baju Bodo" yang berasal dari Sulawesi Selatan umumnya terbuat dari kain yang transparan dan tipis. Pakaian ini menjadi ciri khas dari suku...',
              opts: ['Toraja', 'Bugis', 'Minahasa', 'Dayak'],
              correct: 1,
            ),
            _soal(
              q: 'Pakaian tradisional Pesa\'an yang terdiri dari kaos garis-garis merah-putih dengan celana hitam longgar merupakan ciri khas masyarakat daerah...',
              opts: ['Madura', 'Bali', 'Lombok', 'Banyuwangi'],
              correct: 0,
            ),
            _soal(
              q: 'Siger adalah mahkota megah berwarna emas yang menjadi bagian penting dari pakaian pengantin wanita yang berasal dari provinsi...',
              opts: ['Lampung', 'Sumatra Selatan', 'Jambi', 'Bengkulu'],
              correct: 0,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: pakaianId,
          categoryName: 'Pakaian Adat Nusantara',
          cardNumber: 3,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Sesuai gambar, pakaian adat Ulee Balang yang anggun ini merupakan pakaian tradisional dari daerah...',
              opts: ['Sumatra Barat', 'Aceh', 'Riau', 'Jambi'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_11.jpg',
            ),
            _soal(
              q: 'Pakaian adat Baju Bodo yang berbentuk segi empat dan berlengan pendek seperti pada gambar merupakan pakaian adat tertua dari suku...',
              opts: ['Bugis/Makassar', 'Dayak', 'Minangkabau', 'Sasak'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_12.jpg',
            ),
            _soal(
              q: 'Kain songket tenun tangan berhias benang emas yang mewah pada gambar di atasmerupakan kerajinan tekstil pelengkap pakaian adat dari daerah...',
              opts: [
                'Palembang (Sumatra Selatan)',
                'Banjarmasin (Kalimantan Selatan)',
                'Pontianak (Kalimantan Barat)',
                'Kupang (NTT)',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_13.jpg',
            ),
            _soal(
              q: 'Penutup kepala pria pada gambar pakaian adat Bali di atas dinamakan...',
              opts: ['Blangkon', 'Tanjak', 'Udeng', 'Kopiah'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_14.jpg',
            ),
            _soal(
              q: 'Gambar di atas menampilkan pakaian adat berbahan kain tenun Songket bernama Pakaian Adat Teluk Belanga yang berasal dari kepulauan...',
              opts: ['Bangka Belitung', 'Riau', 'Mentawai', 'Nias'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_15.jpg',
            ),
            _soal(
              q: 'Kain tenun mewah berhiaskan benang emas yang menjadi pelengkap utama pakaian adat masyarakat Palembang dan Melayu adalah...',
              opts: ['Kain Ikat', 'Kain Songket', 'Kain Ulos', 'Kain Tapis'],
              correct: 1,
            ),
            _soal(
              q: 'Pakaian adat "Baju Cele" memiliki motif kotak-kotak kecil dan biasanya dikombinasikan dengan kain sarung. Pakaian ini berasal dari daerah...',
              opts: ['Papua', 'NTT', 'Maluku', 'NTB'],
              correct: 2,
            ),
            _soal(
              q: 'Masyarakat suku Baduy di Provinsi Banten memiliki pakaian adat yang sederhana dengan warna dominan yang mencerminkan filosofi hidup mereka, yaitu warna...',
              opts: [
                'Merah dan Kuning',
                'Hitam dan Putih',
                'Biru dan Hijau',
                'Ungu dan Cokelat',
              ],
              correct: 1,
            ),
            _soal(
              q: 'Kain bawahan tradisional yang digunakan oleh pria dan wanita dalam pakaian adat Bali dinamakan...',
              opts: ['Kamen', 'Jarik', 'Sarung', 'Tapis'],
              correct: 0,
            ),
            _soal(
              q: 'Pakaian adat tradisional dari DI Yogyakarta untuk pria yang mirip dengan beskap namun memiliki motif batik atau lurik yang khas dinamakan...',
              opts: ['Surjan', 'Pangsi', 'Kebaya Kutubaru', 'Jas Takwo'],
              correct: 0,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: pakaianId,
          categoryName: 'Pakaian Adat Nusantara',
          cardNumber: 4,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Pakaian tradisional berbahan dasar kain tenun ikat yang dikenakan sepasang pengantin pada gambar di atas berasal dari daerah Suku Sasak di...',
              opts: [
                'Nusa Tenggara Barat (NTB)',
                'Bali',
                'Sulawesi Selatan',
                'Nusa Tenggara Timur (NTT)',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_16.jpg',
            ),
            _soal(
              q: 'Gambar pakaian adat dengan hiasan kepala berupa mahkota emas bertingkat yang megah bernama Aesan Gede ini berasal dari provinsi...',
              opts: ['Lampung', 'Sumatra Selatan', 'Jambi', 'Bengkulu'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_17.jpg',
            ),
            _soal(
              q: 'Pakaian adat pria Jawa yang dilengkapi dengan penutup kepala "Blangkon" seperti pada gambar di atas adalah...',
              opts: ['Kebaya', 'Beskap', 'Pangsi', 'Sadariah'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_18.jpg',
            ),
            _soal(
              q: 'Pakaian adat dengan dominasi warna merah, kuning, dan hitam serta manik-manik indah khas suku Toraja pada gambar bernama...',
              opts: ['Baju Pokko', 'Baju Cele', 'Baju Bodo', 'Baju Nggembe'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_19.jpg',
            ),
            _soal(
              q: 'Gambar pakaian adat dengan penutup kepala pria melengkung tinggi mirip tanduk bernama Siger ini berasal dari daerah...',
              opts: ['Lampung', 'Palembang', 'Padang', 'Bengkulu'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_20.jpg',
            ),
            _soal(
              q: 'Aksesoris pakaian adat Papua berupa tas tradisional yang dirajut dari serat kayu dan dipakai di kepala dinamakan...',
              opts: ['Noken', 'Salawaku', 'Koteka', 'Terompah'],
              correct: 0,
            ),
            _soal(
              q: 'Pakaian tradisional wanita dari Indonesia yang memiliki ciri khas lipatan kain di bagian tengah dada (tanpa kancing penuh di depan) disebut kebaya...',
              opts: ['Encim', 'Kartini', 'Kutubaru', 'Ambon'],
              correct: 2,
            ),
            _soal(
              q: 'Pakaian tradisional "Ulee Balang" merupakan pakaian adat yang melambangkan keagungan dan berasal dari provinsi...',
              opts: ['Riau', 'Sumatra Barat', 'Aceh', 'Sumatra Utara'],
              correct: 2,
            ),
            _soal(
              q: 'Pakaian adat dari Kalimantan Selatan yang menggunakan kain khas bermotif lajur atau garis bernama Sasirangan adalah...',
              opts: [
                'Bagajah Gamuling Baular Lulut',
                'King Baba',
                'Baju Kurung',
                'Pakaian Sultan',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Senjata tradisional yang menjadi pelengkap pakaian adat "Ulee Balang" dari Aceh dinamakan...',
              opts: ['Keris', 'Rencong', 'Badik', 'Kujang'],
              correct: 1,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: pakaianId,
          categoryName: 'Pakaian Adat Nusantara',
          cardNumber: 5,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Kain penutup bagian bawah tubuh berupa kain panjang yang dililitkan seperti pada gambar pakaian adat Bali dan Jawa dinamakan...',
              opts: ['Ulos', 'Songket', 'Kamen / Jarik', 'Sarung Celana'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_21.jpg',
            ),
            _soal(
              q: 'Gambar di atas memperlihatkan pakaian tradisional bernama Baju Kurung tanggung yang dilengkapi aksesoris dada berupa kalung bersusun, berasal dari...',
              opts: ['Jambi', 'Riau', 'Sumatra Barat', 'Sumatra Utara'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_22.jpg',
            ),
            _soal(
              q: 'Pakaian tradisional berhiaskan rumbai-rumbai bulu burung engang pada gambar di atas adalah ciri khas pakaian adat dari pulau…',
              opts: ['Sulawesi', 'Sumatra', 'Papua', 'Kalimantan'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_23.jpg',
            ),
            _soal(
              q: 'Berdasarkan gambar, pakaian adat berbahan longgar hitam dengan celana gombrang yang sering dipakai dalam seni pencak silat ini bernama...',
              opts: [
                'Baju Pangsi',
                'Baju Sadariah',
                'Baju Pesa\'an',
                'Baju Teluk Belanga',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_24.jpg',
            ),
            _soal(
              q: 'Pakaian tradisional pada gambar yang terdiri dari kaos garis merah-putih dan luaran hitam longgar merupakan pakaian adat Pesa\'an dari...',
              opts: [
                'Madura (Jawa Timur)',
                'Betawi (Jakarta)',
                'Sunda (Jawa Barat)',
                'Baduy (Banten)',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/pakaian_adat/pakaian_25.jpg',
            ),
            _soal(
              q: 'Penutup kepala pria pada pakaian adat Melayu Riau yang berbentuk lilitan kain yang indah dinamakan...',
              opts: ['Tanjak', 'Blangkon', 'Udeng', 'Kopiah'],
              correct: 0,
            ),
            _soal(
              q: 'Pakaian adat Suku Sasak dari Nusa Tenggara Barat (NTB) untuk kaum wanita yang sering digunakan saat menyambut tamu dinamakan...',
              opts: ['Baju Lambung', 'Baju Pegon', 'Baju Bodo', 'Baju Cele'],
              correct: 0,
            ),
            _soal(
              q: 'Keanekaragaman pakaian adat di Indonesia dipengaruhi oleh berbagai faktor bawah ini, \*kecuali\*...',
              opts: [
                'Letak geografis daerah',
                'Pengaruh budaya luar dan agama',
                'Ketersediaan bahan alam di lingkungan sekitar',
                'Tren fashion modern dari luar negeri',
              ],
              correct: 3,
            ),
            _soal(
              q: 'Warna pakaian adat tradisional Baju Bodo pada zaman dahulu digunakan untuk menunjukkan...',
              opts: [
                'Tingkat pendidikan seseorang',
                'Status sosial dan usia pemakainya',
                'Jumlah kekayaan keluarga',
                'Jenis pekerjaan pemakainya',
              ],
              correct: 1,
            ),
            _soal(
              q: 'Pakaian adat "Pangsi" yang berwarna hitam longgar lengkap dengan ikat kepala (totopong) merupakan pakaian tradisional dari suku...',
              opts: ['Sunda', 'Betawi', 'Jawa', 'Madura'],
              correct: 0,
            ),
          ],
        ),
      );
    }

    final tarianId = catMap['Tarian Tradisional'] ?? '';
    if (tarianId.isNotEmpty) {
      questions.addAll(
        _card(
          categoryId: tarianId,
          categoryName: 'Tarian Tradisional',
          cardNumber: 1,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Berdasarkan gambar di atas, tari tradisional yang menggunakan properti kipas dan berasal dari Sulawesi Selatan ini bernama...',
              opts: [
                'Tari Kipas Pakarena',
                'Tari Pagelu',
                'Tari Gandrang Bulo',
                'Tari Ma\'gellu',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_01.jpg',
            ),
            _soal(
              q: 'Perhatikan gambar penari yang duduk berbanjar sambil menggerakkan tangan dan badan dengan kompak. Tari ini berasal dari Aceh dan bernama...',
              opts: [
                'Tari Seudati',
                'Tari Rateb Meuseukat',
                'Tari Saman',
                'Tari Likok Pulo',
              ],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_02.jpg',
            ),
            _soal(
              q: 'Penari pada gambar di atas membawa piring di kedua telapak tangan sambil menari dengan gerakan cepat. Tari ini berasal dari provinsi...',
              opts: ['Jambi', 'Riau', 'Sumatra Utara', 'Sumatra Barat'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_03.png',
            ),
            _soal(
              q: 'Gambar di atas menunjukkan seorang penari yang mengenakan topeng dan hiasan bulu merak yang sangat besar dan megah. Tari ini dinamakan...',
              opts: [
                'Tari Kuda Lumping',
                'Tari Jaipong',
                'Tari Reog Ponorogo',
                'Tari Gambyong',
              ],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_04.jpg',
            ),
            _soal(
              q: 'Perhatikan gambar penari pria yang membawa perisai dan mandau, serta memakai hiasan bulu burung enggang di kepalanya. Ini adalah pakaian khas penari...',
              opts: [
                'Tari Kancet Papatai',
                'Tari Pendet',
                'Tari Cakalele',
                'Tari Suanggi',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_05.jpeg',
            ),
            _soal(
              q: 'Tari Saman merupakan salah satu tarian tradisional Indonesia yang sudah mendunia. Tari ini berasal dari daerah...',
              opts: ['Sumatra Utara', 'Riau', 'Aceh', 'Barat Daya Sumatra'],
              correct: 2,
            ),
            _soal(
              q: 'Properti utama yang digunakan dalam pertunjukan Tari Piring dari Sumatra Barat adalah...',
              opts: ['Lilin', 'Piring', 'Selendang', 'Kipas'],
              correct: 1,
            ),
            _soal(
              q: 'Tari Kecak dari Bali dikenal unik karena iringan musiknya tidak menggunakan alat musik gamelan, melainkan menggunakan...',
              opts: [
                'Suara manusia secara massal ("cak-cak-cak")',
                'Tiupan seruling bambu',
                'Petikan senar gitar tradisional',
                'Hentakan kaki para penari',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Tari Jaipong merupakan tarian tradisional yang sangat populer dan berasal dari provinsi...',
              opts: ['Jawa Tengah', 'Jawa Timur', 'DKI Jakarta', 'Jawa Barat'],
              correct: 3,
            ),
            _soal(
              q: 'Tari Reog Ponorogo yang menampilkan topeng kepala singa berukuran sangat besar berasal dari provinsi...',
              opts: [
                'Jawa Timur',
                'Jawa Tengah',
                'DI Yogyakarta',
                'Jawa Barat',
              ],
              correct: 0,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: tarianId,
          categoryName: 'Tarian Tradisional',
          cardNumber: 2,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Gambar di atas memperlihatkan pertunjukan tari massal di Bali di mana para penari pria duduk melingkar sambil mengangkat kedua tangan dan meneriakkan kata "cak". Tari ini adalah...',
              opts: ['Tari Legong', 'Tari Barong', 'Tari Janger', 'Tari Kecak'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_06.png',
            ),
            _soal(
              q: 'Berdasarkan gambar penari wanita yang membawa mangkuk kecil berisi bunga dan memperlihatkan gerakan mata yang khas (seledet), tari asal Bali ini bernama...',
              opts: [
                'Tari Pendet',
                'Tari Bali Agung',
                'Tari Oleg Tamulilingan',
                'Tari Trunajaya',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_07.jpg',
            ),
            _soal(
              q: 'Gambar di atas menampilkan sekelompok penari wanita yang bergerak lincah and dinamis dengan iringan musik kendang yang dominan. Tari khas Jawa Barat ini dinamakan...',
              opts: [
                'Tari Merak',
                'Tari Jaipong',
                'Tari Ronggeng',
                'Tari Topeng Kuncaran',
              ],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_08.jpg',
            ),
            _soal(
              q: 'Perhatikan gambar penari wanita yang menggunakan kostum menyerupai burung dengan sayap yang indah dan penuh warna. Tari tradisional ini adalah...',
              opts: [
                'Tari Merak',
                'Tari Cendrawasih',
                'Tari Enggang',
                'Tari Kasuari',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_09.jpg',
            ),
            _soal(
              q: 'Gambar tersebut memperlihatkan sekelompok penari yang membawa busur dan anak panah. Tari berburu yang berasal dari Papua ini adalah...',
              opts: ['Tari Sajojo', 'Tari Yospan', 'Tari Panah', 'Tari Musyoh'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_10.jpg',
            ),
            _soal(
              q: 'Senjata tradisional yang sering digunakan sebagai properti dalam tari perang suku Dayak di Kalimantan adalah...',
              opts: ['Keris', 'Rencong', 'Kujang', 'Mandau'],
              correct: 3,
            ),
            _soal(
              q: 'Tari Pendet pada awalnya merupakan tarian yang dilakukan di pura sebagai bentuk...',
              opts: [
                'Hiburan rakyat',
                'Perayaan kemenangan perang',
                'Pemujaan atau penyambutan dewa',
                'Upacara panen padi',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Tari tradisional yang menggambarkan keindahan burung merak dengan gerakan mengepakkan sayap bernama...',
              opts: [
                'Tari Cendrawasih',
                'Tari Garuda',
                'Tari Merak',
                'Tari Enggang',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Salah satu tarian dari Papua yang sering digunakan untuk menyambut tamu dan dinyanyikan dengan lagu ceria secara massal adalah...',
              opts: [
                'Tari Kecak',
                'Tari Saman',
                'Tari Sajojo',
                'Tari Cakalele',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Tari Remo dari Jawa Timur biasanya dipentaskan sebagai tarian pembuka dalam pertunjukan kesenian...',
              opts: ['Ketoprak', 'Ludruk', 'Wayang Orang', 'Lenong'],
              correct: 1,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: tarianId,
          categoryName: 'Tarian Tradisional',
          cardNumber: 3,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Perhatikan kostum penari pada gambar yang didominasi warna merah, hitam, dan kuning, serta membawa selendang. Tari klasik yang berasal dari Daerah Istimewa Yogyakarta ini adalah...',
              opts: [
                'Tari Gambyong',
                'Tari Bedhaya',
                'Tari Ketuk Tilu',
                'Tari Serimpi',
              ],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_11.png',
            ),
            _soal(
              q: 'Gambar di atas menunjukkan sekelompok penari pria yang menunggangi anyaman bambu berbentuk kuda. Tari rakyat yang sangat populer di Jawa ini bernama...',
              opts: [
                'Tari Reog',
                'Tari Kuda Lumping',
                'Tari Ndolalak',
                'Tari Jathilan',
              ],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_12.jpg',
            ),
            _soal(
              q: 'Berdasarkan gerakan melompat tinggi melewati batu yang ada di latar belakang penari, tari tradisional ini erat kaitannya dengan tradisi lompat batu di...',
              opts: [
                'Mentawai (Sumatra Barat)',
                'Nias (Sumatra Utara)',
                'Sumba (Nusa Tenggara Timur)',
                'Flores (Nusa Tenggara Timur)',
              ],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_13.jpeg',
            ),
            _soal(
              q: 'Gambar di atas menunjukkan sekelompok penari wanita yang membawa lilin menyala di atas piring kecil yang dipegang dengan telapak tangan. Nama tari ini adalah...',
              opts: [
                'Tari Piring',
                'Tari Lilin',
                'Tari Tanggai',
                'Tari Gending Sriwijaya',
              ],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_14.jpg',
            ),
            _soal(
              q: 'Perhatikan gambar penari yang mengenakan pakaian adat Melayu dan membawa mangkuk/kotak berisi sirih untuk dipersembahkan kepada tamu. Tari ini adalah...',
              opts: [
                'Tari Zapin',
                'Tari Tandak',
                'Tari Joget Lambak',
                'Tari Persembahan / Sekapur Sirih',
              ],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_15.jpg',
            ),
            _soal(
              q: 'Properti berupa anyaman bambu berbentuk kuda digunakan dalam pertunjukan tari...',
              opts: [
                'Tari Reog',
                'Tari Barong',
                'Tari Topeng',
                'Tari Kuda Lumping',
              ],
              correct: 3,
            ),
            _soal(
              q: 'Tari Serimpi merupakan tari klasik yang tumbuh dan berkembang di lingkungan...',
              opts: [
                'Keraton Jawa (Yogyakarta dan Surakarta)',
                'Masyarakat pesisir pantai',
                'Suku pedalaman Kalimantan',
                'Perkampungan nelayan Sulawesi',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Tari tradisional yang penarinya membawa lilin menyala di atas piring sambil menari di ruangan gelap dinamakan...',
              opts: ['Tari Piring', 'Tari Lilin', 'Tari Obor', 'Tari Pendet'],
              correct: 1,
            ),
            _soal(
              q: 'Suku Dayak di Kalimantan memiliki tari tradisional yang menggunakan bulu burung sebagai properti di tangan. Burung yang disakralkan tersebut adalah...',
              opts: [
                'Burung Merak',
                'Burung Cendrawasih',
                'Burung Enggang',
                'Burung Elang',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Tari Zapin merupakan tari tradisional yang mendapat pengaruh kuat dari budaya...',
              opts: ['Tionghoa', 'India/Hindu', 'Eropa', 'Arab/Islam'],
              correct: 3,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: tarianId,
          categoryName: 'Tarian Tradisional',
          cardNumber: 4,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Gambar di atas menampilkan para penari yang bergerak lincah dengan menghentakkan kaki ke lantai papan, diiringi musik petik instrumen Sape. Tari ini berasal dari suku...',
              opts: ['Suku Banjar', 'Suku Kutai', 'Suku Dayak', 'Suku Paser'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_16.jpg',
            ),
            _soal(
              q: 'Gambar tersebut menunjukkan pertunjukan tari di mana para penari pria memakai pakaian perang dan membawa tombak/parang dari Maluku. Tari ini disebut...',
              opts: [
                'Tari Lenso',
                'Tari Saureka-Reka',
                'Tari Cakalele',
                'Tari Orlapei',
              ],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_17.webp',
            ),
            _soal(
              q: 'Perhatikan gambar penari wanita yang menggerakkan tubuhnya dengan lemah gemulai di atas sebatang bambu yang dipasang horizontal. Tari tradisional ini berasal dari Sulawesi Tengah, yaitu...',
              opts: [
                'Tari Lumense',
                'Tari Pontanu',
                'Tari Dero',
                'Tari Peule Cinde',
              ],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_18.webp',
            ),
            _soal(
              q: 'Gambar di atas memperlihatkan sekelompok remaja yang menari berpasangan dengan gerakan kaki yang ceria dan penuh semangat kebersamaan. Tari persahabatan dari Papua ini adalah...',
              opts: [
                'Tari Musyoh',
                'Tari Sajojo',
                'Tari Yospan',
                'Tari Selamat Datang',
              ],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_19.webp',
            ),
            _soal(
              q: 'Berdasarkan gambar penari yang memakai pakaian adat dengan hiasan kepala menyerupai tanduk rumah gadang, tari ini dipastikan berasal dari daerah...',
              opts: ['Sumatra Selatan', 'Jambi', 'Bengkulu', 'Sumatra Barat'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_20.jpg',
            ),
            _soal(
              q: 'Provinsi yang terkenal dengan Tari Kipas Pakarena adalah...',
              opts: [
                'Sulawesi Utara',
                'Sulawesi Selatan',
                'Sulawesi Tenggara',
                'Sulawesi Tengah',
              ],
              correct: 1,
            ),
            _soal(
              q: 'Tari Tor-Tor merupakan tarian adat yang ditarikan dalam upacara adat suku...',
              opts: ['Batak', 'Minangkabau', 'Melayu', 'Nias'],
              correct: 0,
            ),
            _soal(
              q: 'Properti payung dalam Tari Payung dari Sumatra Barat melambangkan...',
              opts: [
                'Kesiapan menghadapi bencana hujan',
                'Status sosial yang tinggi',
                'Perlindungan kasih sayang dalam keluarga atau pasangan',
                'Kekuatan melawan musuh',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Tari Yapong merupakan tari kreasi baru yang dikembangkan untuk mengekspresikan kegembiraan masyarakat suku...',
              opts: ['Sunda', 'Baduy', 'Betawi', 'Jawa'],
              correct: 2,
            ),
            _soal(
              q: 'Tari Cakalele merupakan tari perang tradisional yang berasal dari daerah...',
              opts: ['Papua', 'NTT', 'Maluku', 'NTB'],
              correct: 2,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: tarianId,
          categoryName: 'Tarian Tradisional',
          cardNumber: 5,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Gambar di atas menunjukkan penari yang memegang payung dan menari berpasangan secara romantis. Tari tradisional ini bernama...',
              opts: [
                'Tari Payung',
                'Tari Karonsih',
                'Tari Gandrung',
                'Tari Remo',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_21.png',
            ),
            _soal(
              q: 'Perhatikan gambar penari dengan gerakan kaki yang tegas, mengenakan selendang, dan berfungsi sebagai tari penyambutan tamu di Jawa Timur. Tari ini adalah...',
              opts: [
                'Tari Jejer',
                'Tari Gandrung Banyuwangi',
                'Tari Caping Ngancak',
                'Tari Remo',
              ],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_22.jpg',
            ),
            _soal(
              q: 'Gambar di atas menampilkan penari wanita yang mengenakan properti topi caping (topi petani) dari anyaman bambu. Tari ini menggambarkan kehidupan...',
              opts: ['Nelayan', 'Petani', 'Pemburu', 'Penenun'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_23.jpg',
            ),
            _soal(
              q: 'Gambar tersebut memperlihatkan sekelompok penari yang melompati bilah-bilah bambu yang dibuka-tutup oleh penari lain. Tari yang melatih ketangkasan ini bernama...',
              opts: [
                'Tari Saureka-Reka',
                'Tari Gaba-Gaba',
                'Tari Likok Pulo',
                'Tari Kabasaran',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_24.webp',
            ),
            _soal(
              q: 'Perhatikan gambar kostum penari yang menggunakan pakaian adat khas Jakarta (Betawi) dengan warna-warna cerah. Tari kreasi baru Betawi ini adalah...',
              opts: [
                'Tari Yapong',
                'Tari Cokek',
                'Tari Topeng Betawi',
                'Tari Lenggang Nyai',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/tari_tradisional/tari_25.jpg',
            ),
            _soal(
              q: 'Alat musik petik khas Kalimantan yang sering mengiringi tarian suku Dayak dinamakan...',
              opts: ['Sasando', 'Angklung', 'Sape', 'Kolintang'],
              correct: 2,
            ),
            _soal(
              q: 'Tari Gandrung merupakan tarian khas yang menjadi maskot dari kabupaten...',
              opts: ['Ponorogo', 'Banyuwangi', 'Malang', 'Blitar'],
              correct: 1,
            ),
            _soal(
              q: 'Tari tradisional yang menggunakan bilah-bilah bambu yang diketuk-ketukkan di lantai sebagai rintangan bagi penari dinamakan tari...',
              opts: [
                'Tari Saureka-Reka',
                'Tari Saman',
                'Tari Tor-Tor',
                'Tari Jaipong',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Keunikan gerakan mata yang melirik ke kanan dan ke kiri secara tajam pada tari Bali disebut...',
              opts: ['Ngeseh', 'Agem', 'Seledet', 'Ngumbang'],
              correct: 2,
            ),
            _soal(
              q: 'Tari Sekapur Sirih dari Jambi berfungsi sebagai tari...',
              opts: [
                'Upacara kematian',
                'Persembahan penyambutan tamu agung',
                'Tolak bala/mengusir roh jahat',
                'Perayaan panen raya',
              ],
              correct: 1,
            ),
          ],
        ),
      );
    }

    final musikId = catMap['Musik Tradisional Nusantara'] ?? '';
    if (musikId.isNotEmpty) {
      questions.addAll(
        _card(
          categoryId: musikId,
          categoryName: 'Musik Tradisional Nusantara',
          cardNumber: 1,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Alat musik tradisional pada gambar di atas berasal dari Jawa Barat dan dimainkan dengan cara digoyang. Alat musik ini bernama...',
              opts: ['Sasando', 'Angklung', 'Kolintang', 'Calung'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_01.png',
            ),
            _soal(
              q: 'Gambar di atas menunjukkan alat musik petik khas Nusa Tenggara Timur yang terbuat dari daun lontar. Nama alat musik ini adalah...',
              opts: ['Kecapi', 'Sampe', 'Japen', 'Sasando'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_02.png',
            ),
            _soal(
              q: 'Berdasarkan gambar tersebut, alat musik tiup khas Minangkabau yang mirip dengan suling ini disebut...',
              opts: ['Seruling', 'Tifa', 'Saluang', 'Lalove'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_03.jpg',
            ),
            _soal(
              q: 'Gambar di atas menampilkan alat musik perkusi asal Papua dan Maluku yang dimainkan dengan cara dipukul. Nama alat musik ini adalah...',
              opts: ['Tifa', 'Kendang', 'Rebana', 'Gong'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_04.png',
            ),
            _soal(
              q: 'Alat musik pada gambar merupakan ansambel musik tradisional khas Jawa dan Bali. Ansambel ini disebut...',
              opts: ['Talempong', 'Degung', 'Gamelan', 'Tanjidor'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_05.jpg',
            ),
            _soal(
              q: 'Lagu daerah berjudul "Ampar-Ampar Pisang" berasal dari provinsi...',
              opts: [
                'Kalimantan Barat',
                'Sulawesi Selatan',
                'Kalimantan Selatan',
                'Sumatra Utara',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Lagu "Apuse" dan "Yamko Rambe Yamko" merupakan lagu daerah yang berasal dari...',
              opts: ['Maluku', 'NTT', 'Sulawesi Utara', 'Papua'],
              correct: 3,
            ),
            _soal(
              q: 'Musik Keroncong merupakan musik perpaduan antara budaya Nusantara dengan budaya negara...',
              opts: ['Spanyol', 'Belanda', 'Portugis', 'Inggris'],
              correct: 2,
            ),
            _soal(
              q: 'Penyanyi atau vokalis wanita dalam ansambel musik Gamelan Jawa disebut...',
              opts: ['Sinden', 'Wiraswara', 'Biduan', 'Dalang'],
              correct: 0,
            ),
            _soal(
              q: 'Lagu daerah dari Jakarta yang menceritakan tentang seni pertunjukan boneka besar adalah...',
              opts: ['Jali-Jali', 'Ondel-Ondel', 'Kicir-Kicir', 'Surilang'],
              correct: 1,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: musikId,
          categoryName: 'Musik Tradisional Nusantara',
          cardNumber: 2,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Gambar di atas menunjukkan alat musik petik khas suku Dayak di Kalimantan. Alat musik ini bernama...',
              opts: ['Guoto', 'Sampe', 'Hasapi', 'Celempung'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_06.jpg',
            ),
            _soal(
              q: 'Alat musik pukul pada gambar terbuat dari bilah-bilah kayu asli Sulawesi Utara. Nama alat musik ini adalah...',
              opts: ['Gambang', 'Saron', 'Bonang', 'Kolintang'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_07.jpeg',
            ),
            _soal(
              q: 'Gambar di atas menunjukkan alat musik membranofon yang sering digunakan dalam musik Melayu dan Kasidah. Alat musik ini adalah...',
              opts: ['Ketipung', 'Rebana', 'Marawis', 'Bedug'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_08.jpeg',
            ),
            _soal(
              q: 'Alat musik tiup berukuran besar pada gambar di atas berasal dari Maluku dan terbuat dari kerang. Nama alat musik ini adalah...',
              opts: ['Fuu', 'Triton', 'Tahuri', 'Kuriding'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_09.jpeg',
            ),
            _soal(
              q: 'Gambar di atas menunjukkan alat musik tradisional Minangkabau yang terdiri dari beberapa gong kecil yang diletakkan berjejer. Alat musik ini bernama...',
              opts: ['Bonang', 'Kenong', 'Kangkanung', 'Talempong'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_10.jpeg',
            ),
            _soal(
              q: 'Alat musik tradisional Angklung sudah diakui oleh UNESCO sebagai Warisan Budaya Takbenda yang berasal dari negara...',
              opts: ['Malaysia', 'Indonesia', 'Filipina', 'Brunei Darussalam'],
              correct: 1,
            ),
            _soal(
              q: 'Lagu daerah "Rasa Sayange" merupakan lagu yang berasal dari daerah...',
              opts: ['Papua', 'NTT', 'Sulawesi Tenggara', 'Maluku'],
              correct: 3,
            ),
            _soal(
              q: 'Musik tradisional yang berfungsi untuk mengiringi tarian khas dari Aceh, yaitu Tari Saman, adalah...',
              opts: [
                'Musik Gamelan',
                'Tepukan tangan dan suara penari sendiri',
                'Musik Gambus',
                'Musik Tanjidor',
              ],
              correct: 1,
            ),
            _soal(
              q: 'Alat musik Sasando dimainkan dengan cara...',
              opts: ['Dipukul', 'Ditiup', 'Dipetik', 'Digesek'],
              correct: 2,
            ),
            _soal(
              q: 'Lagu "Gundhul-Gundhul Pacul" merupakan lagu daerah yang mengandung nasihat bagi seorang pemimpin. Lagu ini berasal dari...',
              opts: ['Jawa Barat', 'Bali', 'Madura', 'Jawa Tengah'],
              correct: 3,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: musikId,
          categoryName: 'Musik Tradisional Nusantara',
          cardNumber: 3,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Alat musik gesek pada gambar sering digunakan dalam kesenian Betawi maupun Jawa. Alat musik ini bernama...',
              opts: ['Sukong', 'Tehyan', 'Biola', 'Rebab'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_11.png',
            ),
            _soal(
              q: 'Berdasarkan gambar di atas, alat musik tiup bambu yang berbentuk seperti huruf \'L\' dari Sulawesi Selatan ini dinamakan...',
              opts: ['Lalove', 'Suling Lembang', 'Pompang', 'Bansi'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_12.jpg',
            ),
            _soal(
              q: 'Gambar di atas menunjukkan salah satu bagian gamelan yang berbentuk bilah perunggu dengan resonator bambu di bawahnya. Alat musik ini bernama...',
              opts: ['Gender', 'Gong', 'Gambang', 'Kempul'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_13.jpg',
            ),
            _soal(
              q: 'Alat musik pukul tradisional pada gambar ini terbuat dari bambu, mirip angklung tetapi bunyinya dihasilkan dengan memukul bilah bambunya. Alat musik ini adalah...',
              opts: ['Rindik', 'Celempung', 'Calung', 'Gambang'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_14.jpg',
            ),
            _soal(
              q: 'Gambar tersebut menunjukkan alat musik tiup yang terbuat dari bambu berukuran besar dari Maluku. Alat musik ini bernama...',
              opts: ['Seruling', 'Fuu', 'Suling Lembang', 'Sawangan'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_15.jpeg',
            ),
            _soal(
              q: 'Musik tradisional Gambang Kromong merupakan musik khas dari suku...',
              opts: ['Betawi', 'Sunda', 'Jawa', 'Madura'],
              correct: 0,
            ),
            _soal(
              q: 'Di bawah ini yang _bukan_ merupakan fungsi dari musik Nusantara pada zaman dahulu adalah...',
              opts: [
                'Sarana upacara adat',
                'Media untuk berjualan keliling',
                'Sarana hiburan rakyat',
                'Pengiring pertunjukan tari',
              ],
              correct: 1,
            ),
            _soal(
              q: 'Tangga nada yang paling sering digunakan dalam musik Gamelan Jawa adalah...',
              opts: [
                'Diatonis Mayor',
                'Pentatonis (Pelog dan Slendro)',
                'Diatonis Minor',
                'Kromatis',
              ],
              correct: 1,
            ),
            _soal(
              q: 'Lagu daerah "Bungong Jeumpa" menceritakan tentang keindahan sebuah bunga di daerah...',
              opts: ['Aceh', 'Sumatra Barat', 'Riau', 'Jambi'],
              correct: 0,
            ),
            _soal(
              q: 'Alat musik tradisional Tifa dimainkan dengan cara...',
              opts: ['Dipetik', 'Ditiup', 'Digoyang', 'Dipukul'],
              correct: 3,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: musikId,
          categoryName: 'Musik Tradisional Nusantara',
          cardNumber: 4,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Alat musik pada gambar di atas dimainkan dengan cara dipetik dan berasal dari Sumatra Utara (suku Batak). Nama alat musik ini adalah...',
              opts: ['Hapetan', 'Kulintang', 'Kecapi', 'Hasapi'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_16.jpg',
            ),
            _soal(
              q: 'Gambar di atas menampilkan alat musik pukul berbentuk lingkaran yang digantung, digunakan sebagai penanda akhir bait dalam musik Gamelan. Alat musik ini adalah...',
              opts: ['Kenong', 'Kempul', 'Kethuk', 'Gong'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_17.jpeg',
            ),
            _soal(
              q: 'Alat musik pada gambar terbuat dari bambu dan menjadi pengiring utama musik dari Bali yang sering dimainkan di pantai. Nama alat musik ini adalah...',
              opts: ['Rindik', 'Calung', 'Gamelan Bali', 'Klentangan'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_18.jpg',
            ),
            _soal(
              q: 'Gambar di atas menunjukkan kesenian musik khas Betawi yang menggunakan alat musik tiup seperti trompet berbahan kuningan. Kesenian ini dinamakan...',
              opts: ['Gambang Kromong', 'Keroncong', 'Marawis', 'Tanjidor'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_19.webp',
            ),
            _soal(
              q: 'Berdasarkan gambar di atas, jenis kendang berukuran kecil yang biasanya diletakkan di tengah pada gamelan Jawa dinamakan...',
              opts: [
                'Kendang Ciblon',
                'Kendang Ketipung',
                'Kendang Ageng',
                'Bedug',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_20.jpg',
            ),
            _soal(
              q: 'Lagu "Soleram" adalah lagu pengantar tidur yang terkenal dan berasal dari daerah...',
              opts: ['Sumatra Utara', 'Riau', 'Palembang', 'Lampung'],
              correct: 1,
            ),
            _soal(
              q: 'Penyanyi pria yang bernyanyi bersama-sama dalam musik Gamelan Jawa dinamakan...',
              opts: ['Wiraswara', 'Sinden', 'Panitera', 'Wiyaga'],
              correct: 0,
            ),
            _soal(
              q: 'Alat musik tradisional Kolintang dibuat dari bahan dasar...',
              opts: ['Bambu', 'Logam kuningan', 'Kulit hewan', 'Kayu'],
              correct: 3,
            ),
            _soal(
              q: 'Lagu daerah "O Ina Ni Keke" berasal dari daerah...',
              opts: [
                'Sulawesi Selatan',
                'Gorontalo',
                'Sulawesi Utara',
                'Sulawesi Tengah',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Alat musik tradisional yang dimainkan dengan cara ditiup disebut juga dengan istilah...',
              opts: ['Membranofon', 'Aerofon', 'Idiofon', 'Kordofon'],
              correct: 1,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: musikId,
          categoryName: 'Musik Tradisional Nusantara',
          cardNumber: 5,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Gambar di atas menunjukkan alat musik tradisional sejenis kecapi yang berasal dari Sulawesi Selatan. Nama alat musik tersebut adalah...',
              opts: ['Sampe', 'Sitera', 'Kacaping', 'Celempung'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_21.jpg',
            ),
            _soal(
              q: 'Alat musik pada gambar di atas dimainkan dengan cara dipukul menggunakan pemukul khusus, berasal dari Aceh dan mirip dengan gendang silinder. Alat musik ini adalah...',
              opts: ['Rapai', 'Geundrang', 'Tifa', 'Dol'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_22.jpg',
            ),
            _soal(
              q: 'Alat musik tradisional yang terbuat dari bambu dan merupakan sejenis organ tiup dari Kalimantan Barat adalah...',
              opts: ['Angklung', 'Sape', 'Kledi', 'Kolintang'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_23.jpg',
            ),
            _soal(
              q: 'Alat musik perkusi berukuran besar dari Bengkulu yang dimainkan dalam perayaan Tabot adalah...',
              opts: ['Gong', 'Tifa', 'Kendang', 'Dol'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_24.jpg',
            ),
            _soal(
              q: 'Alat musik gesek khas daerah Sulawesi Selatan yang menyerupai rebab adalah...',
              opts: ['Gesok-Gesok', 'Biola', 'Tehyan', 'Sukong'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/musik_nusantara/musik_25.jpg',
            ),
            _soal(
              q: 'Lagu daerah Sumatra Barat yang mengisahkan tentang kerinduan seorang anak kepada kampung halamannya adalah...',
              opts: [
                'Ayam Den Lapeh',
                'Badindin',
                'Kampuang Nan Jauh Di Mato',
                'Barek Solok',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Alat musik tradisional Indonesia yang terbuat dari bambu dan menghasilkan bunyi saat digoyang adalah...',
              opts: ['Calung', 'Suling', 'Rindik', 'Angklung'],
              correct: 3,
            ),
            _soal(
              q: 'Tangga nada pentatonis tradisional Nusantara terdiri dari berapa nada pokok dalam satu oktaf?',
              opts: ['7 nada', '12 nada', '5 nada', '8 nada'],
              correct: 2,
            ),
            _soal(
              q: 'Lagu daerah "Manuk Dadali" yang mengisahkan tentang kegagahan burung garuda berasal dari daerah...',
              opts: ['Jawa Tengah', 'Jawa Barat', 'Banten', 'DKI Jakarta'],
              correct: 1,
            ),
            _soal(
              q: 'Alat musik perkusi yang sering digunakan untuk mengiringi lagu-lagu bernuansa Islami di Nusantara dinamakan...',
              opts: ['Gong', 'Kendang', 'Rebana', 'Sasando'],
              correct: 2,
            ),
          ],
        ),
      );
    }

    final senjataId = catMap['Senjata Tradisional'] ?? '';
    if (senjataId.isNotEmpty) {
      questions.addAll(
        _card(
          categoryId: senjataId,
          categoryName: 'Senjata Tradisional',
          cardNumber: 1,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Senjata tradisional khas suku Jawa yang memiliki lekukan (luk) khas dan sering dianggap sakral adalah...',
              opts: ['Rencong', 'Mandau', 'Kujang', 'Keris'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_01.png',
            ),
            _soal(
              q: 'Perhatikan gambar\! Senjata tradisional asal Jawa Barat yang bentuknya mirip dengan tanduk rusa atau kepala burung ini dinamakan...',
              opts: ['Badik', 'Kujang', 'Celurit', 'Golok'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_02.png',
            ),
            _soal(
              q: 'Gambar tersebut menunjukkan senjata tradisional asal Madura yang berbentuk melengkung menyerupai bulan sabit, yaitu...',
              opts: ['Rencong', 'Parang', 'Celurit', 'Klewang'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_03.jpg',
            ),
            _soal(
              q: 'Senjata tikam sejenis belati asal Aceh yang bentuk gagangnya menyerupai huruf "L" pada gambar dinamakan...',
              opts: ['Rencong', 'Badik', 'Kurambiak', 'Keris'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_04.png',
            ),
            _soal(
              q: 'Gambar ini memperlihatkan pedang panjang khas suku Dayak di Kalimantan Barat yang gagangnya dihiasi bulu burung, yaitu...',
              opts: [
                'Pedang Jenawi',
                'Golok Rempu',
                'Parang Salawaku',
                'Mandau',
              ],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_05.png',
            ),
            _soal(
              q: 'Senjata tradisional Indonesia yang sudah diakui oleh UNESCO sebagai Warisan Budaya Takbenda Dunia adalah...',
              opts: ['Celurit', 'Kujang', 'Mandau', 'Keris'],
              correct: 3,
            ),
            _soal(
              q: 'Suku Dayak di pedalaman Kalimantan memiliki senjata tiup beracun yang sangat senyap saat digunakan berburu. Senjata ini disebut...',
              opts: ['Sumpit', 'Busur', 'Ketapel', 'Tulup'],
              correct: 0,
            ),
            _soal(
              q: 'Pasangan senjata tradisional dan tameng pelindung khas dari daerah Maluku saat menarikan tarian Cakalele adalah...',
              opts: [
                'Mandau dan Talawang',
                'Golok dan Perisai',
                'Parang dan Salawaku',
                'Keris dan Tameng',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Senjata tradisional Jawa Barat yang erat kaitannya dengan sejarah Kerajaan Pajajaran dan Prabu Siliwangi adalah...',
              opts: ['Keris', 'Golok', 'Kujang', 'Badik'],
              correct: 2,
            ),
            _soal(
              q: 'Senjata tradisional khas dari Pulau Madura yang memiliki bentuk melengkung setengah lingkaran seperti bulan sabit dinamakan...',
              opts: ['Rencong', 'Celurit', 'Klewang', 'Parang'],
              correct: 1,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: senjataId,
          categoryName: 'Senjata Tradisional',
          cardNumber: 2,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Senjata tradisional berbentuk pisau kecil melengkung khas Minangkabau yang terinspirasi dari cakar harimau pada gambar adalah...',
              opts: [
                'Badik Lompo Battang',
                'Kurambiak (Karambit)',
                'Pisau Belati',
                'Kujang',
              ],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_06.jpg',
            ),
            _soal(
              q: 'Gambar tersebut menunjukkan senjata tikam khas Sulawesi Selatan yang mirip keris tetapi tidak memiliki lekukan (lurus), bernama...',
              opts: ['Badik', 'Rencong', 'Mandau', 'Kujang'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_07.jpeg',
            ),
            _soal(
              q: 'Berdasarkan gambar, senjata khas Papua berbentuk panah dan busur ini biasanya digunakan untuk berburu dan terbuat dari...',
              opts: [
                'Besi tempa',
                'Tulang burung kasuari',
                'Bambu atau kayu ruyung',
                'Tanduk kerbau',
              ],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_08.jpg',
            ),
            _soal(
              q: 'Senjata berupa tombak panjang khas Yogyakarta yang sering dibawa oleh prajurit keraton pada gambar dinamakan...',
              opts: ['Sumpit', 'Trisula', 'Tombak Pleret', 'Kujang'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_09.jpg',
            ),
            _soal(
              q: 'Perhatikan gambar\! Senjata tameng kayu panjang yang dipasangkan dengan parang dalam budaya perang Maluku adalah...',
              opts: ['Salawaku', 'Talawang', 'Utap', 'Panggona'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_10.jpg',
            ),
            _soal(
              q: 'Rencong merupakan senjata tradisional berbilah tajam yang melambangkan keberanian masyarakat dari provinsi...',
              opts: ['Sumatra Barat', 'Riau', 'Aceh', 'Jambi'],
              correct: 2,
            ),
            _soal(
              q: 'Si Pitung merupakan tokoh jawara legendaris yang identik dengan penggunaan senjata tradisional berupa...',
              opts: ['Kujang', 'Keris', 'Celurit', 'Golok Betawi'],
              correct: 3,
            ),
            _soal(
              q: 'Senjata tradisional Minangkabau yang bentuknya sangat kecil, melengkung, dan cara menggunakannya disisipkan di jari tangan dinamakan...',
              opts: ['Kurambiak (Karambit)', 'Badik', 'Rencong', 'Pisau Raut'],
              correct: 0,
            ),
            _soal(
              q: 'Senjata tradisional khas Papua yang bahan utamanya dibuat langsung dari alam tanpa logam, melainkan menggunakan tulang dari hewan asli Papua adalah...',
              opts: [
                'Busur dari rotan',
                'Tombak bambu',
                'Panah kayu ruyung',
                'Belati dari tulang burung kasuari',
              ],
              correct: 3,
            ),
            _soal(
              q: 'Di wilayah Sulawesi Selatan, suku Bugis dan Makassar memiliki senjata tikam tradisional lurus tanpa lekukan yang disebut...',
              opts: ['Mandau', 'Badik', 'Rencong', 'Kujang'],
              correct: 1,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: senjataId,
          categoryName: 'Senjata Tradisional',
          cardNumber: 3,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Gambar berikut menunjukkan tameng khas suku Dayak Kalimantan yang diukir dengan motif magis untuk perlindungan, yaitu...',
              opts: ['Salawaku', 'Kanjar', 'Talawang', 'Kurambiak'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_11.jpeg',
            ),
            _soal(
              q: 'Senjata tiup khas suku Dayak Kalimantan yang digunakan untuk menembak anak panah beracun pada gambar bernama...',
              opts: ['Tulup', 'Bendo', 'Panah', 'Sumpit (Sipet)'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_12.jpeg',
            ),
            _soal(
              q: 'Senjata tradisional berwujud pisau besar berwajah lebar khas Betawi pada gambar sangat populer digunakan oleh tokoh...',
              opts: [
                'Si Pitung (Golok Betawi)',
                'Wiro Sableng',
                'Gajah Mada',
                'Ken Arok',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_13.jpg',
            ),
            _soal(
              q: 'Gambar tersebut menampilkan senjata tradisional Sumatra Utara sejenis pedang pendek yang ujung sarungnya melengkung ke atas, yaitu...',
              opts: ['Piso Podang', 'Piso Gaja Dompak', 'Rencong', 'Mandau'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_14.jpg',
            ),
            _soal(
              q: 'Senjata tradisional Bali yang mirip dengan keris tetapi memiliki gagang berupa patung atau ukiran indah pada gambar adalah...',
              opts: ['Wedhung', 'Tiuk', 'Keris Bali', 'Taji'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_15.jpg',
            ),
            _soal(
              q: 'Senjata tradisional Sumatra Utara yang menjadi lambang kebesaran Raja-raja Batak dan memiliki ukiran kepala gajah pada gagangnya adalah...',
              opts: [
                'Piso Podang',
                'Piso Gaja Dompak',
                'Piso Sanalenggam',
                'Piso Toba',
              ],
              correct: 1,
            ),
            _soal(
              q: 'Senjata tradisional khas Sumatra Selatan yang berbentuk seperti garpu besar dengan tiga mata tombak yang tajam dinamakan...',
              opts: ['Tombak Pleret', 'Seruit', 'Kujang', 'Trisula'],
              correct: 3,
            ),
            _soal(
              q: 'Suku Dayak menggunakan tameng pelindung yang terbuat dari kayu ringan tetapi sangat kuat dan dihiasi ukiran indah. Tameng ini disebut...',
              opts: ['Salawaku', 'Panggona', 'Talawang', 'Utap'],
              correct: 2,
            ),
            _soal(
              q: 'Pedang panjang dua tangan yang digunakan oleh prajurit Kerajaan Melayu di Riau untuk pertempuran jarak jauh dinamakan...',
              opts: ['Klewang', 'Mandau', 'Pedang Jenawi', 'Sundang'],
              correct: 2,
            ),
            _soal(
              q: 'Senjata tradisional Bali yang digunakan khusus sebagai pisau taji kecil yang dipasang pada kaki ayam saat acara ritual adat (tajen) dinamakan...',
              opts: ['Tiuk', 'Taji', 'Caluk', 'Kandik'],
              correct: 1,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: senjataId,
          categoryName: 'Senjata Tradisional',
          cardNumber: 4,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Perhatikan gambar\! Senjata genggam berbilah tipis khas masyarakat Riau yang bentuknya mirip daun teratai adalah...',
              opts: ['Badik Tumbuk Lada', 'Pedang Jenawi', 'Kujang', 'Rencong'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_16.jpg',
            ),
            _soal(
              q: 'Gambar tersebut menunjukkan pedang panjang dua tangan yang dahulu digunakan oleh para panglima perang kerajaan di Riau, bernama...',
              opts: ['Mandau', 'Pedang Jenawi', 'Klewang', 'Sundang'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_17.jpg',
            ),
            _soal(
              q: 'Senjata tradisional sejenis kapak kecil dengan bentuk hiasan ukiran khas suku Asmat Papua pada gambar disebut...',
              opts: ['Kapak Batu', 'Kurambiak', 'Kandik', 'Patu'],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_18.jpg',
            ),
            _soal(
              q: 'Gambar ini menunjukkan senjata tikam lurus berujung runcing dari Sumatra Selatan yang sarungnya dilapisi perak atau emas, bernama...',
              opts: ['Siwar', 'Kujang', 'Keris Palembang', 'Badik'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_19.jpg',
            ),
            _soal(
              q: 'Perhatikan gambar\! Senjata tradisional NTB sejenis keris yang gagangnya terbuat dari tanduk rusa atau kayu pelet dinamakan…',
              opts: ['Sampari', 'Keris Lombok', 'Pasatimpo', 'Belati'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_20.jpeg',
            ),
            _soal(
              q: 'Senjata tradisional sejenis pisau pendek dari daerah Jambi yang memiliki nama unik karena diyakini aromanya bisa membuat musuh pingsan adalah...',
              opts: [
                'Keris Siginjai',
                'Pedang Baiduri',
                'Badik Tumbuk Lada',
                'Siwar Panjang',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Senjata tradisional dari Nusa Tenggara Barat (NTB) yang bentuknya menyerupai keris dengan sarung bermotif indah dinamakan...',
              opts: ['Sampari', 'Pasatimpo', 'Guma', 'Alamang'],
              correct: 0,
            ),
            _soal(
              q: 'Senjata belati tradisional yang berasal dari daerah Sulawesi Tengah dan sering dipakai dalam upacara adat pernikahan dinamakan...',
              opts: ['Badik Bugis', 'Mandau', 'Rencong', 'Pasatimpo'],
              correct: 3,
            ),
            _soal(
              q: 'Senjata tradisional berbentuk pisau pemotong berukuran besar yang digunakan masyarakat banten untuk bertani maupun membela diri dinamakan...',
              opts: ['Kujang', 'Golok Ciomas', 'Keris', 'Celurit'],
              correct: 1,
            ),
            _soal(
              q: 'Keris tradisional yang memiliki bilah lurus tanpa lekukan sama sekali sering disebut dengan istilah...',
              opts: [
                'Keris Lurus (Sapu Jagat)',
                'Keris Luk',
                'Keris Majapahit',
                'Wedhung',
              ],
              correct: 0,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: senjataId,
          categoryName: 'Senjata Tradisional',
          cardNumber: 5,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Gambar tersebut memperlihatkan belati pendek khas Sulawesi Tengah yang sering disisipkan di ikat pinggang pakaian adat, yaitu...',
              opts: ['Badik', 'Alamang', 'Guma', 'Pasatimpo'],
              correct: 3,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_21.png',
            ),
            _soal(
              q: 'Senjata tradisional berbentuk tombak dengan tiga mata tajam (seperti garpu besar) pada gambar di bawah bernama...',
              opts: ['Kujang', 'Trisula', 'Kujang Kuntul', 'Kudhi'],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_22.jpg',
            ),
            _soal(
              q: 'Berdasarkan gambar, senjata potong berbentuk kapak genggam lonjong dari zaman prasejarah yang masih dilestarikan di pedalaman Papua adalah...',
              opts: [
                'Kapak Lonjong / Kapak Batu',
                'Kapak Perunggu',
                'Parang',
                'Beliung',
              ],
              correct: 0,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_23.jpg',
            ),
            _soal(
              q: 'Gambar ini menampilkan pisau dapur tradisional masyarakat Bali yang juga berfungsi sebagai senjata perlindungan diri sehari-hari, bernama...',
              opts: ['Taji', 'Caluk', 'Tiuk', 'Wedhung'],
              correct: 2,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_24.webp',
            ),
            _soal(
              q: 'Perhatikan gambar\! Senjata khas masyarakat Kalimantan Selatan berbentuk belati kecil dengan hiasan kuningan adalah...',
              opts: [
                'Belitung',
                'Wasi (Keris Pajang)',
                'Mandau kecil',
                'Sarapang',
              ],
              correct: 1,
              imageUrl:
                  'assets/quiz_category_images/senjata_tradisional/senjata_25.jpeg',
            ),
            _soal(
              q: 'Senjata tradisional suku Asmat di Papua yang digunakan untuk menebang pohon atau berburu pada zaman dahulu terbuat dari batu lonjong tipis yang diikat pada kayu. Senjata ini adalah...',
              opts: [
                'Tombak Kayu',
                'Panah Rotan',
                'Kapak Batu',
                'Belati Tulang',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Bagian dari senjata keris yang berfungsi sebagai wadah atau sarung pelindung bilah besi disebut...',
              opts: ['Ukiran', 'Warangka', 'Pendok', 'Luk'],
              correct: 1,
            ),
            _soal(
              q: 'Senjata tradisional berwujud pisau kecil pelindung diri khas kaum perempuan di Aceh yang bentuknya menyerupai rencong mini disebut...',
              opts: ['Siwar', 'Peudeung', 'Rentaka', 'Rencong Meucugek'],
              correct: 3,
            ),
            _soal(
              q: 'Senjata tradisional yang memiliki fungsi ganda sebagai alat kerja memotong kayu di hutan Kalimantan sekaligus senjata perang suku Dayak adalah...',
              opts: ['Talawang', 'Mandau', 'Sipet', 'Lonjo'],
              correct: 1,
            ),
            _soal(
              q: 'Senjata tradisional berbentuk melengkung mirip celurit namun ukurannya jauh lebih kecil dan digunakan oleh masyarakat Jawa Tengah untuk memotong padi dinamakan...',
              opts: ['Kudhi', 'Bendo', 'Ani-ani', 'Celurit Kecil'],
              correct: 2,
            ),
          ],
        ),
      );
    }

    final rumahId = catMap['Rumah Adat Nusantara'] ?? '';
    if (rumahId.isNotEmpty) {
      questions.addAll(
        _card(
          categoryId: rumahId,
          categoryName: 'Rumah Adat Nusantara',
          cardNumber: 1,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Rumah adat pada gambar di atas memiliki atap ikonik yang menyerupai tanduk kerbau. Apa nama rumah adat yang berasal dari Sumatra Barat ini?',
              opts: [
                'Rumah Joglo',
                'Rumah Gadang',
                'Rumah Tongkonan',
                'Rumah Bolon',
              ],
              correct: 1,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_01.png',
            ),
            _soal(
              q: 'Gambar di atas menunjukkan rumah adat suku Toraja dengan atap melengkung menyerupai perahu. Disebut apakah rumah adat ini?',
              opts: [
                'Rumah Honai',
                'Rumah Tongkonan',
                'Rumah Lamin',
                'Rumah Banjar',
              ],
              correct: 1,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_02.png',
            ),
            _soal(
              q: 'Perhatikan gambar di atas. Rumah adat khas Jawa Tengah ini memiliki ciri khas atap berbentuk tajug yang ditopang oleh soko guru. Apa namanya?',
              opts: [
                'Rumah Baileo',
                'Rumah Baduy',
                'Rumah Limas',
                'Rumah Joglo',
              ],
              correct: 3,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_03.png',
            ),
            _soal(
              q: 'Gambar di atas memperlihatkan rumah adat Papua yang berbentuk jamur bulat tanpa jendela untuk menahan dingin. Apa nama rumah adat ini?',
              opts: [
                'Rumah Tambi',
                'Rumah Sasak',
                'Rumah Honai',
                'Rumah Boyang',
              ],
              correct: 2,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_04.png',
            ),
            _soal(
              q: 'Berdasarkan gambar di atas, rumah panggung besar dan panjang dari Kalimantan Timur yang dihuni oleh suku Dayak ini bernama...',
              opts: [
                'Rumah Lamin',
                'Rumah Gadang',
                'Rumah Bubungan Tinggi',
                'Rumah Souraja',
              ],
              correct: 0,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_05.png',
            ),
            _soal(
              q: 'Rumah adat Gadang yang memiliki bentuk atap runcing seperti tanduk kerbau berasal dari provinsi...',
              opts: ['Sumatra Utara', 'Riau', 'Sumatra Barat', 'Jambi'],
              correct: 2,
            ),
            _soal(
              q: 'Provinsi yang terkenal dengan rumah adat berbentuk bulat jamur tanpa jendela bernama Honai adalah...',
              opts: [
                'Papua',
                'Maluku',
                'Nusa Tenggara Timur',
                'Sulawesi Utara',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Rumah Joglo merupakan rumah adat ikonik yang sangat mudah dijumpai di daerah...',
              opts: [
                'Jawa Barat dan Banten',
                'Jawa Tengah dan Yogyakarta',
                'Bali dan NTB',
                'Kalimantan Barat',
              ],
              correct: 1,
            ),
            _soal(
              q: 'Rumah panggung yang sangat panjang dan dihuni oleh puluhan keluarga suku Dayak di Kalimantan dinamakan rumah...',
              opts: ['Tongkonan', 'Gadang', 'Honai', 'Lamin atau Betang'],
              correct: 3,
            ),
            _soal(
              q: 'Suku Betawi di DKI Jakarta memiliki rumah adat tradisional yang terinspirasi dari lipatan kain. Rumah adat ini dinamakan...',
              opts: [
                'Rumah Kasepuhan',
                'Rumah Kebaya',
                'Rumah Joglo',
                'Rumah Baduy',
              ],
              correct: 1,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: rumahId,
          categoryName: 'Rumah Adat Nusantara',
          cardNumber: 2,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Gambar di atas menunjukkan rumah adat berbentuk limas bertingkat yang sering dijumpai di Palembang, Sumatra Selatan. Apa nama rumah adat tersebut?',
              opts: [
                'Rumah Panggung',
                'Rumah Krong Bade',
                'Rumah Limas',
                'Rumah Kebaya',
              ],
              correct: 2,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_06.jpeg',
            ),
            _soal(
              q: 'Perhatikan gambar struktur atap rumah adat DKI Jakarta yang berbentuk pelana lipat ini. Apa nama rumah adat khas suku Betawi ini?',
              opts: [
                'Rumah Kebaya',
                'Rumah Baduy',
                'Rumah Joglo',
                'Rumah Gapura Candi Bentar',
              ],
              correct: 0,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_07.webp',
            ),
            _soal(
              q: 'Gambar di atas adalah rumah adat dari suku Manggarai di NTT yang berbentuk kerucut tinggi melingkar. Rumah adat ini dikenal dengan nama...',
              opts: [
                'Rumah Musalaki',
                'Rumah Mbaru Niang',
                'Rumah Sao Ata Mosa Lakitana',
                'Rumah Dalam Loka',
              ],
              correct: 1,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_08.webp',
            ),
            _soal(
              q: 'Berdasarkan gambar di atas, rumah adat dari Provinsi Aceh yang berbentuk panggung tinggi dengan tangga di bagian depan dinamakan...',
              opts: [
                'Rumah Bolon',
                'Rumah Bubungan Lima',
                'Rumah Melayu Selaso Jatuh Kembar',
                'Rumah Krong Bade',
              ],
              correct: 3,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_09.webp',
            ),
            _soal(
              q: 'Gambar di atas menampilkan rumah adat suku Batak Toba di Sumatra Utara yang memiliki hiasan ukiran cicak dan payudara. Apa nama rumah ini?',
              opts: [
                'Rumah Gadang',
                'Rumah Bolon',
                'Rumah Baileo',
                'Rumah Boyang',
              ],
              correct: 1,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_10.png',
            ),
            _soal(
              q: 'Rumah adat Bolon merupakan rumah tradisional yang berasal dari suku Batak di provinsi...',
              opts: ['Aceh', 'Sumatra Selatan', 'Sumatra Utara', 'Riau'],
              correct: 2,
            ),
            _soal(
              q: 'Rumah adat Baileo yang berfungsi sebagai tempat pertemuan adat dan ibadah masyarakat terletak di kepulauan...',
              opts: ['NTT', 'Maluku', 'NTB', 'Bangka Belitung'],
              correct: 1,
            ),
            _soal(
              q: 'Rumah adat Gapura Candi Bentar memiliki ciri khas arsitektur yang kental dengan nuansa Hindu. Rumah adat ini berasal dari...',
              opts: ['Bali', 'Jawa Timur', 'Lombok', 'Kalimantan Selatan'],
              correct: 0,
            ),
            _soal(
              q: 'Rumah adat yang berbentuk panggung tinggi untuk menghindari banjir dan hewan buas di daerah Sumatera Selatan dinamakan...',
              opts: [
                'Rumah Gadang',
                'Rumah Kebaya',
                'Rumah Honai',
                'Rumah Limas',
              ],
              correct: 3,
            ),
            _soal(
              q: 'Rumah adat suku Toraja yang terkenal dengan struktur atap melengkung menyerupai perahu atau tanduk kerbau adalah...',
              opts: [
                'Rumah Tongkonan',
                'Rumah Walewangko',
                'Rumah Boyang',
                'Rumah Souraja',
              ],
              correct: 0,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: rumahId,
          categoryName: 'Rumah Adat Nusantara',
          cardNumber: 3,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Perhatikan gambar gerbang masuk rumah adat Bali yang sangat ikonik dengan arsitektur pahatan batunya. Apa nama gapura adat ini?',
              opts: [
                'Rumah Joglo Situbondo',
                'Bale Manten',
                'Gapura Candi Bentar',
                'Rumah Souraja',
              ],
              correct: 2,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_11.jpg',
            ),
            _soal(
              q: 'Gambar di atas menunjukkan rumah adat berbentuk panggung melingkar tanpa dinding dari Maluku yang digunakan untuk musyawarah. Apa namanya?',
              opts: [
                'Rumah Baileo',
                'Rumah Tambi',
                'Rumah Sasak',
                'Rumah Walewangko',
              ],
              correct: 0,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_12.jpg',
            ),
            _soal(
              q: 'Berdasarkan gambar di atas, rumah adat dari Nusa Tenggara Barat (NTB) yang memiliki atap melengkung dari jerami hingga menyentuh tanah adalah...',
              opts: [
                'Rumah Dalam Loka',
                'Rumah Musalaki',
                'Rumah Mbaru Niang',
                'Rumah Sasak',
              ],
              correct: 3,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_13.webp',
            ),
            _soal(
              q: 'Gambar di atas memperlihatkan rumah adat Provinsi Riau yang memiliki ciri khas selasar jatuh ke bawah. Rumah adat ini disebut...',
              opts: [
                'Rumah Melayu Selaso Jatuh Kembar',
                'Rumah Bubungan Lima',
                'Rumah Limas',
                'Rumah Lontiok',
              ],
              correct: 0,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_14.jpg',
            ),
            _soal(
              q: 'Perhatikan gambar rumah adat Sulawesi Utara yang berbentuk panggung kayu kokoh dengan tangga di sisi kiri dan kanan berikut. Apa nama rumah adat ini?',
              opts: [
                'Rumah Tongkonan',
                'Rumah Walewangko',
                'Rumah Boyang',
                'Rumah Tambi',
              ],
              correct: 1,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_15.jpg',
            ),
            _soal(
              q: 'Apa nama rumah adat provinsi Aceh yang memiliki kolong panggung tinggi dan biasanya memiliki jumlah anak tangga yang ganjil?',
              opts: [
                'Rumah Melayu Selaso',
                'Rumah Krong Bade',
                'Rumah Bubungan Lima',
                'Rumah Nowou Sesat',
              ],
              correct: 1,
            ),
            _soal(
              q: 'Suku Baduy yang hidup selaras dengan alam di Provinsi Banten memiliki rumah adat bernama...',
              opts: [
                'Rumah Baduy (Sulah Nyanda)',
                'Rumah Kasepuhan',
                'Rumah Kebaya',
                'Rumah Joglo',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Rumah adat dari provinsi Jambi yang memiliki struktur panggung persegi panjang dinamakan...',
              opts: [
                'Rumah Limas',
                'Rumah Lontiok',
                'Rumah Panggung Kajang Leko',
                'Rumah Banjar',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Rumah adat Mbaru Niang yang berbentuk kerucut tinggi dengan 5 tingkat terletak di desa adat Wae Rebo, provinsi...',
              opts: [
                'Nusa Tenggara Barat',
                'Sulawesi Selatan',
                'Maluku Utara',
                'Nusa Tenggara Timur',
              ],
              correct: 3,
            ),
            _soal(
              q: 'Rumah adat Nowou Sesat yang memiliki arti "rumah ibadah/musyawarah" merupakan rumah tradisional dari provinsi...',
              opts: ['Bengkulu', 'Lampung', 'Jambi', 'Riau'],
              correct: 1,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: rumahId,
          categoryName: 'Rumah Adat Nusantara',
          cardNumber: 4,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Gambar di atas menampilkan rumah adat suku Mandar dari Sulawesi Barat yang berbentuk panggung kayu bermotif sarung tenun. Nama rumah adat ini adalah...',
              opts: [
                'Rumah Souraja',
                'Rumah Tongkonan',
                'Rumah Boyang',
                'Rumah Banjar',
              ],
              correct: 2,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_16.jpg',
            ),
            _soal(
              q: 'Berdasarkan gambar di atas, rumah adat dari Bengkulu yang ditopang oleh tiang-tiang besar dan memiliki atap bertingkat lima disebut...',
              opts: [
                'Rumah Krong Bade',
                'Rumah Limas',
                'Rumah Gadang',
                'Rumah Bubungan Lima',
              ],
              correct: 3,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_17.jpg',
            ),
            _soal(
              q: 'Gambar di atas menunjukkan rumah adat suku Baduy di Banten yang terbuat sepenuhnya dari bambu dan ijuk tanpa paku. Apa nama rumah adat tersebut?',
              opts: [
                'Rumah Kebaya',
                'Rumah Joglo',
                'Rumah Baduy (Sulah Nyanda)',
                'Rumah Kasepuhan',
              ],
              correct: 2,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_18.webp',
            ),
            _soal(
              q: 'Perhatikan gambar rumah adat dari Kalimantan Selatan yang memiliki ciri khas atap tinggi menjulang ke langit berikut. Apa nama rumah adat ini?',
              opts: [
                'Rumah Bubungan Tinggi',
                'Rumah Lamin',
                'Rumah Betang',
                'Rumah Pasang',
              ],
              correct: 0,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_19.jpeg',
            ),
            _soal(
              q: 'Gambar di atas memperlihatkan rumah adat berbahan kayu jati dari Jawa Timur yang sekilas mirip Joglo Jawa Tengah namun memiliki ciri khas tersendiri. Disebut apakah rumah ini?',
              opts: [
                'Rumah Kebaya',
                'Rumah Joglo Situbondo',
                'Rumah Baduy',
                'Rumah Gapura',
              ],
              correct: 1,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_20.jpg',
            ),
            _soal(
              q: 'Rumah adat Walewangko atau Rumah Pewaris merupakan rumah panggung kayu khas dari daerah...',
              opts: [
                'Sulawesi Utara',
                'Sulawesi Tengah',
                'Sulawesi Barat',
                'Sulawesi Tenggara',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Rumah adat yang memiliki nama unik "Bubungan Lima" merupakan rumah tradisional dari daerah...',
              opts: ['Riau', 'Bengkulu', 'Jambi', 'Sumatra Selatan'],
              correct: 1,
            ),
            _soal(
              q: 'Bahan utama yang digunakan untuk membuat dinding dan lantai rumah adat Honai di Papua adalah...',
              opts: [
                'Kayu dan jerami/ilalang',
                'Beton dan semen',
                'Kaca dan besi',
                'Batu bata merah',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Ciri utama dari rumah adat Melayu Selaso Jatuh Kembar di Riau adalah memiliki selasar yang...',
              opts: [
                'Lebih tinggi dari lantai rumah',
                'Berada di dalam kamar tidur',
                'Lebih rendah dari lantai rumah',
                'Berada di atas atap rumah',
              ],
              correct: 2,
            ),
            _soal(
              q: 'Rumah adat Kasepuhan merupakan bangunan keraton yang berasal dari daerah...',
              opts: ['Solo', 'Yogyakarta', 'Cirebon', 'Semarang'],
              correct: 2,
            ),
          ],
        ),
      );

      questions.addAll(
        _card(
          categoryId: rumahId,
          categoryName: 'Rumah Adat Nusantara',
          cardNumber: 5,
          difficulty: 'Mudah',
          soal: [
            _soal(
              q: 'Berdasarkan gambar di atas, rumah adat dari Jambi yang memiliki bentuk panggung memanjang dan sering disebut rumah "Lamo" adalah...',
              opts: [
                'Rumah Limas',
                'Rumah Selaso Jatuh Kembar',
                'Rumah Panggung Kajang Leko',
                'Rumah Krong Bade',
              ],
              correct: 2,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_21.jpeg',
            ),
            _soal(
              q: 'Gambar di atas menampilkan kraton/rumah adat resmi dari Cirebon, Jawa Barat. Apa nama rumah adat tersebut?',
              opts: [
                'Rumah Kasepuhan',
                'Rumah Kebaya',
                'Rumah Baduy',
                'Rumah Joglo',
              ],
              correct: 0,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_22.webp',
            ),
            _soal(
              q: 'Perhatikan gambar rumah adat Nusa Tenggara Timur (NTT) yang menjadi tempat tinggal kepala suku dan berbentuk bulat telur beratap jerami berikut. Apa namanya?',
              opts: [
                'Rumah Musalaki',
                'Rumah Mbaru Niang',
                'Rumah Honai',
                'Rumah Sasak',
              ],
              correct: 0,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_23.webp',
            ),
            _soal(
              q: 'Gambar di atas menunjukkan rumah adat berbahan kayu hitam besar dari Sulawesi Tengah yang dihuni oleh bangsawan atau raja setempat. Nama rumah adat ini adalah...',
              opts: [
                'Rumah Boyang',
                'Rumah Walewangko',
                'Rumah Tongkonan',
                'Rumah Souraja',
              ],
              correct: 3,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_24.jpeg',
            ),
            _soal(
              q: 'Berdasarkan gambar di atas, rumah adat dari Provinsi Lampung yang berbentuk panggung dengan hiasan siger di bagian depannya dinamakan...',
              opts: [
                'Rumah Nowou Sesat',
                'Rumah Limas',
                'Rumah Bubungan Lima',
                'Rumah Krong Bade',
              ],
              correct: 0,
              imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_25.webp',
            ),
            _soal(
              q: 'Rumah adat Boyang merupakan rumah panggung kayu tradisional yang berasal dari suku Mandar di provinsi...',
              opts: [
                'Sulawesi Selatan',
                'Sulawesi Barat',
                'Gorontalo',
                'Sulawesi Tengah',
              ],
              correct: 1,
            ),
            _soal(
              q: 'Rumah adat Musalaki yang digunakan sebagai tempat tinggal kepala suku atau makam para leluhur berasal dari provinsi...',
              opts: [
                'Nusa Tenggara Timur',
                'Nusa Tenggara Barat',
                'Bali',
                'Maluku',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Di bawah ini, rumah adat yang memiliki fungsi utama sebagai tempat penyimpanan padi atau lumbung adalah...',
              opts: [
                'Rangkiang (di dekat Rumah Gadang)',
                'Honai',
                'Kasepuhan',
                'Limas',
              ],
              correct: 0,
            ),
            _soal(
              q: 'Rumah adat Kalimantan Selatan yang memiliki bubungan atap sangat tinggi dan lancip dinamakan Rumah...',
              opts: ['Lamin', 'Bubungan Tinggi', 'Betang', 'Pasang'],
              correct: 1,
            ),
            _soal(
              q: 'Mengapa rumah adat di pulau Sumatra dan Kalimantan umumnya berbentuk rumah panggung?',
              opts: [
                'Untuk menghindari banjir dan serangan hewan liar',
                'Agar rumah terlihat lebih megah dan mewah',
                'Karena kekurangan bahan material batu dan semen',
                'Mengikuti gaya arsitektur bangunan Eropa kuno',
              ],
              correct: 0,
            ),
          ],
        ),
      );
    }
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
    return soal
        .map(
          (s) => {
            ...s,
            'categoryId': categoryId,
            'categoryName': categoryName,
            'cardNumber': cardNumber,
            'difficulty': difficulty,
            'isActive': true,
            'imageUrl': s['imageUrl'],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'stats': {'timesAnswered': 0, 'timesWrong': 0, 'wrongRate': 0.0},
          },
        )
        .toList();
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
