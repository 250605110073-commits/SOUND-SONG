import 'package:flutter_test/flutter_test.dart';
import 'package:soundwave/main.dart';

void main() {
  testWidgets('SoundWave app menampilkan navigasi utama', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundWaveApp());

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
  });
}
