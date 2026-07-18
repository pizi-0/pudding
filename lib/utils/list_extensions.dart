extension UniqueByExtension<T> on Iterable<T> {
  Iterable<T> uniqueBy(Object Function(T element) selectKey) {
    final seenKeys = <Object>{};
    return where((element) => seenKeys.add(selectKey(element)));
  }
}
