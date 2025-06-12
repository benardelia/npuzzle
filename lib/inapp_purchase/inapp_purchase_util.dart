import 'dart:async';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:npuzzle/utils/logger.dart';

class InappPurchaseUtil extends GetxController {
  // private constructor
  InappPurchaseUtil._();

  // singleton instance
  static final InappPurchaseUtil _instance = InappPurchaseUtil._();

  // Getter to access the singleton instance
  static InappPurchaseUtil get instance => _instance;

  // private variable
  final InappPurchaseUtil _iap = InappPurchaseUtil.instance;

  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  @override
  void onClose() {
    _purchaseSubscription.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

  Future<void> initialize() async {
    if (!(_iap.initialized)) return;

    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
          if (purchaseDetails.status == PurchaseStatus.pending) {
            // Handle pending purchases
          } else if (purchaseDetails.status == PurchaseStatus.purchased ||
              purchaseDetails.status == PurchaseStatus.restored) {
            // Handle successful purchases
            InAppPurchase.instance.completePurchase(purchaseDetails);
            Log.i('Purchase completed: ${purchaseDetails.productID}');
          } else if (purchaseDetails.status == PurchaseStatus.error) {
            // Handle errors
           
          }
        }
      },
      onError: (error) {
        // Handle errors from the stream
        
      },
    );
  }
}
