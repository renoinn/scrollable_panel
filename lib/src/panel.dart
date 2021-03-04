import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// TODO List<double> anchorみたいなのを用意して、そのポイントでsnapするようにしたい。open()した時に、defaultPanelSizeが指定されていればdefaultPanelSizeに、されていなければanchor[0]になる。toNext/toPrevで上下する。

class ScrollablePanel extends StatefulWidget {
  const ScrollablePanel({
    Key? key,
    required this.builder,
    this.controller,
    this.defaultPanelState = PanelState.open,
    this.defaultPanelSize = 0.25,
    this.minPanelSize = 0,
    this.maxPanelSize = 1.0,
    this.onOpen,
    this.onClose,
    this.onExpand,
  })  : assert(minPanelSize < defaultPanelSize),
        assert(defaultPanelSize < maxPanelSize),
        super(key: key);

  /// default PanelState. if null, set [PanelState.open].
  final PanelState defaultPanelState;

  /// default panel height. when open panel, animate to defaultPanelSize.
  /// set between 0.0 to 1.0 .
  final double defaultPanelSize;

  /// minimum panel height. when close panel, animate to minPanelSize.
  /// set between 0.0 to 1.0 .
  final double minPanelSize;

  /// maximum panel height. when expand panel, animate to defaultPanelSize.
  /// set between 0.0 to 1.0 .
  final double maxPanelSize;

  /// build inner widget in panel.
  /// pass [_PanelScrollController] instance to scrollController.
  ///
  /// ```dart
  /// builder: (context, controller) {
  ///   return SingleChildScrollView(
  ///     controller: controller,
  ///     child: InnerView(),
  ///   );
  /// },
  /// ```
  final ScrollableWidgetBuilder builder;

  /// [PanelController] instance for control panel.
  final PanelController? controller;

  /// call this method when PanelState become open if not null.
  final VoidCallback? onOpen;

  /// call this method when PanelState become close if not null.
  final VoidCallback? onClose;

  /// call this method when PanelState become expand if not null.
  final VoidCallback? onExpand;

  @override
  State<StatefulWidget> createState() => _ScrollablePanelState();
}

enum PanelState {
  /// [PanelState.open] when panel height value greater-than 0.0 and less-than 1.0
  open,

  /// [PanelState.expand] when panel height value equal maxPanelSize.
  expand,

  /// [PanelState.close] when panel height value equal minPanelSize.
  close,
}

class _ScrollablePanelState extends State<ScrollablePanel> with SingleTickerProviderStateMixin {
  final double _snapThreshold = 0.2;
  double get defaultPanelSize => widget.defaultPanelSize;
  double get minPanelSize => widget.minPanelSize;
  double get maxPanelSize => widget.maxPanelSize;
  late ScrollController _scrollController;
  late AnimationController _dragAnimationController;
  late PanelState _panelState;

  @override
  void initState() {
    super.initState();
    _panelState = widget.defaultPanelState;
    var startValue = defaultPanelSize;
    if (widget.defaultPanelState == PanelState.close) {
      startValue = minPanelSize;
    } else if (widget.defaultPanelState == PanelState.expand) {
      startValue = maxPanelSize;
    }
    _dragAnimationController = AnimationController(value: startValue, vsync: this, duration: const Duration(milliseconds: 300));
    _dragAnimationController.addListener(() {
      if (mounted) {
        setState(() {});

        if (_dragAnimationController.value == defaultPanelSize) {
          if (widget.onOpen != null && _panelState != PanelState.open) {
            widget.onOpen!();
          }
          _panelState = PanelState.open;
        }
        if (_dragAnimationController.value == minPanelSize) {
          if (widget.onClose != null && _panelState != PanelState.close) {
            widget.onClose!();
          }
          _panelState = PanelState.close;
        }
        if (_dragAnimationController.value == maxPanelSize) {
          if (widget.onExpand != null && _panelState != PanelState.expand) {
            widget.onExpand!();
          }
          _panelState = PanelState.expand;
        }
      }
    });
    final panelController = widget.controller ?? PanelController();
    panelController._addState(this);
    _scrollController = _PanelScrollController(controller: panelController);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: FractionallySizedBox(
          heightFactor: _dragAnimationController.value,
          alignment: Alignment.bottomCenter,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: widget.builder(context, _scrollController),
          ),
        ),
      ),
    );
  }

  void _onDragEnd() {
    final fromMinValue = minPanelSize - _dragAnimationController.value;
    if (fromMinValue.abs() < (defaultPanelSize - minPanelSize) / 2) {
      _animateTo(minPanelSize);
      return;
    }

    final half = (maxPanelSize - defaultPanelSize) / 2 + defaultPanelSize;
    final fromMaxValue = maxPanelSize - _dragAnimationController.value;
    if (fromMaxValue.abs() < _snapThreshold || _dragAnimationController.value > half) {
      _animateTo(maxPanelSize);
      return;
    }

    final fromDefaultValue = defaultPanelSize - _dragAnimationController.value;
    if (fromDefaultValue.abs() < _snapThreshold || _dragAnimationController.value < half) {
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
    _dragAnimationController.animateTo(to);
  }

  void _toDefault() {
    _dragAnimationController.animateTo(defaultPanelSize);
  }

  void _expand() {
    _animateTo(maxPanelSize);
  }

  void _close() {
    _animateTo(minPanelSize);
  }

  Future<bool> _onWillPop() async {
    _scrollController.jumpTo(0.0);
    if (_dragAnimationController.value > defaultPanelSize) {
      _toDefault();
      return false;
    } else if (_dragAnimationController.value > minPanelSize) {
      _close();
      return false;
    }
    return true;
  }
}

