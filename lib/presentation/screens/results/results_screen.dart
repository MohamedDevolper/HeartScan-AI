import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:convert';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class ResultsScreen extends StatelessWidget {
  final String? diagnosis;
  final Map<String, String>? confidenceScores;
  final String? plotBase64;

  const ResultsScreen({
    super.key, 
    this.diagnosis, 
    this.confidenceScores,
    this.plotBase64,
  });

  String _getLocalizedDiagnosis(String? diagnosis, bool isArabic) {
    if (!isArabic) return diagnosis ?? "Arrhythmia Detected";
    if (diagnosis == null) return "تم اكتشاف خلل في ضربات القلب";
    
    switch (diagnosis.toLowerCase().trim()) {
      case 'normal heart rhythm': return 'نبض قلب طبيعي';
      case 'normal': return 'طبيعي';
      case 'arrhythmia detected': return 'تم اكتشاف عدم انتظام ضربات القلب';
      case 'arrhythmia': 
      case 'arrhythmias': return 'عدم انتظام ضربات القلب';
      case 'angina': 
      case 'angina pectoris': return 'الذبحة الصدرية';
      case 'heart failure': return 'قصور القلب';
      case 'myocardial infarction': return 'احتشاء عضلة القلب (جلطة)';
      default: return diagnosis;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<SettingsProvider>(context).locale.languageCode == 'ar';
    final theme = Theme.of(context);

    // Determine if healthy based on diagnosis
    final bool isHealthy = diagnosis == "Normal Heart Rhythm" || diagnosis == "Normal" || diagnosis == null;
    final String displayDiagnosis = _getLocalizedDiagnosis(diagnosis, isArabic);
    final Color statusColor = isHealthy ? AppColors.success : AppColors.error;
    final IconData statusIcon = isHealthy ? Iconsax.verify5 : Iconsax.warning_25;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isArabic ? 'نتيجة التشخيص' : 'Diagnosis Result', style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
              ),
              child: Column(
                children: [
                  Icon(statusIcon, size: 80, color: statusColor)
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds),
                  const SizedBox(height: 24),
                  Text(
                    displayDiagnosis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (confidenceScores != null && confidenceScores!.containsKey(diagnosis ?? "Arrhythmia Detected"))
                    Text(
                      '${isArabic ? 'نسبة الثقة' : 'Confidence Score'}: ${confidenceScores![diagnosis ?? "Arrhythmia Detected"]}',
                      style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                    ),
                ],
              ),
            ).animate().fade().scale(),
            
            const SizedBox(height: 32),

            // Plot Section (New)
            if (plotBase64 != null) ...[
              Text(
                isArabic ? 'التحليل البصري' : 'Visual Analysis',
                style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fade(delay: 100.ms).slideX(),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(plotBase64!),
                    fit: BoxFit.contain,
                  ),
                ),
              ).animate().fade(delay: 200.ms).scale(),
              const SizedBox(height: 32),
            ],
            
            // AI Analysis Details
            Text(
              isArabic ? 'تفاصيل تحليل الذكاء الاصطناعي' : 'AI Analysis Details',
              style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fade(delay: 200.ms).slideX(),
            const SizedBox(height: 16),
            
            if (confidenceScores != null)
              ...confidenceScores!.entries.map((entry) {
                return _buildDetailCard(
                  context,
                  icon: Iconsax.activity,
                  title: _getLocalizedDiagnosis(entry.key, isArabic),
                  value: entry.value,
                  isWarning: entry.key != "Normal Heart Rhythm",
                  delay: 300,
                );
              })
            else ...[
              _buildDetailCard(
                context,
                icon: Iconsax.health,
                title: 'Heart Rate',
                value: '112 bpm',
                isWarning: !isHealthy,
                delay: 300,
              ),
              _buildDetailCard(
                context,
                icon: Iconsax.activity,
                title: 'Rhythm Regularity',
                value: 'Irregular',
                isWarning: !isHealthy,
                delay: 400,
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Medical Advice
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.info_circle, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'التوصيات' : 'Recommendations',
                        style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isHealthy 
                        ? (isArabic ? 'يبدو أن إيقاع قلبك طبيعي بناءً على البيانات. استمر في الحفاظ على نمط حياة صحي.' : 'Your heart rhythm appears normal based on the provided data. Continue maintaining a healthy lifestyle.')
                        : (isArabic ? 'اكتشف الذكاء الاصطناعي أنماطاً مرتبطة بـ $displayDiagnosis. يُنصح بشدة باستشارة طبيب قلب لتقييم حالتك بدقة.' : 'The AI detected patterns associated with $displayDiagnosis. It is highly recommended to consult a cardiologist for a professional evaluation.'),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ).animate().fade(delay: 500.ms).slideY(begin: 0.2),

            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Iconsax.document_download),
              label: Text(isArabic ? 'تحميل التقرير الكامل' : 'Download Full Report'),
            ).animate().fade(delay: 600.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required bool isWarning,
    required int delay,
  }) {
    return Card(
      color: Theme.of(context).cardTheme.color,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.secondary),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isWarning ? AppColors.error : AppColors.success,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    ).animate().fade(delay: delay.ms).slideX(begin: 0.1);
  }
}
