import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String code;
  final String customerName;
  final String customerAddress;
  final GeoPoint geoPoint;
  final String customerMobile;
  final List products;
  final double totalPrice;
  final double delivery;
  final double tax;
  final double price;
  final double walletAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String date;
  final int items;
  final String deliveryBy;
  final Timestamp timestamp;
  final String status;
  final String paymentID;

  Order(
      {this.customerAddress,
      this.customerMobile,
      this.customerName,
      this.id,
      this.price,
      this.paymentStatus,
      this.paymentMethod,
      this.products,
      this.delivery,
      this.tax,
      this.totalPrice,
      this.date,
      this.deliveryBy,
      this.code,
      this.items,
      this.timestamp,
      this.status,
      this.geoPoint,
      this.walletAmount,
      this.paymentID});

  factory Order.fromFirestore({DocumentSnapshot doc}) {
    Map data = doc.data();

    return Order(
      id: doc.id,
      customerAddress: data['customerAddress'],
      customerMobile: data['customerMobile'],
      customerName: data['customerName'],
      price: data['price'],
      paymentStatus: data['payment'],
      paymentMethod: data['paymentMethod'],
      products: data['products'],
      delivery: data['delivery'],
      tax: data['tax'],
      totalPrice: data['total'],
      date: data['date'],
      deliveryBy: data['deliveryBy'],
      code: data['code'],
      timestamp: data['timestamp'],
      items: data['items'],
      status: data['status'],
      geoPoint: data['location'],
      walletAmount: data['walletAmount'],
      paymentID: data['paymentID'],
    );
  }
}
