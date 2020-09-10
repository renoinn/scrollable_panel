library scrollable_panel;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScrollablePanel extends StatefulWidget {
  final double defaultPanelSize;
  final double minPanelSize;
  final double maxPanelSize;
  final ScrollableWidgetBuilder builder;
  final PanelController controller;

  const ScrollablePanel({
    Key key,
    @required this.builder,
    this.controller,
    this.defaultPanelSize = 0.25,
    this.minPanelSize = 0,
    this.maxPanelSize = 1.0,
  })  : assert(minPanelSize < defaultPanelSize),
        assert(defaultPanelSize < maxPanelSize),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _ScrollablePanelState();
}

class _ScrollablePanelState extends State<ScrollablePanel> with SingleTickerProviderStateMixin {
  final double _snapThreshold = 0.2;
  double get defaultPanelSize => widget.defaultPanelSize;
  double get minPanelSize => widget.minPanelSize;
  double get maxPanelSize => widget.maxPanelSize;
  ScrollController _scrollController;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(value: defaultPanelSize, vsync: this, duration: Duration(milliseconds: 300));
    _animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    var panelController = widget.controller ?? PanelController();
    panelController._addState(this);
    _scrollController = _PanelScrollController(controller: panelController);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: _animationController.value,
        alignment: Alignment.bottomCenter,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: widget.builder(context, _scrollController),
        ),
      ),
    );
  }

  void _onDragEnd() {
    double fromMinValue = minPanelSize - _animationController.value;
    if (fromMinValue.abs() < (defaultPanelSize - minPanelSize) / 2) {
      _animateTo(minPanelSize);
      return;
    }

    double half = (maxPanelSize - defaultPanelSize) / 2 + defaultPanelSize;
    double fromMaxValue = maxPanelSize - _animationController.value;
    if (fromMaxValue.abs() < _snapThreshold || _animationController.value > half) {
      _animateTo(maxPanelSize);
      return;
    }

    double fromDefaultValue = defaultPanelSize - _animationController.value;
    if (fromDefaultValue.abs() < _snapThreshold || _animationController.value < half) {
      _animateTo(defaultPanelSize);
      return;
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      _onDragEnd();
    }

    return true;
  }

  void _animateTo(double to) {
    _animationController.animateTo(to);
  }

  void _toDefault() {
    _animationController.animateTo(defaultPanelSize);
  }
}

class PanelController {
  _ScrollablePanelState _state;

  double get value => _state?._animationController?.value;
  bool get isAttached => _state != null;
  double get defaultPanelSize => _state?.defaultPanelSize ?? 0.25;
  double get minPanelSize => _state?.minPanelSize ?? 0;
  double get maxPanelSize => _state?.maxPanelSize ?? 1.0;

  PanelController();

  void _addState(_ScrollablePanelState state) {
    _state = state;
  }

  void updateExtent(double delta) {
    double value = delta / _state.context.size.height;
    _state._animationController.value += value;
  }

  void animateTo(double to) {
    _state._animateTo(to);
  }

  void toDefault() {
    _state._toDefault();
  }
}

class _PanelScrollController extends ScrollController {
  final PanelController controller;

  _PanelScrollController({
    double initialScrollOffset = 0.0,
    keepScrollOffset = true,
    debugLabel,
    this.controller,
  }) : super(
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
          initialScrollOffset: initialScrollOffset,
        );

  @override
  _PanelScrollPosition createScrollPosition(ScrollPhysics physics, ScrollContext context, ScrollPosition oldPosition) {
    return _PanelScrollPosition(physics: physics, context: context, oldPosition: oldPosition, controller: controller);
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
    this.controller,
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
            (controller.value > controller.minPanelSize && delta > 0))) {
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
            (controller.value > controller.minPanelSize && velocity > 0))) {
      super.goBallistic(0);
      if (controller.value < controller.maxPanelSize && velocity > 300) {
        controller.animateTo(controller.maxPanelSize);
      } else if (controller.value > controller.defaultPanelSize) {
        if (velocity < -2000) {
          controller.animateTo(controller.minPanelSize);
        } else if (velocity < -300) {
          controller.animateTo(controller.defaultPanelSize);
        }
      } else if (controller.value < controller.defaultPanelSize && velocity < -300) {
        controller.animateTo(controller.minPanelSize);
      }
    } else {
      super.goBallistic(velocity);
    }
  }
}
