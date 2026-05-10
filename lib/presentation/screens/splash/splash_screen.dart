import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred Background for cinematic effect
          Image.asset(
            'assets/images/splash_icon.png.jpg',
            fit: BoxFit.cover,
          ).animate().fadeIn(duration: 800.ms),
          
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          // Main Logo (un-cropped)
          Center(
            child: Image.asset(
              'assets/images/splash_icon.png.jpg',
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width * 0.85,
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scaleXY(begin: 1.0, end: 1.05, duration: 4.seconds, curve: Curves.easeInOutSine)
                .shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.1)),
          ),

          // Dark Gradient Overlay for text readability (only at the bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withOpacity(0.6),
                    AppColors.background.withOpacity(0.9),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ).animate().fadeIn(duration: 1200.ms),
          ),

          // Content
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Heart beat icon / accent
                Icon(
                  Iconsax.health,
                  size: 56,
                  color: AppColors.primary,
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scaleXY(begin: 1.0, end: 1.2, duration: 800.ms, curve: Curves.easeInOut)
                    .then()
                    .scaleXY(begin: 1.2, end: 1.0, duration: 800.ms, curve: Curves.easeInOut)
                    .fadeIn(duration: 1000.ms),

                const SizedBox(height: 24),

                // App Title
                Text(
                  'HeartScan AI',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 800.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack, duration: 800.ms),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'AI-Powered Heart Diagnostics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w500,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 800.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut, duration: 800.ms),

                const SizedBox(height: 48),

                // Loading Indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withOpacity(0.8)),
                    strokeWidth: 3,
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 800.ms).scale(curve: Curves.elasticOut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
