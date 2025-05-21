import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

// Order model
class Order {
  final String orderId;
  final String tableName;
  final List<OrderItem> items;
  final double totalPrice;

  Order({
    required this.orderId,
    required this.tableName,
    required this.items,
  }) : totalPrice = items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  factory Order.fromJson(Map<dynamic, dynamic> json) {
    var itemsJson = json['items'] as List<dynamic>? ?? [];
    return Order(
      orderId: json['orderId']?.toString() ?? 'Unknown',
      tableName: json['table']?.toString() ?? 'Unknown', // Changed from tableName to table
      items: itemsJson
          .map((item) {
            try {
              return OrderItem.fromJson(item as Map<dynamic, dynamic>);
            } catch (e) {
              print('Error parsing item: $e');
              return null;
            }
          })
          .where((item) => item != null)
          .cast<OrderItem>()
          .toList(),
    );
  }
}

// OrderItem model
class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<dynamic, dynamic> json) {
    return OrderItem(
      name: json['name']?.toString() ?? 'Unknown',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as int?) ?? 1,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const OrderApp());
}

class OrderApp extends StatelessWidget {
  const OrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const OrderListScreen(),
    );
  }
}

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  OrderListScreenState createState() => OrderListScreenState();
}

class OrderListScreenState extends State<OrderListScreen> {
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref('orders');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Text(
              'Orders Received',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _ordersRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('No orders received yet.'));
          }

          try {
            print('Firebase data: ${snapshot.data!.snapshot.value}');

            Map<dynamic, dynamic> ordersMap =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<Order> orders = ordersMap.entries
                .map((entry) {
                  try {
                    return Order.fromJson(entry.value);
                  } catch (e) {
                    print('Error parsing order ${entry.key}: $e');
                    return null;
                  }
                })
                .where((order) => order != null)
                .cast<Order>()
                .toList();

            if (orders.isEmpty) {
              return const Center(child: Text('No valid orders found.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderCard(order: order);
              },
            );
          } catch (e) {
            return Center(child: Text('Error parsing data: $e'));
          }
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${order.orderId}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Table: ${order.tableName}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Items:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Text(
                    '${item.name} (x${item.quantity}): \$${item.price * item.quantity}',
                    style: const TextStyle(fontSize: 14),
                  ),
                )),
            const SizedBox(height: 8),
            Text(
              'Total Price: \$${order.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE74C3C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}