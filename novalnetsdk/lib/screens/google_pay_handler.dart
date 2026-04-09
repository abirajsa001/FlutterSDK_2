import 'package:flutter/material.dart';
import '../novalnet_util.dart';
import '../novalnet_payment_params.dart';

class GooglePayHandler {
  static Future<Map<String, dynamic>?> startPayment(
    BuildContext context,
    Map<String, dynamic> bodyParams,
    Map<String, dynamic> token,
    String paymentType,
  ) async {
    try {
      String testMode = bodyParams["test_mode"].toString() == "1"
          ? "SANDBOX"
          : "PRODUCTION";
      // Validate token
      if (token.isEmpty) {
        return {
          "status": "FAILURE",
          "message": NovalnetUtil.localize(
            "TOKEN_INVALID",
            bodyParams["lang"] ?? "EN",
          ),
        };
      }
      // onLoading(true);

      Map<String, dynamic> genarateWalletTokenReq = {
        "client_key": "${bodyParams["client_key"]}",
        "domain": "https://www.novalnet.com/",
        "is_pending_transaction": false,
        "payment_method": "GOOGLEPAY",
        "validate_data": token,
      };

      final validateData =
          genarateWalletTokenReq["validate_data"] as Map<String, dynamic>;

      validateData["environment"] = testMode;
      validateData["amount"] = bodyParams["amount"];
      final Map<String, dynamic> tokenResponse = await NovalnetUtil.sendRequest(
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
        paymentType: "GOOGLEPAY",
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
      return {"status": "FAILURE", "message": "Google Pay failed $e"};
    }
  }
}
