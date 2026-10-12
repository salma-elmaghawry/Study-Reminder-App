import 'package:flutter_test/flutter_test.dart';
import 'package:local_notifications_app/main.dart';

void main() {
  testWidgets('Home shows the study reminder actions', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Ready to study today?'), findsOneWidget);
    expect(find.text('No reminder set yet'), findsOneWidget);
    expect(find.text('Pick study time'), findsOneWidget);
  });
}
