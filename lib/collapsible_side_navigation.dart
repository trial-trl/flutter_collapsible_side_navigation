library collapsible_side_navigation;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum CollapseSideNavigationMode {
  AUTO,
  MANUAL,
  NONE,
}

class CollapsibleSideNavigation extends StatefulWidget {
  final Widget? header;
  final double maxWidth;
  final double minWidth;
  final double elevation;
  final Widget? child;
  final CollapseSideNavigationMode collapseMode;
  final bool startCollapsed;

  CollapsibleSideNavigation({
    this.header,
    this.maxWidth = 250.0,
    this.minWidth = 56.0,
    this.elevation = 12.0,
    this.collapseMode = CollapseSideNavigationMode.AUTO,
    this.startCollapsed = true,
    this.child,
  });

  @override
  createState() => _CollapsibleSideNavigationController();
}

class CollapsibleSideNavigationContextConsumer extends StatelessWidget {
  final Widget? child;
  final Widget Function(BuildContext, CollapsibleSideNavigationContext, Widget?)
      builder;

  const CollapsibleSideNavigationContextConsumer({
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CollapsibleSideNavigationContext>(
      child: child,
      builder: builder,
    );
  }
}

class CollapsibleSideNavigationContextProvider extends StatelessWidget {
  final Widget? child;
  final Widget Function(BuildContext, Widget?)? builder;

  const CollapsibleSideNavigationContextProvider({
    this.child,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CollapsibleSideNavigationContext(),
      child: child,
      builder: builder,
    );
  }
}

class CollapsibleSideNavigationContext with ChangeNotifier {
  void init({
    required AnimationController animationController,
    required double maxWidth,
    required double minWidth,
    required bool isCollapsed,
    required CollapseSideNavigationMode collapseMode,
  }) {
    if (isInitialized) return;

    _maxWidth = maxWidth;
    _minWidth = minWidth;
    _isCollapsed = isCollapsed;
    _collapseMode = collapseMode;
    _animationController = animationController;
    if (_collapseMode == CollapseSideNavigationMode.NONE) _isCollapsed = false;
    _widthAnimation = Tween<double>(begin: minWidth, end: maxWidth)
        .chain(CurveTween(curve: Curves.ease))
        .animate(animationController);
    _initialized = true;
    notifyListeners();
  }

  bool _initialized = false;
  bool get isInitialized => _initialized;

  late double _maxWidth;
  double get maxWidth => _maxWidth;
  set maxWidth(double v) {
    _maxWidth = v;
    notifyListeners();
  }

  late double _minWidth;
  double get minWidth => _minWidth;
  set minWidth(double v) {
    _minWidth = v;
    notifyListeners();
  }

  late bool _isCollapsed;
  bool get isCollapsed => _isCollapsed;
  set isCollapsed(bool v) {
    _isCollapsed = v;
    notifyListeners();
  }

  void toggle() {
    if (!isCollapsed)
      collapse();
    else
      expand();
  }

  void expand() {
    isCollapsed = false;
    animationController.forward();
  }

  void collapse() {
    isCollapsed = true;
    animationController.reverse();
  }

  late CollapseSideNavigationMode _collapseMode;
  CollapseSideNavigationMode get collapseMode => _collapseMode;
  set collapseMode(CollapseSideNavigationMode v) {
    _collapseMode = v;
    notifyListeners();
  }

  late AnimationController _animationController;
  AnimationController get animationController => _animationController;
  set animationController(AnimationController v) {
    _animationController = v;
    notifyListeners();
  }

  late Animation<double> _widthAnimation;
  Animation<double> get widthAnimation => _widthAnimation;
  set widthAnimation(Animation<double> v) {
    _widthAnimation = v;
    notifyListeners();
  }
}

class _CollapsibleSideNavigationController
    extends State<CollapsibleSideNavigation> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late CollapsibleSideNavigationContext _navProvider;

  late bool _contextProvided;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
      value: widget.collapseMode == CollapseSideNavigationMode.NONE ||
              !widget.startCollapsed
          ? 1
          : 0,
    );
    try {
      _navProvider = Provider.of<CollapsibleSideNavigationContext>(
        context,
        listen: false,
      );
      _contextProvided = true;
    } catch (e) {
      _navProvider = CollapsibleSideNavigationContext();
      _contextProvided = false;
    }
    _navProvider.init(
      animationController: _animationController,
      maxWidth: widget.maxWidth,
      minWidth: widget.minWidth,
      collapseMode: widget.collapseMode,
      isCollapsed: widget.startCollapsed,
    );
  }

  @override
  void didUpdateWidget(covariant CollapsibleSideNavigation oldWidget) {
    if (widget.maxWidth != oldWidget.maxWidth ||
        widget.minWidth != oldWidget.minWidth ||
        widget.collapseMode != oldWidget.collapseMode) {
      if (widget.collapseMode == CollapseSideNavigationMode.NONE ||
          !widget.startCollapsed) {
        _navProvider.expand();
      } else {
        _navProvider.collapse();
      }
      _navProvider.animationController = _animationController;
      _navProvider.maxWidth = widget.maxWidth;
      _navProvider.minWidth = widget.minWidth;
      _navProvider.collapseMode = widget.collapseMode;
      _navProvider.isCollapsed = widget.startCollapsed;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_contextProvided) return render();

    return ChangeNotifierProvider(
      create: (_) => _navProvider,
      child: render(),
    );
  }

  Widget render() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final navState = Provider.of<CollapsibleSideNavigationContext>(context);

        return Material(
          elevation: widget.elevation,
          child: Container(
            width: navState.widthAnimation.value,
            color: Theme.of(context).colorScheme.background,
            child: Builder(
              builder: (context) {
                if (navState.collapseMode == CollapseSideNavigationMode.AUTO)
                  return MouseRegion(
                    onEnter: (PointerEvent details) {
                      navState.expand();
                    },
                    onExit: (PointerEvent details) {
                      navState.collapse();
                    },
                    child: widget.child,
                  );

                return widget.child!;
              },
            ),
          ),
        );
      },
    );
  }
}
