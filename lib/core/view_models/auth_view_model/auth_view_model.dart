import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_app/core/enums/phone_auth_mode.dart';

class AuthViewModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User user = FirebaseAuth.instance.currentUser;
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController smsController = TextEditingController();
  String _verificationId;
  bool loading = false;
  PhoneAuthMode phoneAuthMode = PhoneAuthMode.EnterPhone;

  void setMode() {
    phoneAuthMode = PhoneAuthMode.Verify;
    notifyListeners();
  }

  void verifyPhoneNumber(
      {VoidCallback onVerify, VoidCallback onCodeSent}) async {
    loading = true;
    notifyListeners();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "+91" + phoneNumberController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          loading = true;
          notifyListeners();
          user = (await _auth.signInWithCredential(credential)).user;
          onVerify();
          Fluttertoast.showToast(
              msg: "Login successful", backgroundColor: Color(0xFF4E598C));
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            Fluttertoast.showToast(
                msg: "The provided phone number is not valid.",
                backgroundColor: Color(0xFF4E598C));
          }
        },
        codeSent: (String verificationId, int resendToken) async {
          loading = false;
          phoneAuthMode = PhoneAuthMode.Verify;
          _verificationId = verificationId;
          notifyListeners();
        },
        timeout: const Duration(seconds: 30),
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          loading = false;
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<User> signInWithPhoneNumber() async {
    loading = true;
    notifyListeners();
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsController.text,
      );

      user = (await _auth.signInWithCredential(credential)).user;

      Fluttertoast.showToast(
        msg: "Login successful",
        backgroundColor: Color(0xFF4E598C),
      );
    } catch (e) {
      print("Failed to sign in: " + e.toString());
    }
    loading = false;
    notifyListeners();
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    user = null;
  }

  Future<void> refundRequestWalletAmount() async{
    FirebaseFirestore.instance.collection("wallets").doc(user.uid).update({
      "refundRequested": true,
      "name": user.displayName,
    });
  }
}
