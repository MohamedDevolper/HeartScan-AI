import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../auth/login_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot? doc = await _authService.getUserData();
      if (doc != null && doc.exists) {
        setState(() {
          _userData = doc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.tr('profile'), style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile Image
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.primary, width: 3),
                            image: _profileImage != null
                                ? DecorationImage(
                                    image: FileImage(_profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _profileImage == null
                              ? const Icon(Iconsax.user, size: 60, color: AppColors.textSecondary)
                              : null,
                        ).animate().scale().fade(),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.camera, color: Colors.white, size: 20),
                          ),
                        ).animate().scale(delay: 300.ms),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _userData?['name'] ?? context.tr('guest_user'),
                  style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ).animate().fade(delay: 200.ms).slideY(),
                const SizedBox(height: 8),
                Text(
                  _userData?['email'] ?? context.tr('no_email'),
                  style: theme.textTheme.bodyMedium,
                ).animate().fade(delay: 300.ms).slideY(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoBadge(context, label: context.tr('age'), value: '${_userData?['age'] ?? '--'}'),
                    const SizedBox(width: 12),
                    _buildInfoBadge(context, label: context.tr('gender'), value: '${_userData?['gender'] ?? '--'}'),
                  ],
                ).animate().fade(delay: 400.ms).scale(),
                
                const SizedBox(height: 32),
                
                // Settings List
                _buildSettingsTile(
                  context,
                  icon: Iconsax.personalcard,
                  title: context.tr('personal_information'),
                  onTap: () => _showPersonalInfoDialog(context),
                ).animate().fade(delay: 500.ms).slideX(),
                _buildSettingsTile(
                  context,
                  icon: Iconsax.language_square,
                  title: context.tr('language'),
                  trailing: Text(settings.locale.languageCode == 'ar' ? 'العربية' : 'English'),
                  onTap: () {
                    settings.setLocale(settings.locale.languageCode == 'en' ? 'ar' : 'en');
                  },
                ).animate().fade(delay: 600.ms).slideX(),
                _buildSettingsTile(
                  context,
                  icon: Iconsax.moon,
                  title: context.tr('theme'),
                  trailing: Switch(
                    value: settings.isDarkMode,
                    onChanged: (val) {
                      settings.toggleTheme(val);
                    },
                    activeColor: AppColors.primary,
                  ),
                  onTap: () {
                    settings.toggleTheme(!settings.isDarkMode);
                  },
                ).animate().fade(delay: 700.ms).slideX(),
                _buildSettingsTile(
                  context,
                  icon: Iconsax.message_question,
                  title: context.tr('help_support'),
                  onTap: () {},
                ).animate().fade(delay: 800.ms).slideX(),
                
                const SizedBox(height: 32),
                
                // Logout Button
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Iconsax.logout, color: AppColors.error),
                  label: Text(
                    context.tr('logout'),
                    style: const TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ).animate().fade(delay: 900.ms).slideY(begin: 0.5),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, {required String label, required String value}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.secondary),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: trailing ?? Icon(Iconsax.arrow_right_3, size: 18, color: Theme.of(context).iconTheme.color),
        onTap: onTap,
      ),
    );
  }

  void _showPersonalInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text(context.tr('personal_information')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${_userData?['name'] ?? context.tr('guest_user')}", style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text("Email: ${_userData?['email'] ?? context.tr('no_email')}", style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text("${context.tr('age')}: ${_userData?['age'] ?? '--'}", style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text("${context.tr('gender')}: ${_userData?['gender'] ?? '--'}", style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('close'), style: const TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }
}
