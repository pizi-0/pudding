import 'package:material_ui/material_ui.dart';
import 'package:pudding/const/const.dart';

extension ScrollToKey on GlobalKey {
  void scrollToKey() {
    if (currentContext != null) {
      Scrollable.ensureVisible(
        currentContext!,
        duration: kDefaultAnimationDuration,
        curve: Curves.linear,
      );
    }
  }
}
