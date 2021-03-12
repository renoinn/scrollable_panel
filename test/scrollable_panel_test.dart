import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_panel/scrollable_panel.dart';

void main() {
  group('PanelController test', () {
    test('ScrollablePanelState not attached', () {
      final panelController = PanelController();
      expect(panelController.isAttached, false);
    });

    testWidgets('ScrollablePanelState is attached', (tester) async {
      final scrollablePanelKey = GlobalKey<ScrollablePanelState>();
      final panelController = PanelController();
      await tester.pumpWidget(ScrollablePanel(
        key: scrollablePanelKey,
        controller: panelController,
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
        ),
      ));

      expect(panelController.isAttached, true);
      expect(panelController.isOpen, true);
    });

    testWidgets('PanelState is Expand call after panelController.expand()', (tester) async {
      final scrollablePanelKey = GlobalKey<ScrollablePanelState>();
      final panelController = PanelController();
      await tester.pumpWidget(ScrollablePanel(
        key: scrollablePanelKey,
        controller: panelController,
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                for (int i = 0; i < 20; i++) Text(i.toString()),
              ],
            ),
          ),
        ),
      ));

      panelController.expand();
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(panelController.isExpand, true);
    });
  });
}
