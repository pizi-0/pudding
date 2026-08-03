import 'package:dart_jellyfin/dart_jellyfin.dart';

extension JellyMediaExtension on JellyfinMediaSource {
  List<JellyfinMediaStream> getAudioStreams() {
    return mediaStreams.where((s) => s.isAudio).toList();
  }

  List<JellyfinMediaStream> getSubtitles() {
    return mediaStreams.where((s) => s.isSubtitle).toList();
  }

  bool get isMultisub => getSubtitles().length > 1;
  bool get isMultiAudio => getAudioStreams().length > 1;
}
