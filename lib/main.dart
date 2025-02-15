import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nks_admin/AdminDash.dart';
import 'package:nks_admin/firebase_options.dart';
import 'package:nks_admin/OrderList.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      home: OrderListScreen(),
    );
  }
}

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> orders = [];
  late TabController _tabController;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        // Store or send the token to your server here
      } else {
        print('Failed to retrieve FCM token.');
      }
    } catch (e) {
      print('Error retrieving FCM token: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    getToken();
    fetchOrders();
    deleteExpiredOrders();
  }

  void deleteExpiredOrders() async {
    final firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore
        .collection('Orders')
        .where('deletionTime', isLessThan: DateTime.now())
        .get();

    for (var doc in snapshot.docs) {
      await firestore.collection('Orders').doc(doc.id).delete();
    }
  }

  void markOrderAsCompleted(String orderId) async {
    print('sar hello');

    try {
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
          .update({'deliveryCompleted': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery marked as completed')),
      );

      fetchOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating delivery: $e')),
      );
    }
  }

  Future<void> fetchOrders() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('Orders').get();
      final fetchedOrders = snapshot.docs.map((doc) {
        return {
          'orderId': doc['orderId'],
          'latitude': doc['latitude'],
          'longitude': doc['longitude'],
          'customerDetails': doc['customerDetails'],
          'timestamp': doc['timestamp'],
          'paymentMethod': doc['paymentMethod'],
          'userName': doc['userName'],
          'userId': doc['userId'],
          'products': doc['products'],
          'shippingPrice': doc['shipping price'],
          'instructions': doc['instructions'],
          'shippingMethod': doc['shipping method'],
          'deliveryCompleted': doc['deliveryCompleted'] ?? false,
          // Fetching this field
        };
      }).toList();

      setState(() {
        orders = fetchedOrders;
      });
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> pendingOrders =
        orders.where((order) => !order['deliveryCompleted']).toList();
    List<Map<String, dynamic>> completedOrders =
        orders.where((order) => order['deliveryCompleted']).toList();

    return Scaffold(
        backgroundColor: const Color(0xFFE3EFFE),
        appBar: AppBar(
          backgroundColor: Colors.white10,
          title: Text(
            'Pending: ${pendingOrders.length} | Completed: ${completedOrders.length}',
            style:
                GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          bottom: TabBar(
              controller: _tabController,
              // labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF464E47),

              // controller: _tabController,indicatorColor: Color(0xFFF06449),
              tabs: [
                Tab(
                  child: Text(
                    'Pending',
                    style: GoogleFonts.kanit(
                        color: Color(0xFF6C91C2),
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Tab(
                    child: Text(
                  'Completed',
                  style: GoogleFonts.kanit(
                      color: Color(0xFFB9314F),
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                )),
                Tab(
                  child: Text(
                    'Admin Dash',
                    style: GoogleFonts.kanit(
                        color: Color(0xFF70A0AF),
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                )
              ]),
          leadingWidth: 100,
          leading: GestureDetector(
              onTap: () {
                print('object');
                print(pendingOrders.length);
                print(completedOrders.length);
                setState(() {
                  fetchOrders();
                });
              },
              child: const Icon(
                Icons.directions_bike_rounded,
                size: 30,
              )),
        ),
        body: Stack(
          children: [
            TabBarView(controller: _tabController, children: [
              pendingOrders.isEmpty
                  ? Center(
                      child: Text(
                      'No Orders Pending',
                      style: GoogleFonts.manrope(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ))
                  : OrderListView(
                      orders: pendingOrders,
                      markOrderAsCompleted: markOrderAsCompleted,
                    ),
              completedOrders.isEmpty
                  ? Center(
                      child: Text(
                      'No Orders Completed',
                      style: GoogleFonts.manrope(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ))
                  : OrderListView(
                      orders: completedOrders,
                      markOrderAsCompleted: null,
                    ),
              Admindash()
            ]),
            Positioned(
                right: 10,
                bottom: 70,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(),
                    onPressed: () {
                      setState(() {
                        fetchOrders();
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          'Refresh',
                          style: GoogleFonts.kanit(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Colors.black),
                        ),
                      ],
                    ))),
          ],
        ));
  }
}
