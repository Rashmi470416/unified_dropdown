import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_dropdown/unified_dropdown.dart';

void main() {
  group('SelectOptions', () {
    test('generateCode turns spaces into slugs', () {
      expect(SelectOptions.generateCode('New Item'), 'new-item');
      expect(SelectOptions.generateCode('  Hello World  '), 'hello-world');
    });

    test('equality uses key, value, and code', () {
      const a = SelectOptions(key: '1', value: 'A', code: 'a');
      const b = SelectOptions(key: '1', value: 'A', code: 'a');
      const c = SelectOptions(key: '2', value: 'A', code: 'a');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('toMap and fromMap round-trip', () {
      const original = SelectOptions(key: '1', value: 'One', code: 'one');
      final restored = SelectOptions.fromMap(original.toMap());
      expect(restored, equals(original));
    });
  });

  group('UnifiedDropdown', () {
    testWidgets('shows hint and opens menu items', (tester) async {
      SelectOptions? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedDropdown(
              isInputField: false,
              fieldHintText: 'Pick one',
              items: const [
                SelectOptions(key: '1', value: 'Alpha', code: 'alpha'),
                SelectOptions(key: '2', value: 'Beta', code: 'beta'),
              ],
              onSelected: (option) => selected = option,
            ),
          ),
        ),
      );

      expect(find.text('Pick one'), findsOneWidget);

      await tester.tap(find.byTooltip('Open options'));
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);

      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();

      expect(selected?.value, 'Beta');
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('clear button resets selection', (tester) async {
      var cleared = false;
      SelectOptions? selected = const SelectOptions(
        key: '1',
        value: 'Alpha',
        code: 'alpha',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return UnifiedDropdown(
                  isInputField: true,
                  initialValue: selected,
                  showClearButton: true,
                  items: const [
                    SelectOptions(key: '1', value: 'Alpha', code: 'alpha'),
                  ],
                  onSelected: (option) {
                    setState(() => selected = option);
                  },
                  onCleared: () {
                    setState(() {
                      cleared = true;
                      selected = null;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Alpha'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear'));
      await tester.pumpAndSettle();

      expect(cleared, isTrue);
    });
  });
}
