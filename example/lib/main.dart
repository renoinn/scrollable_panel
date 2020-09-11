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

class __AnimatedAppBarState extends State<_AnimatedAppBar> {
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _animation = ColorTween(
      begin: Colors.transparent,
      end: Colors.red,
    ).animate(widget.panelController.animation);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.panelController.animation,
      builder: (context, child) {
        return Container(
          height: kToolbarHeight,
          color: _animation.value,
          child: SafeArea(child: Text('scrollable panel')),
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
