// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:sukun/core/constants/images.dart';
import 'package:sukun/core/local_data/shared_preferences.dart';
import 'package:sukun/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:sukun/features/onboarding/presentation/widgets/onboarding_page_widget.dart';
import 'package:sukun/features/onboarding/presentation/widgets/page_indicator.dart';

/// The 3 onboarding page data definitions
const List<OnboardingPageData> _pages = [
  OnboardingPageData(
    tag: 'Peace in every prayer',
    title: 'Prayer Time, Silent Time',
    subtitle: 'Let your phone honor every prayer — automatically, every day.',
    iconAsset: AppIcons.mosque,
    useMosqueLayout: true,
  ),
  OnboardingPageData(
    tag: 'Smart automation',
    title: 'Set Once, Forget Forever',
    subtitle:
        'Salah Silent detects your local prayer times and silences your phone without any effort.',
    iconAsset: AppIcons.bellOff,
  ),
  OnboardingPageData(
    tag: 'Full control',
    title: 'Your Rules, Your Way',
    subtitle:
        'Choose which prayers to silence, customize duration, and restore sound mode after.',
    iconAsset: AppIcons.settingsActive,
  ),
];

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _animateToPage(int page) async {
    await _fadeController.reverse();
    if (!mounted) return;
    context.read<OnboardingCubit>().goToPage(page);
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    if (!mounted) return;
    _fadeController.forward();
  }

  Future<void> _finish() async {
    final prefs = GetIt.instance<AppPreferences>();
    await prefs.setHasSeenOnboarding();
    Get.offAllNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, int>(
      builder: (context, currentPage) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.50, 0.00),
                end: Alignment(0.50, 1.00),
                colors: [Color(0xFF081C15), Color(0xFF0B2E22)],
              ),
            ),
            child: Stack(
              children: [
                // PageView content (faded)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pages.length,
                    itemBuilder: (_, index) =>
                        OnboardingPageWidget(data: _pages[index]),
                  ),
                ),

                // Skip button (hidden on last page)
                if (currentPage < 2)
                  Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      height: 88,
                      padding: const EdgeInsets.only(top: 56, right: 28),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _finish,
                            child: Container(
                              width: 60,
                              height: 32,
                              decoration: ShapeDecoration(
                                color: const Color(0x14A3F7BF),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 0.65,
                                    color: Color(0x26A3F7BF),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Skip'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xB2A3F7BF),
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    height: 1.50,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom bar: indicators + button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 52),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Page dots
                        PageIndicator(
                          currentPage: currentPage,
                          pageCount: _pages.length,
                        ),
                        const SizedBox(height: 24),
                        // Action button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: _buildButton(currentPage),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(int currentPage) {
    final bool isLast = currentPage == 2;
    final String label = isLast ? 'Enable Silent During Prayer' : 'Continue';

    return GestureDetector(
      onTap: () {
        if (isLast) {
          _finish();
        } else {
          _animateToPage(currentPage + 1);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.00, 0.00),
            end: Alignment(1.00, 1.00),
            colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x4C2ECC71),
              blurRadius: 32,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                label.tr,
                key: ValueKey<String>(label),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                  letterSpacing: 0.20,
                ),
              ),
            ),
            if (!isLast) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
