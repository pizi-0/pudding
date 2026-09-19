import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pudding/utils/jellyfin_item_extensions.dart';

extension JellyItemNavigator on JellyfinItem {
  void push(BuildContext context, {bool shouldReplace = true}) {
    if (shouldReplace) {
      context.pushReplacement(_destination());
    } else {
      context.push(_destination());
    }
  }

  String _destination() {
    if (isMovie) {
      return '/movie/$id';
    } else if (isSeries) {
      return '/show/$id';
    } else if (isEpisode && seriesId != null) {
      return '/show/$seriesId';
    } else if (isBoxsets) {
      return '/collection/$id';
    } else {
      return '/home';
    }
  }
}
