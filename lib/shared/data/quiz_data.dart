import 'package:santarana/shared/data/quiz_model.dart';

/// QuizData - Data Provider untuk Quiz
/// Mengikuti prinsip Parameterized
/// Support MIX soal dengan gambar dan tanpa gambar
class QuizData {
  /// Get quiz berdasarkan kategori
  static QuizSession getQuizByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'tarian tradisional':
        return _getTariQuiz();
      case 'pakaian adat nusantara':
        return _getPakaianAdatQuiz();
      case 'rumah adat nusantara':
        return _getRumahAdatQuiz();
      case 'musik tradisional nusantara':
        return _getMusikNusantaraQuiz();
      case 'senjata tradisional':
        return _getSenjataTradisionalQuiz();
      case 'makanan nusantara':
        return _getMakananTradisionalQuiz();
      default:
        return _getTariQuiz();
    }
  }

  /// Quiz Tari Tradisional - MIX soal dengan & tanpa gambar/// Quiz Tari Tradisional - MIX soal dengan & tanpa gambar
  static QuizSession _getTariQuiz() {
    return QuizSession(
      id: 'tari_001',
      title: 'Tarian Tradisional Nusantara',
      category: 'Tari Tradisional',
      totalQuestions: 15,
      imagePath: 'assets/quiz_category_images/tari_tradisional/',
      questions: [
        QuizQuestion(
          id: 'tari_q1',
          question: 'Tari Saman berasal dari daerah mana?',
          options: ['A. Aceh', 'B. Bali', 'C. Jawa Tengah', 'D. Papua'],
          correctAnswerIndex: 0,
          category: 'Tari Tradisional',
        ),

        QuizQuestion(
          id: 'tari_q2',
          question: 'Dari mana asal Tari Pendet?',
          options: [
            'A. Jawa Barat',
            'B. Bali',
            'C. Sumatera Barat',
            'D. Jawa Timur',
          ],
          correctAnswerIndex: 1,
          category: 'Tari Tradisional',
        ),

        QuizQuestion(
          id: 'tari_q3',
          question: 'Tarian pada gambar berasal dari daerah...',
          options: ['A. Sumatera Barat', 'B. Bali', 'C. Papua', 'D. Riau'],
          correctAnswerIndex: 0,
          category: 'Tari Tradisional',
          imageUrl:
              'assets/quiz_category_images/tari_tradisional/tari_piring.png',
        ),

        QuizQuestion(
          id: 'tari_q4',
          question: 'Properti utama yang digunakan dalam Tari Piring adalah...',
          options: ['A. Selendang', 'B. Piring', 'C. Payung', 'D. Tombak'],
          correctAnswerIndex: 1,
          category: 'Tari Tradisional',
        ),

        QuizQuestion(
          id: 'tari_q5',
          question: 'Tari Jaipong berasal dari provinsi...',
          options: [
            'A. Jawa Timur',
            'B. Jawa Barat',
            'C. Jawa Tengah',
            'D. Banten',
          ],
          correctAnswerIndex: 1,
          category: 'Tari Tradisional',
        ),

        QuizQuestion(
          id: 'tari_q6',
          question: 'Gerakan khas Tari Saman adalah...',
          options: [
            'A. Gerakan kaki cepat',
            'B. Tepuk tangan kompak',
            'C. Putaran badan',
            'D. Loncat tinggi',
          ],
          correctAnswerIndex: 1,
          category: 'Tari Tradisional',
        ),

        QuizQuestion(
          id: 'tari_q7',
          question: 'Tarian pada gambar dikenal dengan nama...',
          options: [
            'A. Tari Kecak',
            'B. Tari Pendet',
            'C. Tari Gambyong',
            'D. Tari Serimpi',
          ],
          correctAnswerIndex: 3,
          category: 'Tari Tradisional',
          imageUrl:
              'assets/quiz_category_images/tari_tradisional/tari_serimpi.png',
        ),

        QuizQuestion(
          id: 'tari_q8',
          question: 'Tari Kecak berasal dari daerah...',
          options: ['A. Bali', 'B. Aceh', 'C. Papua', 'D. Kalimantan'],
          correctAnswerIndex: 0,
          category: 'Tari Tradisional',
        ),

        QuizQuestion(
          id: 'tari_q9',
          question: 'Tari Serimpi berasal dari daerah...',
          options: ['A. Yogyakarta', 'B. Bali', 'C. Makassar', 'D. Lampung'],
          correctAnswerIndex: 0,
          category: 'Tari Tradisional',
        ),

        QuizQuestion(
          id: 'tari_q10',
          question:
              'Tarian pada gambar biasanya dibawakan oleh banyak penari pria yang duduk melingkar.',
          options: [
            'A. Tari Jaipong',
            'B. Tari Kecak',
            'C. Tari Piring',
            'D. Tari Topeng',
          ],
          correctAnswerIndex: 1,
          category: 'Tari Tradisional',
          imageUrl:
              'assets/quiz_category_images/tari_tradisional/tari_kecak.png',
        ),

        QuizQuestion(
          id: 'tari_q11',
          question: 'Tari Topeng berasal dari daerah...',
          options: ['A. Cirebon', 'B. Papua', 'C. Riau', 'D. Aceh'],
          correctAnswerIndex: 0,
          category: 'Tari Tradisional',
        ),

        QuizQuestion(
          id: 'tari_q12',
          question: 'Tari Gambyong berasal dari daerah...',
          options: [
            'A. Jawa Tengah',
            'B. Bali',
            'C. Kalimantan',
            'D. Sumatera Barat',
          ],
          correctAnswerIndex: 0,
          category: 'Tari Tradisional',
        ),

        QuizQuestion(
          id: 'tari_q13',
          question: 'Tarian pada gambar menggunakan properti payung.',
          options: [
            'A. Tari Payung',
            'B. Tari Piring',
            'C. Tari Jaipong',
            'D. Tari Serimpi',
          ],
          correctAnswerIndex: 0,
          category: 'Tari Tradisional',
          imageUrl:
              'assets/quiz_category_images/tari_tradisional/tari_payung.png',
        ),

        QuizQuestion(
          id: 'tari_q14',
          question: 'Tari Reog berasal dari daerah...',
          options: ['A. Ponorogo', 'B. Surabaya', 'C. Malang', 'D. Kediri'],
          correctAnswerIndex: 0,
          category: 'Tari Tradisional',
        ),

        QuizQuestion(
          id: 'tari_q15',
          question: 'Fungsi tari tradisional pada zaman dahulu adalah untuk...',
          options: [
            'A. Hiburan modern',
            'B. Upacara adat dan penyambutan',
            'C. Kompetisi olahraga',
            'D. Belajar di sekolah',
          ],
          correctAnswerIndex: 1,
          category: 'Tari Tradisional',
        ),
      ],
    );
  }

  /// Quiz Pakaian Adat
  static QuizSession _getPakaianAdatQuiz() {
    return QuizSession(
      id: 'pakaian_001',
      title: 'Pakaian Adat Nusantara',
      category: 'Pakaian Adat',
      totalQuestions: 15,
      imagePath: 'assets/quiz_category_images/pakaian_adat/',
      questions: [
        QuizQuestion(
          id: 'pakaian_q1',
          question: 'Pakaian adat pada gambar berasal dari daerah?',
          options: ['A. Jawa', 'B. Sumatera', 'C. Bali', 'D. Papua'],
          correctAnswerIndex: 0,
          category: 'Pakaian Adat',
          imageUrl:
              'assets/quiz_category_images/pakaian_adat/pakaian_adat_jawa.png',
        ),

        QuizQuestion(
          id: 'pakaian_q2',
          question: 'Ulos adalah pakaian adat dari?',
          options: [
            'A. Jawa Barat',
            'B. Sumatera Utara',
            'C. Sulawesi',
            'D. Kalimantan',
          ],
          correctAnswerIndex: 1,
          category: 'Pakaian Adat',
        ),

        QuizQuestion(
          id: 'pakaian_q3',
          question: 'Songket adalah kain tradisional dari?',
          options: ['A. Palembang', 'B. Jakarta', 'C. Bali', 'D. Makassar'],
          correctAnswerIndex: 0,
          category: 'Pakaian Adat',
        ),

        QuizQuestion(
          id: 'pakaian_q4',
          question: 'Nama pakaian adat pada gambar adalah?',
          options: ['A. Baju Bodo', 'B. Kebaya', 'C. Ulos', 'D. Koteka'],
          correctAnswerIndex: 1,
          category: 'Pakaian Adat',
          imageUrl: 'assets/quiz_category_images/pakaian_adat/kebaya.png',
        ),

        QuizQuestion(
          id: 'pakaian_q5',
          question: 'Baju Kurung berasal dari daerah?',
          options: ['A. Riau', 'B. Jawa Tengah', 'C. Bali', 'D. NTT'],
          correctAnswerIndex: 0,
          category: 'Pakaian Adat',
        ),

        QuizQuestion(
          id: 'pakaian_q6',
          question: 'Baju Bodo merupakan pakaian adat dari?',
          options: [
            'A. Sulawesi Selatan',
            'B. Papua',
            'C. Jawa Timur',
            'D. Sumatera Barat',
          ],
          correctAnswerIndex: 0,
          category: 'Pakaian Adat',
        ),

        QuizQuestion(
          id: 'pakaian_q7',
          question: 'Pakaian adat pada gambar berasal dari daerah?',
          options: ['A. Bali', 'B. Aceh', 'C. Kalimantan', 'D. Papua'],
          correctAnswerIndex: 3,
          category: 'Pakaian Adat',
          imageUrl:
              'assets/quiz_category_images/pakaian_adat/pakaian_adat_papua.png',
        ),

        QuizQuestion(
          id: 'pakaian_q8',
          question: 'Blangkon biasanya digunakan oleh masyarakat dari daerah?',
          options: ['A. Jawa', 'B. Sumatera', 'C. Sulawesi', 'D. Papua'],
          correctAnswerIndex: 0,
          category: 'Pakaian Adat',
        ),

        QuizQuestion(
          id: 'pakaian_q9',
          question: 'Pakaian adat Ulee Balang berasal dari daerah?',
          options: ['A. Aceh', 'B. Bali', 'C. Riau', 'D. Lampung'],
          correctAnswerIndex: 0,
          category: 'Pakaian Adat',
        ),

        QuizQuestion(
          id: 'pakaian_q10',
          question: 'Pakaian adat pada gambar dikenal dengan nama?',
          options: ['A. Ulos', 'B. Baju Bodo', 'C. Payas Agung', 'D. Beskap'],
          correctAnswerIndex: 2,
          category: 'Pakaian Adat',
          imageUrl: 'assets/quiz_category_images/pakaian_adat/payas_agung.png',
        ),

        QuizQuestion(
          id: 'pakaian_q11',
          question: 'Beskap biasanya dikenakan oleh pria dari daerah?',
          options: ['A. Jawa', 'B. Papua', 'C. Kalimantan', 'D. Bali'],
          correctAnswerIndex: 0,
          category: 'Pakaian Adat',
        ),

        QuizQuestion(
          id: 'pakaian_q12',
          question: 'Pakaian adat khas suku Dayak berasal dari?',
          options: ['A. Sumatera', 'B. Kalimantan', 'C. Bali', 'D. Jawa'],
          correctAnswerIndex: 1,
          category: 'Pakaian Adat',
        ),

        QuizQuestion(
          id: 'pakaian_q13',
          question: 'Pakaian adat pada gambar berasal dari provinsi?',
          options: ['A. Sumatera Barat', 'B. Jawa Barat', 'C. Bali', 'D. NTB'],
          correctAnswerIndex: 0,
          category: 'Pakaian Adat',
          imageUrl:
              'assets/quiz_category_images/pakaian_adat/bundo_kanduang.png',
        ),

        QuizQuestion(
          id: 'pakaian_q14',
          question: 'Mahkota khas pakaian adat Minangkabau disebut?',
          options: ['A. Blangkon', 'B. Suntiang', 'C. Udeng', 'D. Songkok'],
          correctAnswerIndex: 1,
          category: 'Pakaian Adat',
        ),

        QuizQuestion(
          id: 'pakaian_q15',
          question: 'Fungsi pakaian adat pada zaman dahulu adalah untuk?',
          options: [
            'A. Sekadar hiasan',
            'B. Upacara adat dan identitas daerah',
            'C. Seragam sekolah',
            'D. Olahraga',
          ],
          correctAnswerIndex: 1,
          category: 'Pakaian Adat',
        ),
      ],
    );
  }

  /// Quiz Rumah Adat
  static QuizSession _getRumahAdatQuiz() {
    return QuizSession(
      id: 'rumah_001',
      title: 'Rumah Adat Nusantara',
      category: 'Rumah Adat',
      totalQuestions: 15,
      imagePath: 'assets/quiz_category_images/rumah_adat/',
      questions: [
        QuizQuestion(
          id: 'rumah_q1',
          question: 'Rumah adat Tongkonan berasal dari daerah mana?',
          options: [
            'A. Sumatera Barat',
            'B. Sulawesi Selatan',
            'C. Kalimantan Timur',
            'D. Bali',
          ],
          correctAnswerIndex: 1,
          category: 'Rumah Adat',
        ),

        QuizQuestion(
          id: 'rumah_q2',
          question: 'Rumah adat pada gambar di atas berasal dari provinsi...',
          options: ['A. Sumatera Barat', 'B. Aceh', 'C. Riau', 'D. Lampung'],
          correctAnswerIndex: 0,
          category: 'Rumah Adat',
          imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_gadang.png',
        ),

        QuizQuestion(
          id: 'rumah_q3',
          question: 'Rumah adat Joglo berasal dari daerah...',
          options: [
            'A. Jawa Tengah',
            'B. Papua',
            'C. Sulawesi Utara',
            'D. Maluku',
          ],
          correctAnswerIndex: 0,
          category: 'Rumah Adat',
        ),

        QuizQuestion(
          id: 'rumah_q4',
          question:
              'Ciri khas rumah adat pada gambar adalah atapnya berbentuk...',
          options: ['A. Perahu terbalik', 'B. Gunung', 'C. Limas', 'D. Kubah'],
          correctAnswerIndex: 0,
          category: 'Rumah Adat',
          imageUrl:
              'assets/quiz_category_images/rumah_adat/rumah_tongkonan.png',
        ),

        QuizQuestion(
          id: 'rumah_q5',
          question: 'Rumah adat Honai berasal dari daerah...',
          options: [
            'A. Nusa Tenggara Timur',
            'B. Papua',
            'C. Kalimantan Barat',
            'D. Bengkulu',
          ],
          correctAnswerIndex: 1,
          category: 'Rumah Adat',
        ),

        QuizQuestion(
          id: 'rumah_q6',
          question:
              'Rumah adat yang memiliki atap melengkung seperti tanduk kerbau adalah...',
          options: ['A. Joglo', 'B. Gadang', 'C. Honai', 'D. Lamin'],
          correctAnswerIndex: 1,
          category: 'Rumah Adat',
        ),

        QuizQuestion(
          id: 'rumah_q7',
          question: 'Rumah adat pada gambar biasanya dihuni oleh suku...',
          options: [
            'A. Suku Dayak',
            'B. Suku Minang',
            'C. Suku Dani',
            'D. Suku Baduy',
          ],
          correctAnswerIndex: 2,
          category: 'Rumah Adat',
          imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_honai.png',
        ),

        QuizQuestion(
          id: 'rumah_q8',
          question: 'Rumah adat Lamin berasal dari daerah...',
          options: [
            'A. Kalimantan Timur',
            'B. Jawa Barat',
            'C. Sumatera Utara',
            'D. Bali',
          ],
          correctAnswerIndex: 0,
          category: 'Rumah Adat',
        ),

        QuizQuestion(
          id: 'rumah_q9',
          question: 'Rumah adat Krong Bade berasal dari daerah...',
          options: ['A. Aceh', 'B. Riau', 'C. Jambi', 'D. Banten'],
          correctAnswerIndex: 0,
          category: 'Rumah Adat',
        ),

        QuizQuestion(
          id: 'rumah_q10',
          question: 'Rumah adat pada gambar memiliki ciri utama yaitu...',
          options: [
            'A. Atap bertingkat dan tinggi di tengah',
            'B. Atap bulat kecil',
            'C. Terbuat dari batu',
            'D. Tidak memiliki tiang',
          ],
          correctAnswerIndex: 0,
          category: 'Rumah Adat',
          imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_joglo.png',
        ),

        QuizQuestion(
          id: 'rumah_q11',
          question: 'Rumah adat Baileo berasal dari daerah...',
          options: [
            'A. Maluku',
            'B. Bali',
            'C. Kalimantan Selatan',
            'D. Sumatera Barat',
          ],
          correctAnswerIndex: 0,
          category: 'Rumah Adat',
        ),

        QuizQuestion(
          id: 'rumah_q12',
          question:
              'Rumah adat yang berbentuk panggung dan banyak ditemukan di daerah rawa adalah...',
          options: ['A. Honai', 'B. Rumah Panggung', 'C. Joglo', 'D. Baileo'],
          correctAnswerIndex: 1,
          category: 'Rumah Adat',
        ),

        QuizQuestion(
          id: 'rumah_q13',
          question:
              'Rumah adat pada gambar terkenal dengan ukiran khas suku...',
          options: ['A. Dayak', 'B. Batak', 'C. Bugis', 'D. Betawi'],
          correctAnswerIndex: 0,
          category: 'Rumah Adat',
          imageUrl: 'assets/quiz_category_images/rumah_adat/rumah_lamin.png',
        ),

        QuizQuestion(
          id: 'rumah_q14',
          question: 'Rumah adat Selaso Jatuh Kembar berasal dari daerah...',
          options: ['A. Riau', 'B. Lampung', 'C. Papua', 'D. Sulawesi Barat'],
          correctAnswerIndex: 0,
          category: 'Rumah Adat',
        ),

        QuizQuestion(
          id: 'rumah_q15',
          question:
              'Fungsi utama rumah adat pada zaman dahulu adalah sebagai...',
          options: [
            'A. Tempat wisata',
            'B. Tempat tinggal dan kegiatan adat',
            'C. Tempat belanja',
            'D. Sekolah',
          ],
          correctAnswerIndex: 1,
          category: 'Rumah Adat',
        ),
      ],
    );
  }

  /// Quiz Musik Nusantara
  static QuizSession _getMusikNusantaraQuiz() {
    return QuizSession(
      id: 'musik_001',
      title: 'Musik Tradisional Nusantara',
      category: 'Musik Tradisional Nusantara',
      totalQuestions: 15,
      imagePath: 'assets/quiz_category_images/musik_nusantara/',
      questions: [
        QuizQuestion(
          id: 'musik_q1',
          question: 'Angklung berasal dari daerah?',
          options: ['A. Jawa Timur', 'B. Jawa Barat', 'C. Bali', 'D. Sumatera'],
          correctAnswerIndex: 1,
          category: 'Musik Nusantara',
        ),

        QuizQuestion(
          id: 'musik_q2',
          question: 'Alat musik pada gambar bernama?',
          options: ['A. Gamelan', 'B. Angklung', 'C. Sasando', 'D. Kolintang'],
          correctAnswerIndex: 2,
          category: 'Musik Nusantara',
          imageUrl: 'assets/quiz_category_images/musik_nusantara/sasando.png',
        ),

        QuizQuestion(
          id: 'musik_q3',
          question: 'Kolintang berasal dari daerah?',
          options: ['A. Sulawesi Utara', 'B. Bali', 'C. Aceh', 'D. Papua'],
          correctAnswerIndex: 0,
          category: 'Musik Nusantara',
        ),

        QuizQuestion(
          id: 'musik_q4',
          question: 'Alat musik tradisional dari Papua adalah?',
          options: ['A. Tifa', 'B. Angklung', 'C. Gamelan', 'D. Rebab'],
          correctAnswerIndex: 0,
          category: 'Musik Nusantara',
        ),

        QuizQuestion(
          id: 'musik_q5',
          question:
              'Gamelan banyak digunakan dalam pertunjukan seni dari daerah?',
          options: [
            'A. Jawa dan Bali',
            'B. Sumatera',
            'C. Kalimantan',
            'D. Papua',
          ],
          correctAnswerIndex: 0,
          category: 'Musik Nusantara',
        ),

        QuizQuestion(
          id: 'musik_q6',
          question:
              'Alat musik pada gambar dimainkan dengan cara digoyang menggunakan tangan.',
          options: ['A. Kolintang', 'B. Sasando', 'C. Tifa', 'D. Angklung'],
          correctAnswerIndex: 3,
          category: 'Musik Nusantara',
          imageUrl: 'assets/quiz_category_images/musik_nusantara/angklung.png',
        ),

        QuizQuestion(
          id: 'musik_q7',
          question:
              'Tifa biasanya digunakan untuk mengiringi tarian dari daerah?',
          options: ['A. Papua', 'B. Jawa Barat', 'C. Bali', 'D. Riau'],
          correctAnswerIndex: 0,
          category: 'Musik Nusantara',
        ),

        QuizQuestion(
          id: 'musik_q8',
          question:
              'Alat musik pada gambar dimainkan dengan cara digesekkan menggunakan busur.',
          options: ['A. Sasando', 'B. Angklung', 'C. Rebab', 'D. Tifa'],
          correctAnswerIndex: 2,
          category: 'Musik Nusantara',
          imageUrl: 'assets/quiz_category_images/musik_nusantara/rebab.png',
        ),

        QuizQuestion(
          id: 'musik_q9',
          question: 'Kendang adalah alat musik yang dimainkan dengan cara?',
          options: ['A. Dipukul', 'B. Dipetik', 'C. Digesek', 'D. Ditiup'],
          correctAnswerIndex: 0,
          category: 'Musik Nusantara',
        ),

        QuizQuestion(
          id: 'musik_q10',
          question: 'Sasando berasal dari provinsi?',
          options: [
            'A. Nusa Tenggara Timur',
            'B. Bali',
            'C. Jawa Tengah',
            'D. Aceh',
          ],
          correctAnswerIndex: 0,
          category: 'Musik Nusantara',
        ),

        QuizQuestion(
          id: 'musik_q11',
          question: 'Alat musik Kolintang dimainkan dengan cara?',
          options: ['A. Dipetik', 'B. Dipukul', 'C. Ditiup', 'D. Digesek'],
          correctAnswerIndex: 1,
          category: 'Musik Nusantara',
        ),

        QuizQuestion(
          id: 'musik_q12',
          question: 'Seruling termasuk alat musik yang dimainkan dengan cara?',
          options: ['A. Dipetik', 'B. Ditiup', 'C. Dipukul', 'D. Digesek'],
          correctAnswerIndex: 1,
          category: 'Musik Nusantara',
        ),

        QuizQuestion(
          id: 'musik_q13',
          question: 'Alat musik pada gambar bernama?',
          options: ['A. Tifa', 'B. Kolintang', 'C. Rebab', 'D. Angklung'],
          correctAnswerIndex: 0,
          category: 'Musik Nusantara',
          imageUrl: 'assets/quiz_category_images/musik_nusantara/tifa.png',
        ),

        QuizQuestion(
          id: 'musik_q14',
          question: 'Gamelan biasanya dimainkan secara?',
          options: [
            'A. Sendiri',
            'B. Berkelompok',
            'C. Berdua',
            'D. Solo gitar',
          ],
          correctAnswerIndex: 1,
          category: 'Musik Nusantara',
        ),

        QuizQuestion(
          id: 'musik_q15',
          question: 'Fungsi musik tradisional pada zaman dahulu adalah untuk?',
          options: [
            'A. Upacara adat dan hiburan',
            'B. Bermain game',
            'C. Belajar matematika',
            'D. Olahraga',
          ],
          correctAnswerIndex: 0,
          category: 'Musik Nusantara',
        ),
      ],
    );
  }

  /// Quiz Senjata Tradisional
  static QuizSession _getSenjataTradisionalQuiz() {
    return QuizSession(
      id: 'senjata_001',
      title: 'Senjata Tradisional',
      category: 'Senjata Tradisional',
      totalQuestions: 15,
      imagePath: 'assets/quiz_category_images/senjata_tradisional/',
      questions: [
        QuizQuestion(
          id: 'senjata_q1',
          question: 'Keris merupakan senjata tradisional dari daerah?',
          options: ['A. Jawa', 'B. Papua', 'C. Bali', 'D. Kalimantan'],
          correctAnswerIndex: 0,
          category: 'Senjata Tradisional',
        ),

        QuizQuestion(
          id: 'senjata_q2',
          question: 'Senjata pada gambar bernama?',
          options: ['A. Mandau', 'B. Rencong', 'C. Keris', 'D. Badik'],
          correctAnswerIndex: 2,
          category: 'Senjata Tradisional',
          imageUrl: 'assets/quiz_category_images/senjata_tradisional/keris.png',
        ),

        QuizQuestion(
          id: 'senjata_q3',
          question: 'Mandau berasal dari daerah?',
          options: ['A. Sumatera', 'B. Kalimantan', 'C. Jawa', 'D. Bali'],
          correctAnswerIndex: 1,
          category: 'Senjata Tradisional',
        ),

        QuizQuestion(
          id: 'senjata_q4',
          question: 'Rencong adalah senjata khas dari?',
          options: ['A. Aceh', 'B. Bali', 'C. Riau', 'D. Lampung'],
          correctAnswerIndex: 0,
          category: 'Senjata Tradisional',
        ),

        QuizQuestion(
          id: 'senjata_q5',
          question: 'Senjata pada gambar berasal dari suku Dayak.',
          options: ['A. Keris', 'B. Mandau', 'C. Rencong', 'D. Kujang'],
          correctAnswerIndex: 1,
          category: 'Senjata Tradisional',
          imageUrl:
              'assets/quiz_category_images/senjata_tradisional/mandau.png',
        ),

        QuizQuestion(
          id: 'senjata_q6',
          question: 'Kujang merupakan senjata tradisional dari daerah?',
          options: ['A. Jawa Barat', 'B. Jawa Timur', 'C. Bali', 'D. Sumatera'],
          correctAnswerIndex: 0,
          category: 'Senjata Tradisional',
        ),

        QuizQuestion(
          id: 'senjata_q7',
          question: 'Badik berasal dari daerah?',
          options: [
            'A. Sulawesi Selatan',
            'B. Jawa Tengah',
            'C. Papua',
            'D. Kalimantan',
          ],
          correctAnswerIndex: 0,
          category: 'Senjata Tradisional',
        ),

        QuizQuestion(
          id: 'senjata_q8',
          question: 'Senjata pada gambar bernama?',
          options: ['A. Rencong', 'B. Kujang', 'C. Badik', 'D. Mandau'],
          correctAnswerIndex: 0,
          category: 'Senjata Tradisional',
          imageUrl:
              'assets/quiz_category_images/senjata_tradisional/rencong.png',
        ),

        QuizQuestion(
          id: 'senjata_q9',
          question:
              'Fungsi utama senjata tradisional pada zaman dahulu adalah untuk?',
          options: [
            'A. Upacara adat dan pertahanan diri',
            'B. Hiasan rumah',
            'C. Mainan anak-anak',
            'D. Alat tulis',
          ],
          correctAnswerIndex: 0,
          category: 'Senjata Tradisional',
        ),

        QuizQuestion(
          id: 'senjata_q10',
          question: 'Senjata pada gambar berasal dari Jawa Barat.',
          options: ['A. Kujang', 'B. Mandau', 'C. Keris', 'D. Rencong'],
          correctAnswerIndex: 0,
          category: 'Senjata Tradisional',
          imageUrl:
              'assets/quiz_category_images/senjata_tradisional/kujang.png',
        ),

        QuizQuestion(
          id: 'senjata_q11',
          question: 'Golok biasanya digunakan oleh masyarakat dari daerah?',
          options: ['A. Betawi', 'B. Papua', 'C. Bali', 'D. Aceh'],
          correctAnswerIndex: 0,
          category: 'Senjata Tradisional',
        ),

        QuizQuestion(
          id: 'senjata_q12',
          question: 'Clurit merupakan senjata tradisional dari daerah?',
          options: ['A. Madura', 'B. Bali', 'C. Riau', 'D. Kalimantan'],
          correctAnswerIndex: 0,
          category: 'Senjata Tradisional',
        ),

        QuizQuestion(
          id: 'senjata_q13',
          question:
              'Senjata pada gambar memiliki bentuk melengkung-lengkung yang khas.',
          options: ['A. Kujang', 'B. Rencong', 'C. Keris', 'D. Badik'],
          correctAnswerIndex: 2,
          category: 'Senjata Tradisional',
          imageUrl:
              'assets/quiz_category_images/senjata_tradisional/keris2.png',
        ),

        QuizQuestion(
          id: 'senjata_q14',
          question: 'Mandau dihiasi dengan ukiran khas suku?',
          options: ['A. Dayak', 'B. Minang', 'C. Bugis', 'D. Betawi'],
          correctAnswerIndex: 0,
          category: 'Senjata Tradisional',
        ),

        QuizQuestion(
          id: 'senjata_q15',
          question:
              'Selain sebagai alat pertahanan, senjata tradisional juga digunakan sebagai?',
          options: [
            'A. Simbol budaya dan adat',
            'B. Alat olahraga',
            'C. Mainan',
            'D. Alat memasak',
          ],
          correctAnswerIndex: 0,
          category: 'Senjata Tradisional',
        ),
      ],
    );
  }

  /// Quiz Makanan Tradisional
  static QuizSession _getMakananTradisionalQuiz() {
    return QuizSession(
      id: 'makanan_001',
      title: 'Makanan Nusantara',
      category: 'Makanan Tradisional',
      totalQuestions: 15,
      imagePath: 'assets/quiz_category_images/makanan_tradisional/',
      questions: [
        QuizQuestion(
          id: 'makanan_q1',
          question:
              'Rendang adalah makanan khas Indonesia yang terkenal hingga mancanegara. Rendang berasal dari daerah mana?',
          options: [
            'A. Sumatera Barat',
            'B. Jawa Tengah',
            'C. Bali',
            'D. Kalimantan',
          ],
          correctAnswerIndex: 0,
          category: 'Makanan Tradisional',
        ),

        QuizQuestion(
          id: 'makanan_q2',
          question:
              'Perhatikan gambar berikut. Makanan berbahan dasar ikan dan disajikan dengan kuah cuko ini bernama apa?',
          options: ['A. Otak-otak', 'B. Pempek', 'C. Tekwan', 'D. Siomay'],
          correctAnswerIndex: 1,
          category: 'Makanan Tradisional',
          imageUrl:
              'assets/quiz_category_images/makanan_tradisional/pempek.png',
        ),

        QuizQuestion(
          id: 'makanan_q3',
          question:
              'Gudeg dikenal sebagai makanan manis berbahan dasar nangka muda. Gudeg berasal dari daerah mana?',
          options: ['A. Bandung', 'B. Yogyakarta', 'C. Surabaya', 'D. Medan'],
          correctAnswerIndex: 1,
          category: 'Makanan Tradisional',
        ),

        QuizQuestion(
          id: 'makanan_q4',
          question:
              'Rawon adalah makanan berkuah hitam yang menggunakan kluwek sebagai bumbu utama. Rawon berasal dari daerah mana?',
          options: ['A. Jawa Timur', 'B. Bali', 'C. Aceh', 'D. Riau'],
          correctAnswerIndex: 0,
          category: 'Makanan Tradisional',
        ),

        QuizQuestion(
          id: 'makanan_q5',
          question:
              'Papeda adalah makanan berbahan dasar sagu dengan tekstur lengket. Papeda berasal dari daerah mana?',
          options: [
            'A. Papua',
            'B. Jawa Barat',
            'C. Sumatera Selatan',
            'D. NTB',
          ],
          correctAnswerIndex: 0,
          category: 'Makanan Tradisional',
        ),

        QuizQuestion(
          id: 'makanan_q6',
          question:
              'Perhatikan gambar berikut. Makanan khas dengan kuah santan kental dan daging sapi ini disebut apa?',
          options: ['A. Gulai', 'B. Rendang', 'C. Semur', 'D. Soto'],
          correctAnswerIndex: 1,
          category: 'Makanan Tradisional',
          imageUrl:
              'assets/quiz_category_images/makanan_tradisional/rendang.png',
        ),

        QuizQuestion(
          id: 'makanan_q7',
          question:
              'Sate Madura terkenal dengan bumbu kacangnya yang khas. Sate Madura berasal dari daerah mana?',
          options: [
            'A. Jawa Tengah',
            'B. Jawa Timur',
            'C. Bali',
            'D. Sumatera Barat',
          ],
          correctAnswerIndex: 1,
          category: 'Makanan Tradisional',
        ),

        QuizQuestion(
          id: 'makanan_q8',
          question:
              'Kerak Telor adalah makanan tradisional yang sering dijumpai saat festival budaya Betawi. Kerak Telor berasal dari daerah mana?',
          options: ['A. Jakarta', 'B. Bandung', 'C. Makassar', 'D. Palembang'],
          correctAnswerIndex: 0,
          category: 'Makanan Tradisional',
        ),

        QuizQuestion(
          id: 'makanan_q9',
          question:
              'Perhatikan gambar berikut. Makanan khas berbahan dasar sagu yang lengket ini bernama apa?',
          options: ['A. Lontong', 'B. Papeda', 'C. Lemper', 'D. Ketupat'],
          correctAnswerIndex: 1,
          category: 'Makanan Tradisional',
          imageUrl:
              'assets/quiz_category_images/makanan_tradisional/papeda.png',
        ),

        QuizQuestion(
          id: 'makanan_q10',
          question:
              'Soto Betawi memiliki kuah santan atau susu yang gurih. Soto Betawi berasal dari daerah mana?',
          options: ['A. Surabaya', 'B. Jakarta', 'C. Padang', 'D. Bali'],
          correctAnswerIndex: 1,
          category: 'Makanan Tradisional',
        ),

        QuizQuestion(
          id: 'makanan_q11',
          question:
              'Ayam Taliwang terkenal dengan cita rasa pedas dan gurih. Ayam Taliwang berasal dari daerah mana?',
          options: ['A. NTB', 'B. Aceh', 'C. Sumatera Barat', 'D. Jawa Barat'],
          correctAnswerIndex: 0,
          category: 'Makanan Tradisional',
        ),

        QuizQuestion(
          id: 'makanan_q12',
          question:
              'Perhatikan gambar berikut. Makanan manis khas Yogyakarta berbahan dasar nangka muda ini disebut apa?',
          options: ['A. Kolak', 'B. Gudeg', 'C. Dodol', 'D. Wajik'],
          correctAnswerIndex: 1,
          category: 'Makanan Tradisional',
          imageUrl: 'assets/quiz_category_images/makanan_tradisional/gudeg.png',
        ),

        QuizQuestion(
          id: 'makanan_q13',
          question: 'Pempek merupakan makanan khas dari daerah mana?',
          options: ['A. Palembang', 'B. Makassar', 'C. Bali', 'D. Bandung'],
          correctAnswerIndex: 0,
          category: 'Makanan Tradisional',
        ),

        QuizQuestion(
          id: 'makanan_q14',
          question:
              'Mie Aceh adalah makanan khas dengan cita rasa pedas dan kaya rempah. Mie Aceh berasal dari daerah mana?',
          options: ['A. Sumatera Barat', 'B. Aceh', 'C. Riau', 'D. Medan'],
          correctAnswerIndex: 1,
          category: 'Makanan Tradisional',
        ),

        QuizQuestion(
          id: 'makanan_q15',
          question:
              'Makanan tradisional Indonesia biasanya diwariskan dari generasi ke generasi sebagai bagian dari budaya. Secara umum, makanan tradisional diwariskan secara apa?',
          options: ['A. Turun-temurun', 'B. Acak', 'C. Modern', 'D. Digital'],
          correctAnswerIndex: 0,
          category: 'Makanan Tradisional',
        ),
      ],
    );
  }

  static List<String> getAvailableCategories() {
    return [
      'Tari Tradisional',
      'Pakaian Adat Nusantara',
      'Rumah Adat Nusantara',
      'Musik Tradisional Nusantara',
      'Senjata Tradisional'
          'Makanan Nusantara',
    ];
  }
}
