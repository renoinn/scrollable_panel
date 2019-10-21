library scrollable_panel;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';

class ScrollablePanel extends StatefulWidget {
  final Widget child;
  final PanelController controller;

  const ScrollablePanel({
    Key key,
    this.child,
    @required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScrollablePanelState();

}

class _ScrollablePanelState extends State<ScrollablePanel> {
  final double _snapThreshold = 0.2;
  double get minPanelSize => panelController.minPanelSize;
  double get maxPanelSize => panelController.maxPanelSize;
  ScrollController _scrollController;
  PanelController get panelController => widget.controller;

  @override
  void initState() {
    super.initState();
    panelController.extent.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _scrollController = _PanelScrollController(controller: panelController);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: panelController.value,
        alignment: Alignment.bottomCenter,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: Scrollbar(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              child: widget.child,
            ),
          ),
        )
      )
    );
  }

  void _onDragEnd() {
    double half = (maxPanelSize - minPanelSize) / 2 + minPanelSize;
    double fromMaxValue = maxPanelSize - panelController.value;
    if (fromMaxValue.abs() < _snapThreshold || panelController.value > half) {
      panelController.animateTo(maxPanelSize);
      return;
    }

    double fromMinValue = minPanelSize - panelController.value;
    if (fromMinValue.abs() < _snapThreshold || panelController.value < half) {
      panelController.animateTo(minPanelSize);
      return;
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      _onDragEnd();
    }

    return true;
  }
}

class PanelController implements TickerProvider {
  final double availablePixels;
  final double minPanelSize;
  final double maxPanelSize;
  final double snapThreshold;
  final ValueNotifier<double> extent;
  Ticker _ticker;
  AnimationController _animationController;
  double get value => extent.value;

  PanelController({
    @required this.minPanelSize,
    this.maxPanelSize = 1.0,
    @required this.availablePixels,
    @required this.extent,
    this.snapThreshold = 0.2,
  }) {
    _animationController = AnimationController(value: minPanelSize, vsync: this, duration: Duration(milliseconds: 300));
    _animationController.addListener(() {
      extent.value = _animationController.value;
    });
  }

  void updateExtent(double delta) {
    double value = delta / availablePixels;
    extent.value += value;
  }

  void animateTo(double to) {
    _animationController.value = extent.value;
    _animationController.animateTo(to);
  }

  @override
  Ticker createTicker(onTick) {
    _ticker = Ticker(onTick, debugLabel: kDebugMode ? 'created by $this' : null);
    // We assume that this is called from initState, build, or some sort of
    // event handler, and that thus TickerMode.of(context) would return true. We
    // can't actually check that here because if we're in initState then we're
    // not allowed to do inheritance checks yet.
    return _ticker;
  }
}

class _PanelScrollController extends ScrollController {
  final PanelController controller;

  _PanelScrollController({
    double initialScrollOffset = 0.0,
    keepScrollOffset = true,
    debugLabel,
    this.controller
  }) : super(
    keepScrollOffset: keepScrollOffset,
    debugLabel: debugLabel,
    initialScrollOffset: initialScrollOffset,
  );

  @override
  _PanelScrollPosition createScrollPosition(ScrollPhysics physics, ScrollContext context, ScrollPosition oldPosition) {
    return _PanelScrollPosition(
      physics: physics,
      context: context,
      oldPosition: oldPosition,
      controller: controller
    );
  }
}

class _PanelScrollPosition extends ScrollPositionWithSingleContext {
  final PanelController controller;

  _PanelScrollPosition({
    ScrollPhysics physics,
    ScrollContext context,
    double initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition oldPosition,
    String debugLabel,
    this.controller
  }) : super(
    physics: physics,
    context: context,
    initialPixels: initialPixels,
    keepScrollOffset: keepScrollOffset,
    oldPosition: oldPosition,
    debugLabel: debugLabel,
  );

  bool get listShouldScroll => pixels > 0.0;

  @override
  void applyUserOffset(double delta) {
    if (!listShouldScroll &&
        (!(controller.value == controller.maxPanelSize || controller.value == controller.minPanelSize) ||
        (controller.value < controller.maxPanelSize && delta < 0) ||
        (controller.value > controller.minPanelSize && delta > 0))
    ) {
      controller.updateExtent(-delta);
    } else {
      super.applyUserOffset(delta);
    }
  }

  @override
  void goBallistic(double velocity) {
    if (!listShouldScroll &&
        (!(controller.value == controller.maxPanelSize || controller.value == controller.minPanelSize) ||
        (controller.value < controller.maxPanelSize && velocity < 0) ||
        (controller.value > controller.minPanelSize && velocity > 0))
    ) {
      super.goBallistic(0);
    } else {
      super.goBallistic(velocity);
    }
  }
}