import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/widgets/progress.dart';
import 'package:pudding/services/di.dart';

class TvDetailScreen extends ConsumerStatefulWidget {
  final String? showId;
  const TvDetailScreen({super.key, this.showId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TvDetailScreensState();
}

class TvDetailScreensState extends ConsumerState<TvDetailScreen> {
  final client = services<JellyfinClient>();
  Future<JellyfinItem?> _getShowsDetails() async {
    if (widget.showId == null) return null;

    return await client.items.byId(widget.showId!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getShowsDetails(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (snapshot.hasData) {
          final item = snapshot.data;

          if (item != null) {
            return Text(item.name);
          }
        }

        return Center(
          child: FCircularProgress(),
        );
      },
    );
  }
}
