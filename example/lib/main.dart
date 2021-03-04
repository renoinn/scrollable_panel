import 'package:flutter/material.dart';
import 'package:scrollable_panel/scrollable_panel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PanelController _panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _AnimatedAppBar(
          panelController: _panelController,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _FirstView(controller: _panelController),
          ),
          ScrollablePanel(
            defaultPanelState: PanelState.close,
            controller: _panelController,
            onOpen: () => print('onOpen'),
            onClose: () => print('onClose'),
            onExpand: () => print('onExpand'),
            builder: (context, controller) {
              return SingleChildScrollView(
                controller: controller,
                child: _SecondView(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AnimatedAppBar extends StatefulWidget {
  const _AnimatedAppBar({
    Key? key,
    required this.panelController,
  }) : super(key: key);

  final PanelController panelController;

  @override
  __AnimatedAppBarState createState() => __AnimatedAppBarState();
}

class __AnimatedAppBarState extends State<_AnimatedAppBar> with SingleTickerProviderStateMixin {
  late final Animation _animation;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    widget.panelController.animation?.addListener(() {
      if (widget.panelController.animation!.value >= 0.8) {
        _animationController.value = (0.2 - (1.0 - widget.panelController.animation!.value)) * 5;
      } else {
        _animationController.value = 0;
      }
    });
    _animation = ColorTween(
      begin: Colors.white,
      end: Colors.red,
    ).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          elevation: 4.0,
          color: _animation.value,
          child: SafeArea(
            bottom: false,
            top: true,
            child: Container(
              height: kToolbarHeight,
              child: const Center(
                child: Text('scrollable panel'),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FirstView extends StatelessWidget {
  const _FirstView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PanelController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => controller.open(),
          child: const Text('open panel'),
        ),
        ElevatedButton(
          onPressed: () => controller.close(),
          child: const Text('close panel'),
        ),
        ElevatedButton(
          onPressed: () => controller.expand(),
          child: const Text('expand panel'),
        ),
      ],
    );
  }
}

class _SecondView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double circularBoxHeight = 16.0;
    final Size size = MediaQuery.of(context).size;
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: size.height + kToolbarHeight + 44.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(circularBoxHeight), topRight: Radius.circular(circularBoxHeight)),
              border: Border.all(color: Colors.blue),
            ),
            child: const Center(
              child: Text("second"),
            ),
          ),
        );
      },
    );
  }
}
