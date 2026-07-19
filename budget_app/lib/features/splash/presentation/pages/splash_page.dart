import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../app_lock/presentation/bloc/app_lock_bloc.dart';
import '../../../app_lock/presentation/bloc/app_lock_event.dart';
import '../../../app_lock/presentation/bloc/app_lock_state.dart';
import '../../../app_lock/presentation/pages/lock_screen_page.dart';
import '../../../budget/presentation/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _navigateToDestination();
    });
  }

  void _navigateToDestination() {
    final appLockState = context.read<AppLockBloc>().state;
    final shouldShowLock =
        appLockState.settings.isEnabled &&
        appLockState.status != AppLockStatus.authenticated &&
        appLockState.status != AppLockStatus.loaded &&
        appLockState.status != AppLockStatus.initial &&
        appLockState.status != AppLockStatus.loading;

    if (shouldShowLock) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LockScreenPage(
            onUnlocked: () {
              context.read<AppLockBloc>().add(AppLockLoadSettings());
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Budget App',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Built by PyCentric',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
