import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'collapsible_side_navigation.dart';
import 'collapsible_tile.dart';
import 'side_navigation_item.dart';

class CollapsibleSideNavigationMenuContext with ChangeNotifier {
  late int _selected;
  int get selected => _selected;
  set selected(int v) {
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
    int selected = 0,
    List<SideNavigationItem> navigationItems = const [],
  }) {
    _selected = selected;
    _navigationItems = navigationItems;
  }
}

class CollapsibleSideNavigationMenu extends StatefulWidget {
  final List<SideNavigationItem> menu;

  CollapsibleSideNavigationMenu({required this.menu});

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
                        Divider(
                          height: 2.0,
                          color: Color(0xffeeeeee),
                        )
                      ],
                    ),
                  ),
                );
              }

              return Container(
                margin: item.isBackButton ? EdgeInsets.only(bottom: 20) : null,
                child: CollapsibleTile(
                  onTap: () {
                    menuState.selected = counter;
                  },
                  isSelected: menuState.selected == counter,
                  navigationItem: item,
                ),
              );
            },
            itemCount: menuState.navigationItems.length,
          );
        },
      ),
    );
  }
}
