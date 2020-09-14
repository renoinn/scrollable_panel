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
  MyHomePage({Key key, this.title}) : super(key: key);

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
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: _AnimatedAppBar(
          panelController: _panelController,
        ),
      ),
      body: Stack(
        children: <Widget>[
          InkWell(
            onTap: () {
              _panelController.toDefault();
            },
            child: _FirstView(),
          ),
          ScrollablePanel(
            controller: _panelController,
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
    Key key,
    this.panelController,
  }) : super(key: key);

  final PanelController panelController;

  @override
  __AnimatedAppBarState createState() => __AnimatedAppBarState();
}

class __AnimatedAppBarState extends State<_AnimatedAppBar> with SingleTickerProviderStateMixin {
  Animation _animation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    widget.panelController.animation.addListener(() {
      if (widget.panelController.animation.value >= 0.8) {
        _animationController.value = (0.2 - (1.0 - widget.panelController.animation.value)) * 5;
      } else {
        _animationController.value = 0;
      }
    });
    _animation = ColorTween(
      begin: Colors.transparent,
      end: Colors.red,
    ).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          color: _animation.value,
          child: SafeArea(
            bottom: false,
            top: true,
            child: Container(
              height: kToolbarHeight,
              child: Text('scrollable panel'),
            ),
          ),
        );
      },
    );
  }
}

class _FirstView extends StatelessWidget {
  const _FirstView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("first"),
    );
  }
}

class _SecondView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double circularBoxHeight = 16.0;
    final Size size = MediaQuery.of(context).size;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
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
            child: Center(child: Text("second")),
          ),
        );
      },
    );
  }
}
