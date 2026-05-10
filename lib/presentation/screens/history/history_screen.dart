import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildSummaryHeader(context)),
          _buildHistoryList(context),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(isArabic(context) ? 'سجل الفحوصات' : 'Heart History', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, Theme.of(context).scaffoldBackgroundColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  bool isArabic(BuildContext context) {
    return Provider.of<SettingsProvider>(context, listen: false).locale.languageCode == 'ar';
  }

  String _getLocalizedDiagnosis(String? diagnosis, bool isArabic) {
    if (!isArabic) return diagnosis ?? "Arrhythmia";
    if (diagnosis == null) return "عدم انتظام ضربات القلب";
    
    switch (diagnosis.toLowerCase().trim()) {
      case 'normal heart rhythm': return 'نبض قلب طبيعي';
      case 'normal rhythm': return 'نبض قلب طبيعي';
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

  Widget _buildSummaryHeader(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _authService.getUserScans(),
      builder: (context, snapshot) {
        int totalScans = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              _buildStatCard(context, isArabic(context) ? 'إجمالي الفحوصات' : 'Total Tests', totalScans.toString(), Iconsax.activity, AppColors.primary),
              const SizedBox(width: 16),
              _buildStatCard(context, isArabic(context) ? 'مؤشر الصحة' : 'Health Score', '94%', Iconsax.heart, AppColors.secondary),
            ],
          ),
        ).animate().fade().slideY(begin: 0.1);
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(value, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _authService.getUserScans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.folder_open, size: 80, color: AppColors.textSecondary.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text(isArabic(context) ? 'لا يوجد سجل فحوصات بعد.' : 'No diagnostic history yet.', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final String status = data['status'] ?? '';
                final bool isHealthy = data['isHealthy'] == true || status.toLowerCase().contains('normal');
                final Timestamp? timestamp = data['createdAt'] as Timestamp?;
                final DateTime date = timestamp != null ? timestamp.toDate() : DateTime.now();

                return _buildHistoryCard(context, data, status, isHealthy, date)
                    .animate()
                    .fade(delay: Duration(milliseconds: 100 * index))
                    .slideX(begin: 0.1);
              },
              childCount: docs.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> data, String status, bool isHealthy, DateTime date) {
    final Color statusColor = isHealthy ? AppColors.success : AppColors.error;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => _showHistoryDetailDialog(context, status, isHealthy),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isHealthy ? Iconsax.verify5 : Iconsax.warning_25,
            color: statusColor,
          ),
        ),
        title: Text(
          _getLocalizedDiagnosis(status.isEmpty ? (isHealthy ? 'Normal Rhythm' : 'Arrhythmia') : status, isArabic(context)),
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            '${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute}',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(isArabic(context) ? 'النسبة' : 'Score', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 10)),
            const SizedBox(height: 4),
            Text(
              data['score'] ?? '98%',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDetailDialog(BuildContext context, String status, bool isHealthy) {
    final bool ar = isArabic(context);
    final Color color = isHealthy ? AppColors.success : AppColors.error;
    final IconData icon = isHealthy ? Iconsax.verify5 : Iconsax.warning_2;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 60, color: color).animate().scale(delay: 100.ms),
              const SizedBox(height: 16),
              Text(
                _getLocalizedDiagnosis(status.isEmpty ? (isHealthy ? 'Normal Rhythm' : 'Arrhythmia') : status, ar),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isHealthy
                    ? (ar
                        ? "إيقاع قلبك طبيعي تماماً! استمر في الحفاظ على نمط حياتك الصحي."
                        : "Your heart rhythm is completely normal! Keep up the healthy lifestyle.")
                    : (ar
                        ? "تحذير: يرجى التوجه إلى أقرب مستشفى فوراً واستشارة طبيب قلب متخصص. حالتك تتطلب تقييماً طبياً عاجلاً."
                        : "Warning: Please head to the nearest hospital immediately and consult a specialist cardiologist. Your condition requires urgent medical evaluation."),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(ar ? 'حسناً' : 'OK', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }
}
