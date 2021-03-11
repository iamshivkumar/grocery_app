import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grocery_app/core/service/date.dart';
import 'package:grocery_app/core/streams/wallet_stream_provider.dart';
import 'package:grocery_app/core/view_models/cart_view_model/cart_view_model_provider.dart';
import 'package:grocery_app/core/view_models/checkout_view_model/checkout_view_model_provider.dart';
import 'package:grocery_app/ui/widgets/custom_radio_listtile.dart';
import 'package:grocery_app/ui/widgets/two_text_row.dart';

class CheckoutPage extends StatelessWidget {
  final Date date = Date();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        var checkoutModel = watch(checkoutViewModelProvider);
        var walletFuture = watch(walletStreamProvider);
        return Scaffold(
          appBar: AppBar(
            title: Text('Place Order'),
          ),
          body: Stepper(
            currentStep: checkoutModel.currentStep,
            onStepTapped: (value) {
              if ((value == 1 || value == 2) &&
                  !checkoutModel.isOptionsCompleted) {
              } else
                checkoutModel.setStep(value);
            },
            controlsBuilder: (context, {onStepCancel, onStepContinue}) =>
                Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  MaterialButton(
                    colorBrightness: Brightness.dark,
                    onPressed: checkoutModel.currentStep == 0 &&
                                checkoutModel.isOptionsCompleted ||
                            checkoutModel.currentStep == 1 ||
                            checkoutModel.currentStep == 2 &&
                                checkoutModel.paymentMethod != null
                        ? onStepContinue
                        : null,
                    child: Text(checkoutModel.currentStep == 2
                        ? checkoutModel.paymentMethod == "Razorpay"
                            ? "Pay"
                            : "Confirm"
                        : "CONTINUE"),
                    color: Theme.of(context).accentColor,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  checkoutModel.currentStep == 0
                      ? TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        )
                      : TextButton(
                          onPressed: () => checkoutModel.backStep(),
                          child: Text('Back'),
                        )
                ],
              ),
            ),
            onStepContinue: () {
              if (checkoutModel.currentStep == 2) {
                checkoutModel.payAndOrder(
                  callback: () {
                    context.read(cartViewModelProvider).makeCartEmpty();
                    Navigator.pop(context, true);
                  },
                );
              } else {
                checkoutModel.nextStep();
              }
            },
            onStepCancel: () => Navigator.pop(context),
            type: StepperType.vertical,
            steps: [
              ///Step 1
              Step(
                isActive: true,
                state: checkoutModel.currentStep == 0
                    ? StepState.editing
                    : checkoutModel.currentStep > 0
                        ? StepState.complete
                        : StepState.indexed,
                title: Text("Delivery Options"),
                content: Column(
                  children: [
                    Material(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Delivery Day'),
                          ),
                          Column(
                              children: [
                            {"viewValue": "Today", "value": date.activeDate(0)},
                            {
                              "viewValue": "Tommorow",
                              "value": date.activeDate(1)
                            },
                            {
                              "viewValue": date.activeDay(2),
                              "value": date.activeDate(2)
                            },
                          ]
                                  .map(
                                    (e) => CustomRadioListTile(
                                      value: checkoutModel.deliveryDay ==
                                          e["value"],
                                      title: Text(e["viewValue"]),
                                      onTap: () => checkoutModel
                                          .setDeliveryDay(e["value"]),
                                    ),
                                  )
                                  .toList())
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Material(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Delivery By'),
                          ),
                          Column(
                            children: [
                              {
                                "range": '9:00 AM - 10:30 AM',
                                "startTime": "09:00:00"
                              },
                              {
                                "range": '10:00 AM - 11:00 AM',
                                "startTime": "10:00:00"
                              },
                              {
                                "range": '12:00 PM - 1:00 PM',
                                "startTime": "12:00:00"
                              },
                              {
                                "range": '2:00 PM - 4:00 PM',
                                "startTime": "14:00:00"
                              },
                            ]
                                .map(
                                  (e) => CustomRadioListTile(
                                    active: checkoutModel.deliveryDay ==
                                                date.activeDate(0) &&
                                            !date.deliverable(
                                                value: e["startTime"])
                                        ? false
                                        : true,
                                    title: Text(e["range"]),
                                    value:
                                        checkoutModel.deliveryBy == e["range"],
                                    onTap: () => checkoutModel.setDeliveryBy(
                                        range: e["range"],
                                        value: e["startTime"]),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Material(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Delivery Address'),
                          ),
                          Column(
                            children: checkoutModel.locationAddressList
                                .map(
                                  (e) => CustomRadioListTile(
                                    value: checkoutModel.locationAddress == e,
                                    onTap: () =>
                                        checkoutModel.setLocationAddress(e),
                                    title: AspectRatio(
                                      aspectRatio: 2,
                                      child: GoogleMap(
                                        liteModeEnabled: true,
                                        key: Key(e.value),
                                        initialCameraPosition: CameraPosition(
                                          target:
                                              LatLng(e.latitude, e.longitude),
                                          zoom: 16,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId: MarkerId("1"),
                                            position:
                                                LatLng(e.latitude, e.longitude),
                                          ),
                                        },
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Text(
                                        e.value,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              ///Step 2
              Step(
                isActive: checkoutModel.isOptionsCompleted,
                state: checkoutModel.currentStep == 1
                    ? StepState.editing
                    : checkoutModel.currentStep > 0
                        ? StepState.complete
                        : StepState.indexed,
                title: Text("Order Details"),
                content: Column(
                  children: [
                    Material(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Column(
                            children: checkoutModel.cartProducts.map((e) {
                              return ListTile(
                                leading: SizedBox(
                                  height: 56,
                                  width: 56,
                                  child: Image.network(
                                    e.image,
                                  ),
                                ),
                                title: Text(e.name),
                                subtitle: Text(e.qt.toString() +
                                    " Items x ₹" +
                                    e.price.toString()),
                                trailing: Text(
                                  "₹" + (e.qt * e.price).toString(),
                                ),
                              );
                            }).toList(),
                          ),
                          walletFuture.when(
                            data: (wallet) => Material(
                              color: Theme.of(context).primaryColorLight,
                              child: ListTile(
                                leading:
                                    Icon(Icons.account_balance_wallet_outlined),
                                title: Text(
                                  'Wallet Amount: ₹' +
                                      (checkoutModel.walletAmount == 0
                                          ? wallet.amount.toString()
                                          : checkoutModel.remainedWalletAmount
                                              .toString()),
                                ),
                                trailing: checkoutModel.walletAmount == 0
                                    ? IconButton(
                                        icon: Icon(Icons.arrow_forward_ios),
                                        onPressed: () => checkoutModel
                                            .useWallet(amount: wallet.amount),
                                      )
                                    : IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () =>
                                            checkoutModel.cancelUsingWallet(),
                                      ),
                              ),
                            ),
                            loading: () => SizedBox(),
                            error: (error, stackTrace) => SizedBox(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                TwoTextRow(
                                    text1: 'Items ${checkoutModel.items}',
                                    text2:
                                        '₹' + checkoutModel.price.toString()),
                                TwoTextRow(
                                    text1: 'Delivery',
                                    text2: '₹' +
                                        checkoutModel.settings.deliveryCharge
                                            .toString()),
                                TwoTextRow(
                                    text1:
                                        'Service Tax (${checkoutModel.settings.serviceTaxPercentage}%)',
                                    text2: '₹' +
                                        checkoutModel.serviceTax.toString()),
                                TwoTextRow(
                                    text1: 'Wallet Amount',
                                    text2: '₹' +
                                        checkoutModel.walletAmount.toString()),
                                TwoTextRow(
                                    text1: 'Total Price',
                                    text2:
                                        '₹' + checkoutModel.total.toString()),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              ///Step 3
              Step(
                isActive: checkoutModel.isOptionsCompleted,
                state: checkoutModel.currentStep == 2
                    ? StepState.editing
                    : checkoutModel.currentStep > 2
                        ? StepState.complete
                        : StepState.indexed,
                title: Text('Payment & Confirmation'),
                content: Column(
                  children: [
                    Material(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Payment Method'),
                          ),
                          Column(
                            children: ["Razorpay", "Cash On Delivery"]
                                .map(
                                  (e) => CustomRadioListTile(
                                    title: Text(e),
                                    value: checkoutModel.paymentMethod == e,
                                    onTap: () =>
                                        checkoutModel.setPaymentMethod(e),
                                  ),
                                )
                                .toList(),
                          ),
                          checkoutModel.paymentMethod == "Razorpay"
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Order will be confirmed once a payment successful.',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
