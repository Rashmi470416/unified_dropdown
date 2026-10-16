import 'package:flutter_test/flutter_test.dart';
import 'package:unified_dropdown_example/main.dart';

void main() {
  testWidgets('demo shows creatable searchable dropdown', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Unified Dropdown'), findsOneWidget);
    expect(find.text('Type to search or add…'), findsOneWidget);
  });
}
