import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About ${AppConstants.appName}')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version ?? '1.0.0';
          final buildNumber = snapshot.data?.buildNumber ?? '';
          final versionDisplay =
              buildNumber.isNotEmpty ? '$version+$buildNumber' : version;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // App icon and name
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 64,
                        height: 64,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'v$versionDisplay',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'A cross-platform app for scanning barcodes on '
                        'physical media and building a personal collection '
                        'catalogue.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Author & GitHub
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('Author'),
                      subtitle: Text('Paul Snow'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('GitHub Repository'),
                      subtitle: const Text(AppConstants.githubUrl),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () => _openUrl(AppConstants.githubUrl),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Features
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FEATURES',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _FeatureTile(
                      icon: Icons.qr_code_scanner,
                      text:
                          'Barcode scanning for CDs, DVDs, Blu-rays, books and games',
                    ),
                    const _FeatureTile(
                      icon: Icons.devices,
                      text:
                          'Multi-platform support (Android, iOS, macOS, Windows, Linux)',
                    ),
                    const _FeatureTile(
                      icon: Icons.swap_horiz,
                      text: 'Lending tracker for borrowed media',
                    ),
                    const _FeatureTile(
                      icon: Icons.album,
                      text:
                          'FLAC rip library scanner with coverage comparison',
                    ),
                    const _FeatureTile(
                      icon: Icons.sync,
                      text: 'PostgreSQL sync for multi-device collections',
                    ),
                    const _FeatureTile(
                      icon: Icons.bar_chart,
                      text: 'Statistics dashboard with CSV/JSON export',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Built with + licences
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const ListTile(
                      leading: FlutterLogo(size: 24),
                      title: Text('Built with Flutter'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Open-source licences'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: versionDisplay,
                        applicationIcon: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            width: 48,
                            height: 48,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      // Silently handle — URL launch may fail on some platforms
    }
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child:
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
