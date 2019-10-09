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
  final minPanelSize = 0.25;
  final maxPanelSize = 1.0;
  PanelController _panelController;
  ValueNotifier<double> _valueNotifier;

  @override
  void initState() {
    super.initState();
    _valueNotifier = ValueNotifier<double>(minPanelSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          _FirstView(),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double availablePixels = maxPanelSize * constraints.biggest.height;
              _panelController = PanelController(
                minPanelSize: minPanelSize,
                maxPanelSize: maxPanelSize,
                availablePixels: availablePixels,
                extent: _valueNotifier,
              );
              return ScrollablePanel(
                controller: _panelController,
                child: _SecondView(),
              );
            }
          )
        ],
      )
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
    return Container(
      height: size.height + 200,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(circularBoxHeight), topRight: Radius.circular(circularBoxHeight)),
        border: Border.all(color: Colors.white),
      ),
      child: Center(child: Text("second")),
    );
  }
}