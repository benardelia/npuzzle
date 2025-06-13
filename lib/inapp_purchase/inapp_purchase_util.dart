import 'dart:async';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:npuzzle/utils/logger.dart';

class InAppPurchaseUtil extends GetxController {
  // // private constructor
  // InappPurchaseUtil._();

  // // singleton instance
  // static final InappPurchaseUtil _instance = InappPurchaseUtil._();

  // // Getter to access the singleton instance
  // static InappPurchaseUtil get inappPurchaseUtilInstance => _instance;

  // private variable
  final InAppPurchase _iap = InAppPurchase.instance;

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
    if (!(await _iap.isAvailable())) return;

    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) async {
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

          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails).then((value) {});
          }
        }
      },
      onError: (error) {
        // Handle errors from the stream
      },
      onDone: () {
        _purchaseSubscription.cancel();
      },
    );
  }

  Future<void> buyNonConsumable(String productId) async {
    if (!(await _iap.isAvailable())) {
      Log.e('In-app purchases are not available');
      return;
    }

    final ProductDetailsResponse response =
        await _iap.queryProductDetails({productId});

    if (response.notFoundIDs.isNotEmpty) {
      Log.e('Product not found: $productId');
      return;
    }

    Log.i('products found: ${response.productDetails}');

    final ProductDetails productDetails = response.productDetails.first;

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
      applicationUserName: null,
    );

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      //  TODO : Handle error
      Log.e('Error buying product: $e');
    }
  }

  restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      //  TODO : Handle error
      Log.e('Error restoring purchases: $e');
    }
  }
}
