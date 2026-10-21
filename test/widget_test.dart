
import 'package:flutter_test/flutter_test.dart';
import 'package:soundwave/main.dart';

void main() {
  testWidgets('SOUNDSONG app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SOUNDSONGApp());

    expect(find.text('SOUNDSONG'), findsOneWidget);
  });
}
