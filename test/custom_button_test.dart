import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';

void main() {
  group('CusttomButton Tests', () {
    testWidgets('Deve chamar chamar o onPressed quando o botäo for clicado',
        (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomButton(
              text: "Doar",
              onPressed: () {
                wasPressed = true;
              }),
        ),
        color: Colors.green,
      ));

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();

      expect(wasPressed, true);
    });

    testWidgets('Deve respeitar as propriedades do isFullWidth',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: "Participar ",
            onPressed: () {},
            isFullWidth: true,
          ),
        ),
      ));

      final sizedBoxFinder = find.byType(SizedBox);
      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.width, double.infinity);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: "Participar",
            onPressed: () {},
            isFullWidth: false,
          ),
        ),
      ));

      final sizedBoxFinder2 = find.byType(SizedBox);
      final sizeBox = tester.widget<SizedBox>(sizedBoxFinder2);
      expect(sizeBox.width, null);
    });

    testWidgets('Deve aplicar o estilo visual corretamente',
        (WidgetTester tester) async {
      const testColor = Colors.green;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: "Doar",
            onPressed: () {},
            color: testColor,
          ),
        ),
      ));

      final elavateButtonFinder = find.byType(ElevatedButton);
      final elevatedButton = tester.widget<ElevatedButton>(elavateButtonFinder);

      // Check background color
      expect(elevatedButton.style?.backgroundColor?.resolve({}), testColor);

      // Check padding
      expect(
        elevatedButton.style?.padding?.resolve({}),
        EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      );

      // Check for rounded edges
      final shape =
          elevatedButton.style?.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(shape?.borderRadius, BorderRadius.circular(8));

      // Check the button text
      final textFinder = find.text("Doar");
      expect(textFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, 16);
      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });
  });
}
