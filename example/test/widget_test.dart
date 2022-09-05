import 'package:flutter_test/flutter_test.dart';
import 'package:dolbyio_getting_started/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FlutterScreen());
  });
}
