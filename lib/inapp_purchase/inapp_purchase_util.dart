import 'dart:async';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';
import 'package:npuzzle/utils/logger.dart';

class InAppPurchaseUtil extends GetxController {
  var isSubscribed = false.obs; // RxBool to track subscription status
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;
  static const String subscriptionId =
      '8_puzzle_subscription'; // Your subscription ID
  final controller = Get.find<AppController>();

  @override
  void onClose() {
    _purchaseSubscription.cancel();
    Log.i('Purchase stream subscription cancelled');
    super.onClose();
  }

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

  Future<void> initialize() async {
    try {
      if (!(await _iap.isAvailable())) {
        Log.e('In-app purchases are not available');
        isSubscribed.value = false;
        return;
      }

      // Set up purchase stream listener
      _purchaseSubscription = _iap.purchaseStream.listen(
        (List<PurchaseDetails> purchaseDetailsList) async {
          for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
            Log.i(
                'Purchase details: ${purchaseDetails.transactionDate}, status: ${purchaseDetails.status}, productID: ${purchaseDetails.productID}');
            if (purchaseDetails.status == PurchaseStatus.pending) {
              Log.i('Purchase pending: ${purchaseDetails.productID}');
            } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                purchaseDetails.status == PurchaseStatus.restored) {
              // Handle successful or restored purchases
              if (purchaseDetails.productID == subscriptionId) {
                isSubscribed.value = await _verifySubscription(purchaseDetails);
                if (isSubscribed.value) {
                  Log.i(
                      'Active subscription found: ${purchaseDetails.productID}');
                  controller.appBox.put('val', 1000);
                  controller.currentLevel.value = 1000;
                } else {
                  Log.i('Subscription not valid: ${purchaseDetails.productID}');
                }
              }
              if (purchaseDetails.pendingCompletePurchase) {
                await _iap.completePurchase(purchaseDetails);
                Log.i('Purchase completed: ${purchaseDetails.productID}');
              }
            } else if (purchaseDetails.status == PurchaseStatus.error) {
              Log.e('Purchase error: ${purchaseDetails.error?.message}');
            } else if (purchaseDetails.status == PurchaseStatus.canceled) {
              Log.i('Purchase canceled: ${purchaseDetails.productID}');
            }
          }
        },
        onError: (error) {
          Log.e('Purchase stream error: $error');
        },
        onDone: () {
          Log.i('Purchase stream closed');
          _purchaseSubscription.cancel();
        },
      );

      // Check subscription status at startup
      await checkSubscriptionStatus();
    } catch (e) {
      Log.e('Initialization error: $e');
      isSubscribed.value = false;
    }
  }

  // Check if the user has an active subscription using restorePurchases
  Future<void> checkSubscriptionStatus() async {
    try {
      if (!(await _iap.isAvailable())) {
        Log.e('In-app purchases are not available');
        isSubscribed.value = false;
        return;
      }

      // Trigger restorePurchases to check for active subscriptions
      Log.i('Restoring purchases to check subscription status');
      await _iap.restorePurchases();
      // The purchaseStream listener will handle restored purchases and update isSubscribed
    } catch (e) {
      Log.e('Error checking subscription status: $e');
      isSubscribed.value = false;
    }
  }

  // Verify if a subscription is active (basic validation)
  Future<bool> _verifySubscription(PurchaseDetails purchase) async {
    // Basic check for purchased or restored status
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      // For production, implement server-side validation:
      // - Google Play: Use purchase.verificationData.localVerificationData (purchase token)
      //   and validate with Google Play Developer API (subscriptions.get).
      // - iOS: Use purchase.verificationData.serverVerificationData and validate
      //   with Apple's receipt validation endpoint.
      Log.i('Subscription verified locally: ${purchase.productID}');
      return true; // Assume valid for testing
    }
    return false;
  }

  Future<void> buyNonConsumable(String productId) async {
    try {
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

      Log.i('Product found: ${response.productDetails.first.id}');

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: '8_puzzle',
      );

      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      Log.e('Error buying product: $e');
    }
  }
}
