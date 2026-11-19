import 'package:flutter_test/flutter_test.dart';
import 'package:monqiz_app/core/di/injection_container.dart';
import 'package:monqiz_app/main.dart';

void main() {
  setUp(() async {
    await sl.reset();
    await initDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('MonqizApp boots and renders navigation shell with all 4 tabs including Profile', (WidgetTester tester) async {
    await tester.pumpWidget(const MonqizApp());
    await tester.pumpAndSettle();

    // Verify the Week 2 4-tab navigation layout
    expect(find.text('طلبات الدم'), findsWidgets);
    expect(find.text('نشاطاتي'), findsWidgets);
    expect(find.text('المستشفيات'), findsWidgets);
    expect(find.text('حسابي'), findsWidgets);
  });
}
