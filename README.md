# scrollable_panel
[![pub package](https://img.shields.io/pub/v/scrollable_panel.svg)](https://pub.dev/packages/scrollable_panel)

drag to expand and then can scroll contents.
similar "Nearby spots" panel on google map app.

https://pub.dev/packages/scrollable_panel

![](https://github.com/renoinn/scrollable_panel/blob/master/panel_movie.gif)

## Panel Properties

| Properties | Data Type | Description |
|--|--|--|
| builder | ScrollableWidgetBuilder |  |
| controller | PanelController |  |
| defaultPanelState | PanelState | (default value PanelState.open) |
| defaultPanelSize | double | (default value 0.25) |
| minPanelSize | double | (default value 0) |
| maxPanelSize | double | (default value 1.0) |
| onOpen | VoidCallback | |
| onClose | VoidCallback | |
| onExpand | VoidCallback | |

## PanelController actions

| Action | Data Type | Description |
|--|--|--|
| open | void |  |
| expand | void |  |
| close | void |  |
| animateTo | double | (default value 0.25) |

## Usage

```dart
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
```

## TODO

- Android embed v2 migration
- write README.md and dartdoc
- null-safety support
- add `List<double> anchor` property to use multi snapping point.