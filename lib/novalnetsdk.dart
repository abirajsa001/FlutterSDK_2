import 'novalnetsdk_platform_interface.dart';
import 'package:flutter/material.dart';
import 'screens/payment_screen.dart';
import 'config_loader.dart';
import 'screens/google_pay_handler.dart';
import 'screens/apple_pay_handler.dart';

class NovalnetSDK {
  Future<String?> getPlatformVersion() {
    return NovalnetsdkPlatform.instance.getPlatformVersion();
  }

  static Future<dynamic> openPaymentScreen(
    BuildContext context, {
    Map<String, dynamic>? bodyParams,
    List<String> paymentMethods = const [],
  }) async {
    Map<String, dynamic> finalParams = {};

    // Priority: manual > yaml
    if (bodyParams != null && bodyParams.isNotEmpty) {
      finalParams = bodyParams;
    } else {
      finalParams = await ConfigLoader.loadConfig();
    }

    if (finalParams.isEmpty) {
      return {"status": "FAILURE", "message": "Missing payment configuration"};
    }

    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          bodyParams: finalParams,
          paymentMethods: paymentMethods,
        ),
      ),
    );
  }

  static Future<dynamic> openWalletPaymentHandler(
    BuildContext context, {
    Map<String, dynamic>? bodyParams,
    required String paymentType,
    required Map<String, dynamic> token,
  }) async {
    Map<String, dynamic> finalParams = {};

    // Priority: manual > yaml
    if (bodyParams != null && bodyParams.isNotEmpty) {
      finalParams = bodyParams;
    } else {
      finalParams = await ConfigLoader.loadConfig();
    }

    if (finalParams.isEmpty) {
      return {"status": "FAILURE", "message": "Missing payment configuration"};
    }

    if (paymentType == 'GOOGLEPAY') {
      return await GooglePayHandler.startPayment(
        context,
        finalParams,
        token,
        paymentType,
      );
    } else if (paymentType == 'APPLEPAY') {
      return await ApplePayHandler.startPayment(
        context,
        finalParams,
        token,
        paymentType,
      );
    }
  }
}
