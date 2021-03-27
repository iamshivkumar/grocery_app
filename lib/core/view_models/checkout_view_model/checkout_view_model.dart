import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_app/core/models/address.dart';
import 'package:grocery_app/core/models/cartProduct.dart';
import 'package:grocery_app/core/models/settings.dart';
import 'package:grocery_app/core/service/date.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CheckoutViewModel extends ChangeNotifier {
  final List<LocationAddress> locationAddressList;
  final List<CartProduct> cartProducts;
  final double price;
  final int items;
  final StoreSettings settings;
  CheckoutViewModel(
      {this.locationAddressList,
      this.cartProducts,
      this.price,
      this.items,
      this.settings});

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User _user = FirebaseAuth.instance.currentUser;
  int currentStep = 0;
  String deliveryDay;
  Date _date = Date();
  String deliveryBy;
  String _deliveryByStartTime;
  LocationAddress locationAddress;
  String paymentMethod;

  double get serviceTax => double.parse(
      (price * settings.serviceTaxPercentage / 100).toStringAsFixed(1));

  double walletAmount = 0;
  double remainedWalletAmount = 0;

  double get total =>
      double.parse(
          (price + settings.deliveryCharge + serviceTax).toStringAsFixed(1)) -
      walletAmount;

  bool get isOptionsCompleted =>
      deliveryBy != null && deliveryDay != null && locationAddress != null;

  void setStep(int value) {
    currentStep = value;
    notifyListeners();
  }

  void backStep() {
    currentStep--;
    notifyListeners();
  }

  void nextStep() {
    currentStep++;
    notifyListeners();
  }

  void setDeliveryDay(String value) {
    deliveryDay = value;
    if (value == _date.activeDate(0) && _deliveryByStartTime != null) {
      if (!_date.deliverable(value: _deliveryByStartTime)) {
        _deliveryByStartTime = null;
        deliveryBy = null;
      }
    }
    notifyListeners();
  }

  void setDeliveryBy({String range, String value}) {
    deliveryBy = range;
    _deliveryByStartTime = value;
    notifyListeners();
  }

  void setLocationAddress(LocationAddress value) {
    locationAddress = value;
    notifyListeners();
  }

  void setPaymentMethod(String value) {
    paymentMethod = value;
    notifyListeners();
  }

  void useWallet({double amount}) {
    if (amount <= total) {
      walletAmount = amount;
    } else {
      remainedWalletAmount = amount - total;
      walletAmount = total;
    }
    notifyListeners();
  }

  void cancelUsingWallet() {
    walletAmount = 0;
    remainedWalletAmount = 0;
    notifyListeners();
  }

  Razorpay _razorpay = Razorpay();

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: response.message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: response.walletName);
  }

//HDLsL5DxJOc4dxdk0lrQTww2
  Future openCheckout(double amount) async {
    var options = {
      'key': 'rzp_test_KmPzyFK6pErbkC',
      'amount': (amount * 100).toInt(),
      'name': 'Grocery APP',
      'description': 'Fruits and Beries',
      'prefill': {
        'contact': _user.phoneNumber,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Fluttertoast.showToast(msg: e.code);
    }
  }

  String getCode(int length) {
    String _chars = '1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(
          _rnd.nextInt(_chars.length),
        ),
      ),
    );
  }

  Future _placeOrder({bool paid, String paymentID}) async {
    String token = await FirebaseMessaging.instance.getToken();
    try {
      _firestore.collection('orders').add(
        {
          'customerId': _user.uid,
          'customerName': "Shivkumar Konade",
          'customerMobile': _user.phoneNumber,
          'customerAddress': locationAddress.value,
          'price': price,
          'items': items,
          'payment': paid ? "Paid" : "Not Paid",
          'paymentMethod': paymentMethod,
          'products': cartProducts.map((e) => e.toJson()).toList(),
          'delivery': settings.deliveryCharge,
          'tax': serviceTax,
          'total': total,
          'date': deliveryDay,
          'deliveryBy': deliveryBy,
          'timestamp': Timestamp.now(),
          'code': getCode(6),
          'status': "Pending",
          "location":
              GeoPoint(locationAddress.latitude, locationAddress.longitude),
          "paymentID": paymentID ?? "-",
          "walletAmount": walletAmount,
          "token": token,
        },
      );
      Fluttertoast.showToast(msg: "Order Successful.");
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Something error try later. if amount debited Contact us");
      return;
    }
    cartProducts.forEach((element) {
      _firestore
          .collection("products")
          .doc(element.id)
          .update({"quantity": FieldValue.increment(-element.qt)});
    });

    if (walletAmount != 0) {
      _firestore.collection('wallets').doc(_user.uid).update(
        {
          "amount": remainedWalletAmount,
        },
      );
    }
  }

  void payAndOrder({VoidCallback callback}) async {
    if (paymentMethod == 'Razorpay' && total != 0) {
      await openCheckout(total);
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
          (PaymentSuccessResponse response) {
        Fluttertoast.showToast(msg: "Payment Successful.");
        _placeOrder(paid: true, paymentID: response.paymentId);
        callback();
      });
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } else if (total == 0) {
      _placeOrder(paid: true);
      callback();
    } else {
      _placeOrder(paid: false);
      callback();
    }
  }

  Future<void> cancelOrder(
      {String orderId,
      double price,
      String paymentMethod,
      double walletAmount,
      String paymentID}) async {
    _firestore
        .collection("orders")
        .doc(orderId)
        .update({"status": "Cancelled"});
    Fluttertoast.showToast(msg: "Order Cancled");
    if (paymentMethod == "Razorpay") {
      var docRef = _firestore.collection("wallets").doc(_user.uid);
      docRef.get().then((value) {
        if (value.exists) {
          docRef.update({
            "amount": FieldValue.increment(price + walletAmount),
            "payments": FieldValue.arrayUnion([
              {
                "id": paymentID,
                "amount": price + walletAmount,
              }
            ]),
          });
        } else {
          docRef.set({
            "amount": price + walletAmount,
            "payments": [
              {
                "id": paymentID,
                "amount": price + walletAmount,
              }
            ],
            "refundRequested": false,
          });
        }
      });
      Fluttertoast.showToast(
          msg:
              "Amount added to your wallet. You can request for refund (Profile>>Refund)",
          timeInSecForIosWeb: 1);
    } else if (walletAmount != 0) {
      _firestore.collection("wallets").doc(_user.uid).update(
        {
          "amount": FieldValue.increment(walletAmount),
          "payments": FieldValue.arrayUnion(
            [
              {
                "id": paymentID,
                "amount": walletAmount,
              }
            ],
          ),
        },
      );
    }
  }
}
