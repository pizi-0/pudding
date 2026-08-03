import 'package:dart_jellyfin/dart_jellyfin.dart';

extension JellyfMediaStream on JellyfinMediaStream {
  String get getTitle => raw['DisplayTitle'] ?? 'title';
}
