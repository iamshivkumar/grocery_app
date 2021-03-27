import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grocery_app/core/view_models/auth_view_model/auth_view_model_provider.dart';
import 'package:grocery_app/core/enums/phone_auth_mode.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class SignInSheet {
  final BuildContext context;
  SignInSheet(this.context);
  Future<dynamic> show() async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: SignInCard(),
      ),
    );
  }
}

class SignInCard extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var authModel = useProvider(authViewModelProvider);
    var phoneController = useTextEditingController();
    var otpController = useTextEditingController();
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: authModel.phoneAuthMode == PhoneAuthMode.EnterPhone
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: Text('Sign In'),
                    subtitle: Text('Enter your phone number to proceed.'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      maxLength: 10,
                      autofocus: true,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.call), prefixText: '+91 '),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: !authModel.loading
                        ? MaterialButton(
                            onPressed: () {
                              authModel.sendOTP(
                                phone: phoneController.text,
                                onVerify: () => Navigator.pop(context),
                              );
                            },
                            colorBrightness: Brightness.dark,
                            color: Theme.of(context).accentColor,
                            child: Text('CONTINUE'),
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: authModel.back,
                    ),
                    title: Text('Verify Phone Number'),
                    subtitle: Text('Enter OTP to verify phone number'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PinCodeTextField(
                      onChanged: (v){},
                      controller: otpController,
                      appContext: context,
                      autoDisposeControllers: false,
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
                              await authModel.verifyOTP(otp: otpController.text);
                              Navigator.pop(context);
                            },
                            colorBrightness: Brightness.dark,
                            color: Theme.of(context).accentColor,
                            child: Text('VERIFY'),
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
