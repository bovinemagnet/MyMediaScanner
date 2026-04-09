import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:mymediascanner/app/app.dart';
import 'package:mymediascanner/core/utils/window_manager_helper.dart';

// FFI binding for setlocale — required by MPV on Linux.
typedef _SetLocaleC = ffi.Pointer<Utf8> Function(
    ffi.Int32 category, ffi.Pointer<Utf8> locale);
typedef _SetLocaleDart = ffi.Pointer<Utf8> Function(
    int category, ffi.Pointer<Utf8> locale);

void _fixLocaleForMpv() {
  if (!Platform.isLinux) return;
  // LC_NUMERIC = 1 on glibc
  const lcNumeric = 1;
  final libc = ffi.DynamicLibrary.open('libc.so.6');
  final setlocale =
      libc.lookupFunction<_SetLocaleC, _SetLocaleDart>('setlocale');
  final cLocale = 'C'.toNativeUtf8();
  setlocale(lcNumeric, cLocale);
  calloc.free(cLocale);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _fixLocaleForMpv();
  JustAudioMediaKit.ensureInitialized();
  await WindowManagerHelper.initialise();
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
