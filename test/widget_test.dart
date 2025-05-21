import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dem_app/main.dart'; // Update to match your project name

void main() {
  testWidgets('OrderApp displays orders', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const OrderApp());

    // Verify that the app displays the "Orders Received" title.
    expect(find.text('Orders Received'), findsOneWidget);

    // Verify that the sample orders are displayed.
    expect(find.text('Order ID: ORD001'), findsOneWidget);
    expect(find.text('Table: Table1'), findsOneWidget);
    expect(find.text('Pizza (x2): \$25.98'), findsOneWidget);
    expect(find.text('Soda (x3): \$5.97'), findsOneWidget);
    expect(find.text('Order ID: ORD002'), findsOneWidget);
    expect(find.text('Table: Table2'), findsOneWidget);
    expect(find.text('Burger (x1): \$8.99'), findsOneWidget);
    expect(find.text('Fries (x2): \$7.98'), findsOneWidget);
  });
}