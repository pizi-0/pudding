enum JellyFilter {
  played('isPlayed'),
  unplayed('isUnplayed'),
  resumable('isResumable'),
  favorite('isFavorite');

  final String value;

  const new(this.value);
}
