import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/constants.dart';

/// Layar pembuka. Satu animasi masuk, lalu pindah ke beranda.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _rise = Tween<Offset>(
    begin: const Offset(0, 0.25),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) Get.offAllNamed(Routes.HOME);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _rise,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  Constants.appName,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 44,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(Constants.appTagline, style: theme.textTheme.labelMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
