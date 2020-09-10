# scrollable_panel

drag to expand and then can scroll contents.
similar "Nearby spots" panel on google map app.

https://pub.dev/packages/scrollable_panel

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
