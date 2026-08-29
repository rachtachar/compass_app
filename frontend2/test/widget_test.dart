import 'package:flutter_test/flutter_test.dart';
import 'package:frontend2/main.dart';

void main() {
  testWidgets('App renders OIDC client screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CompassOidcApp());
    await tester.pumpAndSettle();
    expect(find.text('Compass OIDC • Frontend 2'), findsOneWidget);
    expect(find.text('Sign in with OIDC (django-oidc-provider)'), findsOneWidget);
  });
}
