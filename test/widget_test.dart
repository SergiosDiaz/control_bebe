import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:control_bebe/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ControlBebeApp()));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
