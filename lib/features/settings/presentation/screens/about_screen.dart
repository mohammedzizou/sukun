import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/images.dart';
import '../../../../core/constants/theme_data.dart';
import '../../../../core/widgets/app_background.dart';
import '../cubit/about_cubit.dart';
import '../cubit/about_state.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: BlocBuilder<AboutCubit, AboutState>(
                  builder: (context, state) {
                    if (state is AboutLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.activeGreen));
                    }
                    if (state is AboutError) {
                      return Center(child: Text(state.message.tr));
                    }
                    if (state is AboutLoaded) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            _buildLogo(),
                            const SizedBox(height: 24),
                            _buildAppInfo(state),
                            const SizedBox(height: 32),
                            _buildDescription(),
                            const SizedBox(height: 40),
                            _buildActionButtons(context),
                            const SizedBox(height: 40),
                            _buildFooter(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'About Sukun'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.activeGreen15,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.activeGreen, width: 2),
      ),
      child: SvgPicture.asset(
        AppIcons.mosque,
        colorFilter: const ColorFilter.mode(AppColors.activeGreen, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildAppInfo(AboutLoaded state) {
    return Column(
      children: [
        Text(
          state.appInfo.appName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Version ${state.appInfo.version} (${state.appInfo.buildNumber})',
          style: const TextStyle(
            color: AppColors.mint50,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.activeGreen20),
      ),
      child: Text(
        'Sukun is an open-source project dedicated to helping Muslims manage their phone\'s sound mode during prayer times automatically.'.tr,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.code,
          label: 'Visit GitHub'.tr,
          onTap: () => _launchUrl('https://github.com/mohammedzizou/sukun'),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          icon: Icons.description_outlined,
          label: 'View Licenses'.tr,
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'Sukun',
            applicationVersion: '1.0.0', // This could be dynamic but LicensePage is static
            applicationIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(AppIcons.mosque, width: 48, height: 48, colorFilter: const ColorFilter.mode(AppColors.activeGreen, BlendMode.srcIn)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          icon: Icons.shield_outlined,
          label: 'Privacy Policy'.tr,
          onTap: () => _launchUrl('https://github.com/mohammedzizou/sukun/blob/main/PRIVACY_POLICY.md'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.activeGreen20),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.activeGreen, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.open_in_new, color: AppColors.mint35, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Free and open for the Ummah'.tr,
          style: const TextStyle(
            color: AppColors.mint50,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'MIT License',
          style: TextStyle(
            color: AppColors.activeGreen,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
