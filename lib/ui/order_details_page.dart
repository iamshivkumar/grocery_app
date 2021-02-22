import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grocery_app/core/futures/orders_list_future_provider.dart';
import 'package:grocery_app/core/futures/wallet_future_provider.dart';
import 'package:grocery_app/core/models/cartProduct.dart';
import 'package:grocery_app/core/models/order.dart';
import 'package:grocery_app/core/view_models/checkout_view_model/checkout_view_model_provider.dart';
import 'package:grocery_app/ui/widgets/two_text_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;
  const OrderDetailsPage({Key key, this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: ListView(
        padding: EdgeInsets.all(4),
        children: [
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Products',
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).primaryColor),
                  ),
                ),
                Column(
                  children: order.products.map((e) {
                    var product = CartProduct.fromJson(e);
                    return ListTile(
                      title: Text(product.name),
                      leading: Image.network(product.image),
                      subtitle: Text(product.qt.toString() +
                          " Items x ₹" +
                          product.price.toString()),
                      trailing: Text(
                        "₹" + (product.qt * product.price).toString(),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Order Summary',
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).primaryColor),
                  ),
                ),
                TwoTextRow(
                    text1: "Items (6)", text2: '₹' + order.price.toString()),
                TwoTextRow(
                    text1: "Delivery", text2: '₹' + order.delivery.toString()),
                TwoTextRow(
                    text1: 'Service Tax', text2: '₹' + order.tax.toString()),
                TwoTextRow(
                    text1: "Wallet Amount",
                    text2: '₹' + order.walletAmount.toString()),
                TwoTextRow(
                    text1: 'Total Price',
                    text2: '₹' + order.totalPrice.toString())
              ],
            ),
          ),
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Delivery Details',
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).primaryColor),
                  ),
                ),
                TwoTextRow(text1: "Status", text2: order.status),
                TwoTextRow(text1: "Delivery Date", text2: order.date),
                TwoTextRow(text1: 'Delivery By', text2: order.deliveryBy),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Delivery Address'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 2,
                    child: GoogleMap(
                      liteModeEnabled: true,
                      key: Key(order.customerAddress),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                            order.geoPoint.latitude, order.geoPoint.longitude),
                        zoom: 16,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId("1"),
                          position: LatLng(order.geoPoint.latitude,
                              order.geoPoint.longitude),
                        ),
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(order.customerAddress),
                ),
              ],
            ),
          ),
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Payment',
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).primaryColor),
                  ),
                ),
                TwoTextRow(text1: "Status", text2: order.paymentStatus),
                TwoTextRow(text1: "Payment Method", text2: order.paymentMethod),
              ],
            ),
          ),
          order.status != "Delivered" && order.status != "Cancelled"
              ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: MaterialButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title:
                              Text('Are you sure you want cancel this order?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('No'),
                            ),
                            MaterialButton(
                              onPressed: () async {
                                Navigator.pop(context);

                                await context
                                    .read(checkoutViewModelProvider)
                                    .cancelOrder(
                                        orderId: order.id,
                                        paymentID: order.paymentID,
                                        paymentMethod: order.paymentMethod,
                                        price: order.totalPrice,
                                        walletAmount: order.walletAmount);
                                context.refresh(ordersListFutureProvider);
                                context.refresh(walletFutureProvider);
                                Navigator.pop(context);
                              },
                              color: Theme.of(context).accentColor,
                              child: Text('Yes'),
                            ),
                          ],
                        ),
                      );
                    },
                    colorBrightness: Brightness.dark,
                    color: Theme.of(context).accentColor,
                    child: Text('CANCEL ORDER'),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

class WhiteCard extends StatelessWidget {
  final Widget child;
  WhiteCard({this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: Colors.white,
        child: Padding(padding: const EdgeInsets.all(12.0), child: child),
      ),
    );
  }
}
