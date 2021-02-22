import 'package:flutter/material.dart';
import 'package:grocery_app/core/models/order.dart';
import 'package:grocery_app/core/service/date.dart';
import 'package:grocery_app/ui/widgets/two_text_row.dart';
import '../order_details_page.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({Key key, this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(
                key: Key(order.id),
                order: order,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TwoTextRow(
                  text1: "Delivery Code: "+order.code,
                  text2: Date().datetime(order.timestamp),
                ),
                Divider(
                  height: 0.5,
                ),
                TwoTextRow(
                  text1: "Order Status",
                  text2: order.status,
                ),
                TwoTextRow(
                  text1: "Items",
                  text2: "${order.items} Items purchased",
                ),
                TwoTextRow(
                  text1: "Price",
                  text2: "₹" + order.totalPrice.toString(),
                ),
                TwoTextRow(
                  text1: "Payment (${order.paymentMethod})",
                  text2: order.paymentStatus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
