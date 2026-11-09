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

  testWidgets('MonqizApp boots and renders navigation shell with all 5 tabs including Settings', (WidgetTester tester) async {
    await tester.pumpWidget(const MonqizApp());
    await tester.pumpAndSettle();

    // Verify all 5 navigation tabs are rendered in bottom bar
    expect(find.text('الحالات العاجلة'), findsWidgets);
    expect(find.text('المستشفيات'), findsWidgets);
    expect(find.text('طلب دم'), findsWidgets);
    expect(find.text('البطاقة الرقمية'), findsWidgets);
    expect(find.text('الإعدادات'), findsWidgets);
  });
}
