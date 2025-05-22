import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dem_app/main.dart';

void main() {
  testWidgets('OrderApp displays orders from Firebase', (WidgetTester tester) async {
    await tester.pumpWidget(const OrderApp());
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.text('Orders Received'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);

    if (find.text('No orders received yet.').evaluate().isEmpty &&
        find.text('No valid orders found.').evaluate().isEmpty) {
      expect(find.text('Order ID: ORD-524942'), findsOneWidget);
      expect(find.text('Table: Table2'), findsOneWidget);
      expect(find.text('Margherita Pizza (x2): \$25.98'), findsOneWidget);
      expect(find.text('Total Price: \$25.98'), findsOneWidget);
    }
  });
}