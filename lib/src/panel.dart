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
  })  : assert(minPanelSize <= defaultPanelSize),
        assert(defaultPanelSize <= maxPanelSize),
        assert(minPanelSize < maxPanelSize),
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
  /// pass [PanelScrollController] instance to scrollController.
  ///
  /// ```dart
  /// builder: (context, controller) {
  ///   return SingleChildScrollView(
  ///     controller: controller,
  ///     child: InnerView(),
  ///   );
  /// },
  ///
  /// ```
  ///
  /// can't drag panel if builder callback return non [Scrollable] widget.
  /// if you want drag to expand, need to return [Scrollable] widget.
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
  State<StatefulWidget> createState() => ScrollablePanelState();
}

enum PanelState {
  /// [PanelState.open] when panel height value greater-than 0.0 and less-than 1.0
  open,

  /// [PanelState.expand] when panel height value equal maxPanelSize.
  expand,

  /// [PanelState.close] when panel height value equal minPanelSize.
  close,
}

class ScrollablePanelState extends State<ScrollablePanel> with SingleTickerProviderStateMixin {
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

        final onOpen = widget.onOpen;
        if (_dragAnimationController.value == defaultPanelSize) {
          if (onOpen != null && _panelState != PanelState.open) {
            onOpen();
          }
          _panelState = PanelState.open;
        }

        final onClose = widget.onClose;
        if (_dragAnimationController.value == minPanelSize) {
          if (onClose != null && _panelState != PanelState.close) {
            onClose();
          }
          _panelState = PanelState.close;
        }

        final onExpand = widget.onExpand;
        if (_dragAnimationController.value == maxPanelSize) {
          if (onExpand != null && _panelState != PanelState.expand) {
            onExpand();
          }
          _panelState = PanelState.expand;
        }
      }
    });
    final panelController = widget.controller ?? PanelController();
    panelController.addState(this);
    _scrollController = PanelScrollController(controller: panelController);
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

  Future<void> _animateTo(double to) async {
    await _dragAnimationController.animateTo(to);
  }

  Future<void> _toDefault() async {
    await _animateTo(defaultPanelSize);
  }

  Future<void> _expand() async {
    await _animateTo(maxPanelSize);
  }

  Future<void> _close() async {
    await _animateTo(minPanelSize);
  }

  Future<bool> _onWillPop() async {
    _scrollController.jumpTo(0.0);
    if (_dragAnimationController.value > defaultPanelSize) {
      await _toDefault();
      return false;
    } else if (_dragAnimationController.value > minPanelSize) {
      await _close();
      return false;
    }
    return true;
  }
}

class PanelController {
  PanelController();

  ScrollablePanelState? _state;

  /// ValueListenable panel animation. when panel drag or call open/close/expand, notifier listeners.
  Animation? get animation => _state?._dragAnimationController;

  /// PanelController need attach _ScrollablePanelState.
  bool get isAttached => _state != null;

  /// return defaultPanelSize
  double get defaultPanelSize => _state?.defaultPanelSize ?? 0.25;

  /// return minPanelSize
  double get minPanelSize => _state?.minPanelSize ?? 0;

  /// return maxPanelSize
  double get maxPanelSize => _state?.maxPanelSize ?? 1.0;

  /// return true if panel state is [PanelState.open]
  bool get isOpen => _state?._panelState == PanelState.open;

  /// return true if panel state is [PanelState.close]
  bool get isClose => _state?._panelState == PanelState.close;

  /// return true if panel state is [PanelState.expand]
  bool get isExpand => _state?._panelState == PanelState.expand;

  @visibleForTesting
  void addState(ScrollablePanelState state) {
    _state = state;
  }

  void _updateExtent(double delta) {
    if (!isAttached) return;
    final value = delta / (_state?.context.size?.height ?? 0);
    _state?._dragAnimationController.value += value;
  }

  /// animate panel height to passed value
  Future<void> animateTo(double to) async {
    if (!isAttached) throw UnAttachStateException('you can\'t use controller before _ScrollablePanelState build.');
    await _state?._animateTo(to);
  }

  /// animate panel height to defaultPanelSize
  Future<void> toDefault() async {
    if (!isAttached) throw UnAttachStateException('you can\'t use controller before _ScrollablePanelState build.');
    await _state?._toDefault();
  }

  /// alias toDefault
  Future<void> open() async {
    await toDefault();
  }

  /// animate panel height to maxPanelSize
  Future<void> expand() async {
    if (!isAttached) throw UnAttachStateException('you can\'t use controller before _ScrollablePanelState build.');
    await _state?._expand();
  }

  /// animate panel height to minPanelSize
  Future<void> close() async {
    if (!isAttached) throw UnAttachStateException('you can\'t use controller before _ScrollablePanelState build.');
    await _state?._close();
  }
}

class UnAttachStateException implements Exception {
  final String message;

  UnAttachStateException(this.message);
}

@visibleForTesting
class PanelScrollController extends ScrollController {
  final PanelController controller;

  PanelScrollController({
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
  PanelScrollPosition createScrollPosition(ScrollPhysics physics, ScrollContext context, ScrollPosition? oldPosition) {
    return PanelScrollPosition(physics: physics, context: context, oldPosition: oldPosition, controller: controller);
  }
}

@visibleForTesting
class PanelScrollPosition extends ScrollPositionWithSingleContext {
  PanelScrollPosition({
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

  final PanelController controller;

  bool get listShouldScroll => pixels > 0.0;
  double get controllerValue => controller.animation?.value ?? 0;

  @override
  void applyUserOffset(double delta) {
    if (!listShouldScroll &&
        (!(controllerValue == controller.maxPanelSize || controllerValue == controller.minPanelSize) ||
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
        (!(controllerValue == controller.maxPanelSize || controllerValue == controller.minPanelSize) ||
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
