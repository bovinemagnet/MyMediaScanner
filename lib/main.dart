import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymediascanner/app/app.dart';
import 'package:mymediascanner/core/utils/window_manager_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManagerHelper.initialise();
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
