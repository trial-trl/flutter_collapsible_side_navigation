import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_expansible_panel_list.dart';
import 'collapsible_side_navigation.dart';
import 'collapsible_tile.dart';
import 'side_navigation_item.dart';

class CollapsibleSideNavigationMenuContext with ChangeNotifier {
  late List<int> _selected;
  List<int> get selected => _selected;
  set selected(List<int> v) {
    _selected = v;
    notifyListeners();
  }

  late List<SideNavigationItem> _navigationItems;
  List<SideNavigationItem> get navigationItems => _navigationItems;
  set navigationItems(List<SideNavigationItem> v) {
    _navigationItems = v;
    notifyListeners();
  }

  CollapsibleSideNavigationMenuContext({
    List<int> selected = const [],
    List<SideNavigationItem> navigationItems = const [],
  }) {
    _selected = selected;
    _navigationItems = navigationItems;
  }
}

class CollapsibleSideNavigationMenu extends StatefulWidget {
  final List<SideNavigationItem> menu;
  final bool onTapNestedMenuSelectFirst;

  const CollapsibleSideNavigationMenu({
    required this.menu,
    this.onTapNestedMenuSelectFirst = false,
  });

  @override
  _CollapsibleSideNavigationMenuState createState() =>
      _CollapsibleSideNavigationMenuState();
}

class _CollapsibleSideNavigationMenuState
    extends State<CollapsibleSideNavigationMenu> {
  @override
  Widget build(BuildContext context) {
    final navState = Provider.of<CollapsibleSideNavigationContext>(context);

    return ChangeNotifierProvider(
      create: (_) => CollapsibleSideNavigationMenuContext(
        navigationItems: widget.menu,
      ),
      child: Consumer<CollapsibleSideNavigationMenuContext>(
        builder: (context, menuState, child) {
          return ListView.builder(
            itemBuilder: (context, counter) {
              final item = menuState.navigationItems[counter];

              if (item.isHeader) {
                return Opacity(
                  opacity: (navState.widthAnimation.value - navState.minWidth) /
                      (navState.maxWidth - navState.minWidth),
                  child: SizedBox(
                    height: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 18),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.0),
                          child: Text(
                            item.label!,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Divider(height: 1.0)
                      ],
                    ),
                  ),
                );
              }

              return renderItemMenu(item);
            },
            itemCount: menuState.navigationItems.length,
          );
        },
      ),
    );
  }

  Widget renderItemMenu(
    SideNavigationItem item, [
    List<SideNavigationItem> parent = const [],
  ]) {
    return Consumer<CollapsibleSideNavigationMenuContext>(
      builder: (context, menuState, child) {
        final currentPath = [...parent, item];
        final currentIndexPath = convertItemsToPath(
          currentPath,
          menuState.navigationItems,
        );
        final isSelected = menuState.selected.length > 0 &&
            currentIndexPath.indexed.every(
              (e) => menuState.selected.elementAtOrNull(e.$1) == e.$2,
            );

        if (item.children != null && item.children!.length > 0) {
          return Container(
            margin: item.isBackButton ? EdgeInsets.only(bottom: 20) : null,
            child: AppExpansionPanelList(
              elevation: 0,
              expansionCallback: (panelIndex, isExpanded) {
                if (widget.onTapNestedMenuSelectFirst) {
                  menuState.selected = [...currentIndexPath, 0];

                  if (item.children!.first.onTap != null)
                    item.children!.first.onTap!();

                  return;
                }

                menuState.selected = currentIndexPath;

                if (item.onTap != null) item.onTap!();
              },
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  backgroundColor: Colors.transparent,
                  headerBuilder: (context, isExpanded) => CollapsibleTile(
                    isSelected: isSelected,
                    navigationItem: item,
                    disableInteraction: true,
                  ),
                  body: Container(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withAlpha(60),
                    child: Column(
                      children: item.children!
                          .map(
                            (nestedItem) => renderItemMenu(
                              nestedItem,
                              currentPath,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  isExpanded: isSelected,
                ),
              ],
            ),
          );
        }

        return Container(
          margin: item.isBackButton ? EdgeInsets.only(bottom: 20) : null,
          child: CollapsibleTile(
            onTap: () {
              menuState.selected = currentIndexPath;
            },
            isSelected: isSelected,
            navigationItem: item,
          ),
        );
      },
    );
  }

  List<int> convertItemsToPath(
    List<SideNavigationItem> items,
    List<SideNavigationItem> startReference,
  ) {
    final List<int> path = [];
    List<SideNavigationItem> reference = startReference;

    items.forEach((item) {
      final foundIndex = convertItemToPath(item, reference);

      if (foundIndex >= 0) {
        if (item.children != null && item.children!.length > 0) {
          reference = item.children!;
        }
        return path.add(foundIndex);
      }
    });

    return path;
  }

  convertItemToPath(
    SideNavigationItem item,
    List<SideNavigationItem> reference,
  ) {
    final foundIndex = reference.indexOf(item);

    if (foundIndex >= 0) {
      return foundIndex;
    }

    return -1;
  }
}
