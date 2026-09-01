import 'package:flutter/material.dart';
import 'package:forui_phosphor/forui_phosphor.dart';

class Topbar extends StatelessWidget {
  final Widget? prefix;
  final List<Widget> children;
  final Widget? suffix;

  const new({
    super.key,

    this.prefix,
    this.children = const [],
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          ?prefix,
          Icon(FPhosphorBoldIcons.dot),
          Expanded(
            child: Row(
              children: children
                  .map(
                    (c) => Flexible(fit: .loose, child: c),
                  )
                  .toList(),
            ),
          ),

          Icon(FPhosphorBoldIcons.dot),
          ?suffix,
        ],
      ),
    );
  }
}