class PanelController {
  _ScrollablePanelState? _state;

  Animation? get animation => _state?._dragAnimationController;
  double? get value => _state?._dragAnimationController.value;
  bool get isAttached => _state != null;
  double get defaultPanelSize => _state?.defaultPanelSize ?? 0.25;
  double get minPanelSize => _state?.minPanelSize ?? 0;
  double get maxPanelSize => _state?.maxPanelSize ?? 1.0;

  PanelController();

  void _addState(_ScrollablePanelState state) {
    _state = state;
  }

  void _updateExtent(double delta) {
    if (!isAttached) return;
    final value = delta / (_state?.context.size?.height ?? 0);
    _state?._dragAnimationController.value += value;
  }

  /// animate panel height to passed value
  void animateTo(double to) {
    if (!isAttached) throw UnAttachStateException('you can\'t use controller before _ScrollablePanelState build.');
    _state?._animateTo(to);
  }

  /// animate panel height to defaultPanelSize
  void toDefault() {
    if (!isAttached) throw UnAttachStateException('you can\'t use controller before _ScrollablePanelState build.');
    _state?._toDefault();
  }

  /// alias toDefault
  void open() => toDefault();

  /// animate panel height to maxPanelSize
  void expand() {
    if (!isAttached) throw UnAttachStateException('you can\'t use controller before _ScrollablePanelState build.');
    _state?._expand();
  }

  /// animate panel height to minPanelSize
  void close() {
    if (!isAttached) throw UnAttachStateException('you can\'t use controller before _ScrollablePanelState build.');
    _state?._close();
  }
}

class UnAttachStateException implements Exception {
  final String message;

  UnAttachStateException(this.message);
}

class _PanelScrollController extends ScrollController {
  final PanelController controller;

  _PanelScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
    required this.controller,
  }) : super(
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
          initialScrollOffset: initialScrollOffset,
        );

  @override
  _PanelScrollPosition createScrollPosition(ScrollPhysics physics, ScrollContext context, ScrollPosition? oldPosition) {
    return _PanelScrollPosition(physics: physics, context: context, oldPosition: oldPosition, controller: controller);
  }
}

class _PanelScrollPosition extends ScrollPositionWithSingleContext {
  final PanelController controller;

  _PanelScrollPosition({
    required ScrollPhysics physics,
    required ScrollContext context,
    double initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition? oldPosition,
    String? debugLabel,
    required this.controller,
  }) : super(
          physics: physics,
          context: context,
          initialPixels: initialPixels,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        );

  bool get listShouldScroll => pixels > 0.0;
  double get controllerValue => controller.animation?.value ?? 0;

  @override
  void applyUserOffset(double delta) {
    if (!listShouldScroll &&
        (!(controller.value == controller.maxPanelSize || controller.value == controller.minPanelSize) ||
            (controllerValue < controller.maxPanelSize && delta < 0) ||
            (controllerValue > controller.minPanelSize && delta > 0))) {
      controller._updateExtent(-delta);
    } else {
      super.applyUserOffset(delta);
    }
  }

  @override
  void goBallistic(double velocity) {
    if (!listShouldScroll &&
        (!(controller.value == controller.maxPanelSize || controller.value == controller.minPanelSize) ||
            (controllerValue < controller.maxPanelSize && velocity < 0) ||
            (controllerValue > controller.minPanelSize && velocity > 0))) {
      super.goBallistic(0);
      if (controllerValue < controller.maxPanelSize && velocity > 300) {
        controller.animateTo(controller.maxPanelSize);
      } else if (controllerValue > controller.defaultPanelSize) {
        if (velocity < -2000) {
          controller.animateTo(controller.minPanelSize);
        } else if (velocity < -300) {
          controller.animateTo(controller.defaultPanelSize);
        }
      } else if (controllerValue < controller.defaultPanelSize && velocity < -300) {
        controller.animateTo(controller.minPanelSize);
      }
    } else {
      super.goBallistic(velocity);
    }
  }
}
