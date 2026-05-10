import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../results/results_screen.dart';

class SymptomsScreen extends StatefulWidget {
  const SymptomsScreen({super.key});

  @override
  State<SymptomsScreen> createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends State<SymptomsScreen> {
  final List<Map<String, dynamic>> _questions = [
    {'title': 'Palpitations', 'title_ar': 'الخفقان', 'question_en': 'Do you feel rapid, fluttering, or pounding heartbeats?', 'question_ar': 'هل تشعر بضربات قلب سريعة، أو رفرفة، أو دقات قوية؟', 'answer': null},
    {'title': 'Tachycardia or Bradycardia', 'title_ar': 'تسرع أو بطء القلب', 'question_en': 'Has a doctor told you that you have an abnormally fast or slow heart rate?', 'question_ar': 'هل أخبرك طبيب أن معدل ضربات قلبك سريع أو بطيء بشكل غير طبيعي؟', 'answer': null},
    {'title': 'Syncope', 'title_ar': 'الإغماء', 'question_en': 'Have you experienced sudden fainting or temporary loss of consciousness?', 'question_ar': 'هل عانيت من إغماء مفاجئ أو فقدان مؤقت للوعي؟', 'answer': null},
    {'title': 'Dizziness or Lightheadedness', 'title_ar': 'الدوخة أو الدوار', 'question_en': 'Do you frequently feel dizzy, lightheaded, or off-balance?', 'question_ar': 'هل تشعر بالدوار أو الدوخة أو عدم التوازن بشكل متكرر؟', 'answer': null},
    {'title': 'Severe Anxiety', 'title_ar': 'القلق الشديد', 'question_en': 'Do you experience severe anxiety, panic, or a feeling of doom?', 'question_ar': 'هل تعاني من قلق شديد أو نوبات هلع أو شعور بالخطر؟', 'answer': null},
    {'title': 'Angina', 'title_ar': 'الذبحة الصدرية', 'question_en': 'Do you feel squeezing, pressure, or heaviness in your chest (chest pain)?', 'question_ar': 'هل تشعر بضغط أو عصر أو ثقل في صدرك (ألم في الصدر)؟', 'answer': null},
    {'title': 'Radiating Pain', 'title_ar': 'ألم يمتد', 'question_en': 'Does your chest pain spread to your jaw, neck, back, or left arm?', 'question_ar': 'هل يمتد ألم صدرك إلى الفك، الرقبة، الظهر، أو الذراع الأيسر؟', 'answer': null},
    {'title': 'Orthopnea', 'title_ar': 'ضيق التنفس الاستلقائي', 'question_en': 'Do you find it hard to breathe when lying flat on your back?', 'question_ar': 'هل تجد صعوبة في التنفس عند الاستلقاء على ظهرك؟', 'answer': null},
    {'title': 'PPeripheral Edema', 'title_ar': 'وذمة محيطية (تورم)', 'question_en': 'Have you noticed swelling in your feet, ankles, or legs?', 'question_ar': 'هل لاحظت تورم في قدميك أو كاحليك أو ساقيك؟', 'answer': null},
    {'title': 'Rapid Weight GainPain', 'title_ar': 'زيادة سريعة في الوزن', 'question_en': 'Have you gained weight rapidly over the last few days (due to fluid retention)?', 'question_ar': 'هل زاد وزنك بسرعة خلال الأيام القليلة الماضية (بسبب احتباس السوائل)؟', 'answer': null},
    {'title': 'Chest Discomfort', 'title_ar': 'انزعاج في الصدر', 'question_en': 'Do you feel general discomfort, tightness, or burning in your chest?', 'question_ar': 'هل تشعر بانزعاج عام، أو ضيق، أو حرقة في صدرك؟', 'answer': null},
    {'title': 'Persistent Cough', 'title_ar': 'سعال مستمر', 'question_en': 'Do you have a persistent cough that doesn\'t seem to go away?', 'question_ar': 'هل تعاني من سعال مستمر لا يبدو أنه سيزول؟', 'answer': null},
    {'title': 'Dyspnea on exertionUrination', 'title_ar': 'ضيق تنفس عند المجهود', 'question_en': 'Do you get short of breath with simple physical effort or daily activities?', 'question_ar': 'هل تشعر بضيق في التنفس مع مجهود بدني بسيط أو أثناء الأنشطة اليومية؟', 'answer': null},
    {'title': 'Paroxysmal Nocturnal Dyspnea', 'title_ar': 'ضيق تنفس ليلي انتيابي', 'question_en': 'Do you suddenly wake up from sleep gasping for air or struggling to breathe?', 'question_ar': 'هل تستيقظ فجأة من النوم تلهث أو تكافح لالتقاط أنفاسك؟', 'answer': null},
    {'title': 'Chronic FatiguePain', 'title_ar': 'تعب مزمن', 'question_en': 'Do you suffer from persistent, unexplained tiredness and extreme fatigue?', 'question_ar': 'هل تعاني من إرهاق مستمر غير مبرر وتعب شديد؟', 'answer': null},
    {'title': 'Nausea or Vomiting', 'title_ar': 'غثيان أو قيء', 'question_en': 'Have you felt nauseous or felt the urge to vomit recently?', 'question_ar': 'هل شعرت بغثيان أو رغبة في القيء مؤخراً؟', 'answer': null},
    {'title': 'DiaphoresisDifficulty', 'title_ar': 'تعرق شديد', 'question_en': 'Do you experience sudden, heavy, cold sweating without a clear reason?', 'question_ar': 'هل تعاني من تعرق بارد وشديد ومفاجئ دون سبب واضح؟', 'answer': null},
  ];

  bool _isAnalyzing = false;

  Future<void> _submitSymptoms(bool isArabic) async {
    bool allAnswered = _questions.every((q) => q['answer'] != null);
    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? 'يرجى الإجابة على جميع الأسئلة.' : 'Please answer all questions.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // Map symptoms to the format expected by FastAPI
      // 0=Angina, 1=HF, 2=Arr
      Map<String, int> inputs = {};
      for (var q in _questions) {
        inputs[q['title']] = q['answer'] == true ? 1 : 0;
      }

      // TODO: Replace with your actual server IP or 10.0.2.2 for Android Emulator
      const String apiUrl = 'http://192.168.0.188:8000/predict';
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'inputs': inputs}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final prediction = result['prediction'];
        final scores = Map<String, String>.from(result['confidence_scores']);

        // Save to Firestore
        await AuthService().saveScanResult(
          diagnosis: prediction,
          confidenceScores: scores,
        );
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                diagnosis: prediction,
                confidenceScores: scores,
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<SettingsProvider>(context).locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isArabic ? 'فحص الأعراض' : 'Symptoms Check', style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isAnalyzing 
          ? _buildLoadingOverlay(isArabic)
          : ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: _questions.length + 1,
        itemBuilder: (context, index) {
          if (index == _questions.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 40.0),
              child: ElevatedButton(
                onPressed: () => _submitSymptoms(isArabic),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(isArabic ? 'تحليل بواسطة الذكاء الاصطناعي' : 'Analyze with AI', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ).animate().fade(delay: 600.ms).slideY(begin: 0.5),
            );
          }

          final question = _questions[index];
          String displayTitle = isArabic ? question['title_ar'] : question['title'];
          String questionText = isArabic ? question['question_ar'] : question['question_en'];
          
          questionText = "$displayTitle\n$questionText";

          return Card(
            color: theme.cardTheme.color,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.health, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          questionText,
                          style: theme.textTheme.titleMedium?.copyWith(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionButton(
                          title: isArabic ? 'نعم' : 'Yes',
                          isSelected: question['answer'] == true,
                          color: AppColors.error,
                          onTap: () {
                            setState(() {
                              question['answer'] = true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOptionButton(
                          title: isArabic ? 'لا' : 'No',
                          isSelected: question['answer'] == false,
                          color: AppColors.success,
                          onTap: () {
                            setState(() {
                              question['answer'] = false;
                            });
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ).animate().fade(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1);
        },
      ),
    );
  }

  Widget _buildLoadingOverlay(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            isArabic ? 'الذكاء الاصطناعي يقوم بتحليل الأعراض...' : 'AI is analyzing your symptoms...',
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required String title,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? color : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
