# scrollable_panel
[![pub package](https://img.shields.io/pub/v/scrollable_panel.svg)](https://pub.dev/packages/scrollable_panel)

drag to expand and then can scroll contents.
similar "Nearby spots" panel on google map app.

https://pub.dev/packages/scrollable_panel

![](https://github.com/renoinn/scrollable_panel/blob/master/panel_movie.gif)

## Panel Properties

| Properties | Data Type | Description |
|--|--|--|
| builder | ScrollableWidgetBuilder | builder for inner panel view. ScrollableWidgetBuilder type define in draggable_scrollable_sheet.dart. provide PanelScrollController that extends ScrollController. |
| controller | PanelController | control panel from some interaction like button. |
| defaultPanelState | PanelState | set default panel state. (default value PanelState.open) |
| defaultPanelSize | double | set default panel height factor (default value 0.25) |
| minPanelSize | double | set minimum panel height factor. (default value 0) |
| maxPanelSize | double | set maximum panel height factor. (default value 1.0) |
| onOpen | VoidCallback | if non-null, this callback is called when panel state become open |
| onClose | VoidCallback | if non-null, this callback is called when panel state become close |
| onExpand | VoidCallback | if non-null, this callback is called when panel state become expand |

## PanelController actions

| Action | Data Type | Description |
|--|--|--|
| open | void | open panel. panel animate to defaultPanelSize. |
| expand | void | expand panel. panel animate to maxPanelSize. |
| close | void | close panel. panel animate to minPanelSize. |
| animateTo | double | animate panel to value height. |

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

- ~write README.md and dartdoc~
- ~null-safety support~
- ~write test code~
- add `List<double> anchor` property to use multi snapping point.
