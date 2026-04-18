import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/router.dart';
import 'package:mymediascanner/app/theme/app_theme.dart';
import 'package:mymediascanner/core/constants/app_constants.dart';
import 'package:mymediascanner/presentation/providers/settings_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choice = ref.watch(themeChoiceProvider);
    final (light, dark) = switch (choice.family) {
      ThemeFamily.classic => (AppTheme.light(), AppTheme.dark()),
      ThemeFamily.popcorn => (AppTheme.popcornLight(), AppTheme.popcornDark()),
    };

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: light,
      darkTheme: dark,
      themeMode: themeModeFrom(choice.brightness),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
