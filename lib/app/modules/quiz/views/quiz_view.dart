import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:santarana/app/modules/quiz/controllers/quiz_controller.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final question = controller.currentQuestion;
      return Scaffold(
        appBar: AppBar(
          title: Text(controller.quizSession.category),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'restart') controller.showRestartDialog();
                if (value == 'exit') Get.back();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'restart',
                  child: Text('Ulang Quiz'),
                ),
                const PopupMenuItem(value: 'exit', child: Text('Keluar')),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Text(
                      '${controller.currentQuestionIndex.value + 1} dari ${controller.quizSession.totalQuestions}',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value:
                            (controller.currentQuestionIndex.value + 1) /
                            controller.quizSession.totalQuestions,
                      ),
                    ),
                  ],
                ),
              ),

              // Soal, gambar, options (sama seperti repo lama)
              // ...

              // Tombol Lanjut
              ElevatedButton(
                onPressed: controller.isAnswered.value
                    ? null
                    : controller.handleNext,
                child: const Text('Lanjut'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
