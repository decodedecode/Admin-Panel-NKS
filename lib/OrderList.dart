import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderListView extends StatefulWidget {
  final List<Map<String, dynamic>> orders;
  final Function(String)? markOrderAsCompleted;

  const OrderListView(
      {super.key, required this.orders, this.markOrderAsCompleted});

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return widget.orders.isEmpty
        ? const Center(
            child: CircularProgressIndicator()) // Show loading indicator
        : Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ListView.builder(
              itemCount: widget.orders.length,
              itemBuilder: (context, index) {
                final order = widget.orders[index];
                final products = order['products'] as List<dynamic>;

                double totalPrice = 0;
                for (var product in products) {
                  final price =
                      double.tryParse(product['price']?.toString() ?? '0') ??
                          0.0;
                  final quantity =
                      int.tryParse(product['quantity']?.toString() ?? '0') ?? 0;
                  totalPrice += price * quantity;
                }

                final shippingPrice = double.tryParse(
                        order['shippingPrice']?.toString() ?? '0') ??
                    0.0;
                final totalAmount = totalPrice + shippingPrice;

                final customerDetails = order['customerDetails'] ?? {};
                final username = order['userName'] ?? 'Unknown User';
                final customerName = customerDetails['name'] ?? 'Not Provided';
                final address = customerDetails['address'] ?? 'Not Provided';
                final phone = customerDetails['phone'] ?? 'Not Provided';
                final pincode = customerDetails['pincode'] ?? 'Not Provided';
                final shippingMethod =
                    order['shippingMethod'] ?? 'Not Provided';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Order #${order['orderId']}',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.8,
                          color: Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User: $username',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Customer Name: $customerName',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Address: $address',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Phone: $phone',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Pincode: $pincode',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Shipping Method: $shippingMethod',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Shipping Price: ₹$shippingPrice',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Order Summary:',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...products.map((product) {
                              final name = product['name'] ?? 'Unnamed Product';
                              final brand = product['brand'] ?? 'Best One';
                              final price = double.tryParse(
                                      product['price']?.toString() ?? '0') ??
                                  0.0;
                              final quantity = int.tryParse(
                                      product['quantity']?.toString() ?? '0') ??
                                  0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$brand $name',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '₹${(price * quantity).toStringAsFixed(2)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total: ₹ ${totalAmount.toStringAsFixed(2)}',
                                  // 'Total: ₹ ${totalAmount.toStringAsFixed(2)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    print('sar object');
                                    if (order['deliveryCompleted'] != true) {
                                      try {
                                        String today = DateFormat('dd-MM-yyyy')
                                            .format(DateTime.now());
                                        DocumentReference dailyStatsRef =
                                            firestore
                                                .collection('Admin')
                                                .doc('OrderStatistics')
                                                .collection('DailyStats')
                                                .doc(today);

                                        await firestore.runTransaction(
                                            (transaction) async {
                                          transaction.update(
                                              firestore
                                                  .collection('Admin')
                                                  .doc('AdminDash'),
                                              {
                                                'Total_Delivered':
                                                    FieldValue.increment(1),
                                                'Total_Income':
                                                    FieldValue.increment(
                                                        totalPrice),
                                              });

                                          transaction.set(
                                              dailyStatsRef,
                                              {
                                                'Delivered':
                                                    FieldValue.increment(1),
                                                'Income': FieldValue.increment(
                                                    totalPrice),
                                              },
                                              SetOptions(merge: true));
                                        });

                                        await firestore
                                            .collection('Orders')
                                            .doc(order['orderId'])
                                            .update({
                                          'deliveryCompleted': true,
                                          'deletionTime': DateTime.now()
                                              .add(Duration(days: 1))
                                        });

                                        setState(() {
                                          widget.orders.removeAt(index);
                                        });

                                        if (widget.markOrderAsCompleted !=
                                            null) {
                                          widget.markOrderAsCompleted!(
                                              order['orderId']);
                                        }

                                        await Future.delayed(Duration(days: 1));
                                        await firestore
                                            .collection('Orders')
                                            .doc(order['orderId'])
                                            .delete();

                                        // ScaffoldMessenger.of(context).showSnackBar(
                                        //   const SnackBar(content: Text('Delivery marked as completed')),
                                        // );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error updating delivery: $e')),
                                        );
                                      }
                                    } else if (order['deliveryCompleted'] ==
                                        true) {
                                      try {
                                        await firestore
                                            .collection('Admin')
                                            .doc('AdminDash')
                                            .update({
                                          'Total_Income':
                                              FieldValue.increment(-totalPrice)
                                        });

                                        await firestore
                                            .collection('Admin')
                                            .doc('AdminDash')
                                            .update({
                                          'Total_Delivered':
                                              FieldValue.increment(-1)
                                        });
                                        await firestore
                                            .collection('Orders')
                                            .doc(order[
                                                'orderId']) // Ensure orderId is the document ID
                                            .update(
                                                {'deliveryCompleted': false});

                                        // ScaffoldMessenger.of(context).showSnackBar(
                                        //   const SnackBar(content: Text('Delivery marked as completed')),
                                        // );

                                        setState(() {
                                          widget.orders.removeAt(
                                              index); // Remove order from pending list
                                        });

                                        // Notify parent widget if a callback is provided
                                        if (widget.markOrderAsCompleted !=
                                            null) {
                                          widget.markOrderAsCompleted!(
                                              order['orderId']);
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error updating delivery: $e')),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        order['deliveryCompleted'] == true
                                            ? const Color(0xFFB9314F)
                                            : const Color(0xFF6C91C2),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 30),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    order['deliveryCompleted'] == true
                                        ? 'Delivered'
                                        : 'Complete Delivery',
                                    style: GoogleFonts.kanit(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                order['deliveryCompleted'] != true
                                    ? GestureDetector(
                                        onTap: () async {
                                          try {
                                            // await firestore.collection('Admin').doc('AdminDash').update({'Total_Cancelled' : FieldValue.increment(1)});
                                            String today =
                                                DateFormat('dd-MM-yyyy')
                                                    .format(DateTime.now());
                                            DocumentReference dailyStatsRef =
                                                firestore
                                                    .collection('Admin')
                                                    .doc('OrderStatistics')
                                                    .collection('DailyStats')
                                                    .doc(today);

                                            await firestore.runTransaction(
                                                (transaction) async {
                                              transaction.update(
                                                  firestore
                                                      .collection('Admin')
                                                      .doc('AdminDash'),
                                                  {
                                                    'Total_Cancelled':
                                                        FieldValue.increment(1),
                                                  });

                                              transaction.set(
                                                  dailyStatsRef,
                                                  {
                                                    'Cancelled':
                                                        FieldValue.increment(1),
                                                  },
                                                  SetOptions(merge: true));
                                            });

                                            await firestore
                                                .collection('Orders')
                                                .doc(order['orderId'])
                                                .delete(); // Await the deletion

                                            setState(() {
                                              widget.orders.removeAt(
                                                  index); // Remove from UI only after Firestore deletion
                                            });

                                            // Notify parent widget if a callback is provided
                                            if (widget.markOrderAsCompleted !=
                                                null) {
                                              widget.markOrderAsCompleted!(
                                                  order['orderId']);
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error deleting order: $e')),
                                            );
                                          }
                                        },
                                        child: Icon(
                                          Icons.cancel_outlined,
                                          size: 35,
                                          color: Color(0xFFEF959D),
                                        ))
                                    : Container()
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
  }
}
