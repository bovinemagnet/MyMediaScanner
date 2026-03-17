import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('About ${AppConstants.appName}')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version ?? '1.0.0';
          final buildNumber = snapshot.data?.buildNumber ?? '';
          final versionDisplay =
              buildNumber.isNotEmpty ? '$version+$buildNumber' : version;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              // App icon and name
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icon/app_icon.png',
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version $versionDisplay',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'A cross-platform app for scanning barcodes on '
                        'physical media and building a personal collection '
                        'catalogue.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),

              // Author
              const ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Author'),
                subtitle: Text('Paul Snow'),
              ),

              // GitHub
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('GitHub Repository'),
                subtitle: const Text(AppConstants.githubUrl),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openUrl(AppConstants.githubUrl),
              ),

              const Divider(),

              // Features
              _SectionHeader(title: 'Features'),
              const _FeatureTile(
                icon: Icons.qr_code_scanner,
                text: 'Barcode scanning for CDs, DVDs, Blu-rays, books and games',
              ),
              const _FeatureTile(
                icon: Icons.devices,
                text: 'Multi-platform support (Android, iOS, macOS, Windows, Linux)',
              ),
              const _FeatureTile(
                icon: Icons.swap_horiz,
                text: 'Lending tracker for borrowed media',
              ),
              const _FeatureTile(
                icon: Icons.album,
                text: 'FLAC rip library scanner with coverage comparison',
              ),
              const _FeatureTile(
                icon: Icons.sync,
                text: 'PostgreSQL sync for multi-device collections',
              ),
              const _FeatureTile(
                icon: Icons.bar_chart,
                text: 'Statistics dashboard with CSV/JSON export',
              ),

              const Divider(),

              // Built with
              ListTile(
                leading: const FlutterLogo(size: 24),
                title: const Text('Built with Flutter'),
              ),

              // Licences
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
          );
        },
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
