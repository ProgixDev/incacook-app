import 'package:flutter/material.dart';
import 'package:homemade/core/common/widgets/custon_shapes/curved_edges/curved_edges_top.dart';

class CurvedEdgesWidgetTop extends StatelessWidget {
  const CurvedEdgesWidgetTop({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: CustomCurvedEdgesTop(), child: child);
  }
}
