import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'collapsible_side_navigation.dart';

class CollapsibleSideNavigationMaterialToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<CollapsibleSideNavigationContext>();

    if (state.collapseMode != CollapseSideNavigationMode.NONE)
      return InkWell(
        onTap: state.toggle,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: state.animationController,
            color: Theme.of(context).colorScheme.onBackground,
            size: 30.0,
          ),
        ),
      );

    return Container();
  }
}
