import 'package:flutter/material.dart';
import '../novalnet_util.dart';
import '../novalnet_payment_params.dart';

class ApplePayHandler {
  static Future<Map<String, dynamic>?> startPayment(
    BuildContext context,
    Map<String, dynamic> bodyParams,
    Map<String, dynamic> token,
    String paymentType,
  ) async {
    try {
      // Validate
      if (token.isEmpty) {
        return {
          "status": "FAILURE",
          "message": NovalnetUtil.localize(
            "TOKEN_INVALID",
            bodyParams["lang"] ?? "EN",
          ),
        };
      }

      final fixedResultData = NovalnetUtil.deepDecode(token);
      Map<String, dynamic> genarateWalletTokenReq = {
        "client_key": "${bodyParams["client_key"]}",
        "domain": "https://www.novalnet.com/",
        "is_pending_transaction": false,
        "payment_method": "APPLEPAY",
        "validate_data": fixedResultData,
      };

      final tokenResponse = await NovalnetUtil.sendRequest(
        genarateWalletTokenReq,
        "tokenize",
        bodyParams["access_key"],
      );

      if (tokenResponse.isNotEmpty && tokenResponse["error"] != null) {
        return {"status": "FAILURE", "message": tokenResponse["error"]};
      }

      if (tokenResponse.isEmpty) {
        return {
          "status": "FAILURE",
          "message": NovalnetUtil.localize(
            "TOKEN_INVALID_NN",
            bodyParams["lang"] ?? "EN",
          ),
        };
      }

      final walletToken = tokenResponse["token"];

      // Build request
      final paymentRequest = NovalnetPaymentParams().nnGetParams(
        bodyParams: {...bodyParams, "wallet_token": walletToken},
        paymentType: "APPLEPAY",
      );

      // Call API
      final response = await NovalnetUtil.sendRequest(
        paymentRequest,
        bodyParams["payment_action"],
        bodyParams["access_key"],
      );

      final resultStatus = response["result"]?["status"];
      if (resultStatus == "FAILURE") {
        return NovalnetUtil.getErrorMessage(response, bodyParams["lang"]);
      }
      return {"status": resultStatus, "result": response};
    } catch (e) {
      return {"status": "FAILURE", "message": "Something went wrong $e"};
    }
  }
}
