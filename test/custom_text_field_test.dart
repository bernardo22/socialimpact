// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';

void main() {
  late TextEditingController controller;

  setUp(() {
    controller = TextEditingController();
  });

  tearDown(() {
    controller.dispose();
  });

  group('CustomTextField Tests', () {
    testWidgets('Deve retornar erro quando o campo obrigatório estiver vazio',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: "Nome",
              isRequired: true,
            ),
          ),
        ),
      );

      final formField = find.byType(TextFormField);
      final textFormField = tester.widget<TextFormField>(formField);
      final validator = textFormField.validator;

      expect(validator!(""), "O campo \"Nome\" é obrigatório.");
      expect(validator(null), "O campo \"Nome\" é obrigatório.");
    });

    testWidgets('Deve retornar erro se o formato do email for inválido',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: "E-mail",
              isRequired: true,
              isEmail: true,
            ),
          ),
        ),
      );

      final formField = find.byType(TextFormField);
      final textFormField = tester.widget<TextFormField>(formField);
      final validator = textFormField.validator;

      expect(validator!("Email Invalido"), "Insira um email válido.");
      expect(validator("test@example.com"), isNull);
    });

    testWidgets(
        'Deve alternar o ícone de visibilidade para o campo de senha palavra-passe',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: "Palavra-passe",
              obscureText: true,
              enableVisibilityToggle: true,
            ),
          ),
        ),
      );

      // Check for inicial state of the icon
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);

      // Tap the icon to toggle visibility
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Check the state after the toggle
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      //Test interaction with the field to confirm functionality
      await tester.enterText(find.byType(TextFormField), "test123");
      expect(controller.text, "test123");
    });
  });
}
