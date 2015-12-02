//
//  IAPHelper.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/1/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import StoreKit
import Foundation


class IAPHelper: NSObject {
    static let IAPHelperPurchaseNotification = "IAPHelperPurchaseNotification"
    
    typealias ProductsRequestCompletionHandler = (products: [SKProduct]?) -> ()
    
    private let productIndentifiers: Set<String>
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler:  ProductsRequestCompletionHandler?
    
    init(prodIds: Set<String>) {
        print(prodIds)
        self.productIndentifiers = prodIds
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
}

//:- API
extension IAPHelper {
    func requestProducts(completionHandler: ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIndentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    func buyProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
}

//:- SKProductsRequestDelegate
extension IAPHelper: SKProductsRequestDelegate {
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        productsRequestCompletionHandler?(products: response.products)
        productsRequestCompletionHandler = .None
        productsRequest = .None
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(products: .None)
        productsRequestCompletionHandler = .None
        productsRequest = .None
    }
}

//:- SKPaymentTransactionObserver
extension IAPHelper: SKPaymentTransactionObserver {
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased:
                completeTransaction(transaction)
            case .Failed:
                failedTransaction(transaction)
            case .Restored:
                restoreTranscation(transaction)
            default:
                print("Unhandled transaction type")
            }
        }
    }
    
    private func completeTransaction(transaction: SKPaymentTransaction) {
        deliverPurchaseNotificatioForIdentifier(transaction.payment.productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    private func restoreTranscation(transaction: SKPaymentTransaction) {
        deliverPurchaseNotificatioForIdentifier(transaction.originalTransaction?.payment.productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction) {
        if transaction.error?.code != SKErrorPaymentCancelled {
            print("Transaction Error: \(transaction.error?.localizedDescription)")
        }
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificatioForIdentifier(identifier: String?) {
        guard let identifier = identifier else { return }
        NSNotificationCenter.defaultCenter()
            .postNotificationName(self.dynamicType.IAPHelperPurchaseNotification, object: identifier)
    }
}



protocol IAPContainer {
    var iapHelper : IAPHelper? { get set }
    
    func passIAPHelperToChildren()
}


extension IAPContainer where Self : UIViewController {
    func passIAPHelperToChildren() {
        for vc in childViewControllers {
            var iapContainer = vc as? IAPContainer
            iapContainer?.iapHelper = iapHelper
        }
    }
}