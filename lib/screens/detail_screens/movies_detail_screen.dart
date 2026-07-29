import 'package:dart_jellyfin/dart_jellyfin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:forui/widgets/progress.dart';
import 'package:pudding/services/di.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  final String? movieId;
  const MovieDetailScreen({super.key, this.movieId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShowsDetailScreensState();
}

class _ShowsDetailScreensState extends ConsumerState<MovieDetailScreen> {
  final client = services<JellyfinClient>();
  Future<JellyfinItem?> _getMovieDetails() async {
    if (widget.movieId == null) return null;

    return await client.items.byId(widget.movieId!);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.movieId);

    return FScaffold(
      header: Padding(
        padding: const EdgeInsets.all(80.0),
        child: FHeader(
          title: Text('data'),
        ),
      ),
      child: FutureBuilder(
        future: _getMovieDetails(),
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
      ),
    );
  }
}
