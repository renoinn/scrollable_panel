# scrollable_panel

drag to expand and then can scroll contents.

![](https://github.com/renoinn/scrollable_panel/blob/master/panel_movie.gif)

## Usage

```dart
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
```
