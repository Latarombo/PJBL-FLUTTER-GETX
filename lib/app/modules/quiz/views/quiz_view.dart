import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:santarana/app/modules/quiz/controllers/quiz_controller.dart';
import 'package:santarana/shared/theme/app_colors.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (controller.questions.isEmpty) return const Scaffold(body: SizedBox());
      final question = controller.currentQuestion!;

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
          title: Text(
            controller.categoryName.value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'restart') controller.showRestartDialog();
                if (value == 'exit') Get.back();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'restart', child: Text('Ulang Quiz')),
                PopupMenuItem(value: 'exit', child: Text('Keluar')),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Text(
                      '${controller.currentQuestionIndex.value + 1} dari ${controller.totalQuestions}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value:
                              (controller.currentQuestionIndex.value + 1) /
                              controller.totalQuestions,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Soal + Pilihan (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Gambar (jika ada)
                      if (question.hasImage) ...[
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage(question.imageUrl!),
                              fit: BoxFit.cover,
                              onError: (e, s) {},
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Kartu Soal
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Pilihan Jawaban
                      ...List.generate(
                        question.options.length,
                        (index) => _buildOptionCard(index, question),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // Tombol Lanjut
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isAnswered.value
                        ? null
                        : controller.handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          controller.selectedAnswerIndex.value != null
                          ? AppColors.dark
                          : AppColors.disabled,
                      disabledBackgroundColor: AppColors.disabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Lanjut',
                      style: TextStyle(
                        color:
                            controller.selectedAnswerIndex.value != null &&
                                !controller.isAnswered.value
                            ? Colors.white
                            : AppColors.onDisabled,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOptionCard(int index, question) {
    final isSelected = controller.selectedAnswerIndex.value == index;
    final isAnswered = controller.isAnswered.value;
    final isCorrect = isAnswered && index == question.correctIndex;
    final isWrong =
        isAnswered &&
        controller.selectedAnswerIndex.value == index &&
        index != question.correctIndex;

    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE0E0E0);
    Color textColor = AppColors.textPrimary;
    IconData? icon;

    if (isAnswered) {
      if (isCorrect) {
        bgColor = Colors.green;
        borderColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check_circle;
      } else if (isWrong) {
        bgColor = Colors.red;
        borderColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      bgColor = const Color(0xFFE3F2FD);
      borderColor = const Color(0xFF2196F3);
    }

    return GestureDetector(
      onTap: isAnswered ? null : () => controller.selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question.options[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (icon != null) Icon(icon, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
