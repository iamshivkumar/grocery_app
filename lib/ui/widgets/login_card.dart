import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/view_models/auth_view_model/auth_view_model_provider.dart';
import 'package:grocery_app/core/enums/phone_auth_mode.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class LoginSheet {
  final BuildContext context;
  LoginSheet(this.context);
  Future<dynamic> show() async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: LoginCard(),
        ),
      ),
    );
  }
}

class LoginCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var authModel = watch(authViewModelProvider);
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: authModel.phoneAuthMode == PhoneAuthMode.EnterPhone
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: Text('Login'),
                    subtitle: Text('Enter your phone number to proceed.'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      autofocus: true,
                      controller: authModel.phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.call), prefixText: '+91'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: !authModel.loading
                        ? MaterialButton(
                            onPressed: () {
                              authModel.sendOTP(
                                onVerify: () =>
                                    Navigator.pop(context, authModel.user),
                              );
                            },
                            colorBrightness: Brightness.dark,
                            color: Theme.of(context).accentColor,
                            child: Text('CONTINUE'),
                          )
                        : Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: IconButton(
                        icon: Icon(Icons.arrow_back_ios), onPressed: () {}),
                    title: Text('Verify Phone Number'),
                    subtitle: Text('Enter OTP to verify phone number'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PinCodeTextField(
                      onChanged: null,
                      controller: authModel.smsController,
                      appContext: context,
                      length: 6,
                      enablePinAutofill: true,
                      autoFocus: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: !authModel.loading
                        ? MaterialButton(
                            onPressed: () async {
                              var user =
                                  await authModel.verifyOTP();
                              Navigator.pop(context, user);
                            },
                            colorBrightness: Brightness.dark,
                            color: Theme.of(context).accentColor,
                            child: Text('VERIFY'),
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
