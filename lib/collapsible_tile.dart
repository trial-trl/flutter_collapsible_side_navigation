import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'collapsible_side_navigation.dart';
import 'side_navigation_item.dart';

class CollapsibleTile extends StatelessWidget {
  final SideNavigationItem navigationItem;
  final Function? onTap;
  final bool isSelected;
  final AnimationController? animationController;

  CollapsibleTile({
    required this.navigationItem,
    this.isSelected = false,
    this.onTap,
    this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final navState = context.watch<CollapsibleSideNavigationContext>();
    final widthAnimation = Tween<double>(
      begin: navState.minWidth,
      end: navState.maxWidth,
    ).animate(navState.animationController);
    final sizedBoxAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(navState.animationController);

    final horizontalPadding = 10.0;

    return InkWell(
      onTap: () {
        if (onTap != null) onTap!();
        if (navigationItem.onTap != null) navigationItem.onTap!();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 4.0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 6.0,
        ),
        child: AnimatedBuilder(
          animation: navState.animationController,
          builder: (context, child) => Row(
            children: [
              navigationItem.icon(
                getForegroundColor(context),
                (navState.minWidth + (horizontalPadding * 2)) / 2,
              ),
              SizedBox.square(dimension: sizedBoxAnimation.value),
              Expanded(
                child: Opacity(
                  opacity: (widthAnimation.value - navState.minWidth) /
                      (navState.maxWidth - navState.minWidth),
                  child: navigationItem.right != null
                      ? navigationItem.right
                      : Text(
                          navigationItem.label!,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: getForegroundColor(context),
                                  ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getForegroundColor(BuildContext context) {
    if (isSelected) return Theme.of(context).colorScheme.onPrimaryContainer;

    return Theme.of(context).colorScheme.onBackground;
  }
}
