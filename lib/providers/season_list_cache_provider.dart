import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeasonListCacheNotifier extends Notifier<Map<String, List<String>>> {
  @override
  Map<String, List<String>> build() {
    return {};
  }

  void addDetail({
    required String seriesId,
    required List<String> seasons,
  }) {
    state = {...state, seriesId: seasons};
  }
}

final seasonListCacheProvider =
    NotifierProvider<SeasonListCacheNotifier, Map<String, List<String>>>(
      () => SeasonListCacheNotifier(),
    );
