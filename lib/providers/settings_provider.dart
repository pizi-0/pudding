import 'dart:async';

import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pudding/models/settings/library/library_prefs.dart';
import 'package:pudding/models/settings/library/pudding_settings.dart';
import 'package:pudding/services/di.dart';

class SettingsNotifier extends AsyncNotifier<PuddingSettings> {
  final client = services<JellyfinClient>();
  @override
  FutureOr<PuddingSettings> build() {
    return getSettings();
  }

  Future<PuddingSettings> getSettings() async {
    try {
      final res = await client.displayPreferences.get(
        displayPreferencesId: 'pudding-test-settings',
        client: 'pudding',
      );

      return PuddingSettings.fromMap(res.customPrefs);
    } catch (e) {
      debugPrint(e.toString());

      return PuddingSettings();
    }
  }

  Future<PuddingSettings> setSettings(
    PuddingSettings Function(PuddingSettings) settings,
  ) async {
    final val = settings(state.value ?? PuddingSettings());

    state = AsyncData(state.value!.copyWith(libraryPrefs: val.libraryPrefs));

    return state.value!;
  }

  Future<PuddingSettings> setLibraryPrefs(
    LibraryPrefs Function(LibraryPrefs) prefs,
  ) async {
    final current = state.value ?? PuddingSettings();
    final val = prefs(current.libraryPrefs);

    state = AsyncData(current.copyWith(libraryPrefs: val));

    return state.value!;
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, PuddingSettings>(
      () => SettingsNotifier(),
    );
