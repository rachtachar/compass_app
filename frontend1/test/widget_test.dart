import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend1/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CompassJwtApp());
    await tester.pumpAndSettle();
    expect(find.text('Compass Travel'), findsOneWidget);
    expect(find.text('Sign In via JWT'), findsOneWidget);
  });
}
