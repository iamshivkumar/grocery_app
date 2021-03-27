import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_app/core/enums/phone_auth_mode.dart';

class AuthViewModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User user = FirebaseAuth.instance.currentUser;

  String _verificationId;
  bool loading = false;
  PhoneAuthMode phoneAuthMode = PhoneAuthMode.EnterPhone;

  void back() {
    phoneAuthMode = PhoneAuthMode.EnterPhone;
    notifyListeners();
  }

  void sendOTP({VoidCallback onVerify,String phone}) async {
    loading = true;
    notifyListeners();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "+91" + phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          loading = true;
          notifyListeners();
          user = (await _auth.signInWithCredential(credential)).user;
          onVerify();
          Fluttertoast.showToast(msg: "Sign in successful");
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            Fluttertoast.showToast(
              msg: "The provided phone number is not valid.",
            );
          } else
            Fluttertoast.showToast(msg: e.code);
          loading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int resendToken) async {
          loading = false;
          phoneAuthMode = PhoneAuthMode.Verify;
          _verificationId = verificationId;

          notifyListeners();
        },
        timeout: const Duration(seconds: 0),
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          loading = false;
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> verifyOTP({String otp}) async {
    loading = true;
    notifyListeners();
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      user = (await _auth.signInWithCredential(credential)).user;

      Fluttertoast.showToast(
        msg: "Sign in successful",
        backgroundColor: Color(0xFF4E598C),
      );
    } catch (e) {
      print("Failed to sign in: " + e.code.toString());
    }
    loading = false;
    notifyListeners();
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    user = null;
  }

  Future<void> refundRequestWalletAmount() async {
    FirebaseFirestore.instance.collection("wallets").doc(user.uid).update({
      "refundRequested": true,
      "name": user.displayName,
    });
  }
}
