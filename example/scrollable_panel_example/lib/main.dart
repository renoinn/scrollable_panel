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
      appBar: AppBar(
        title: Text('scrollable panel'),
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
