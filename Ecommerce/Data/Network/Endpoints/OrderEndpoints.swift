//
//  OrderEndpoints.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation

// MARK: - Order Endpoints

public enum OrderEndpoint: APIEndpoint {
    case createOrder(
        items: [[String: Any]],
        shippingAddress: [String: Any],
        billingAddress: [String: Any],
        paymentMethod: String,
        shippingMethod: String,
        couponCode: String?
    )
    case getOrders(page: Int, limit: Int, status: String?)
    case getOrder(id: String)
    case cancelOrder(id: String, reason: String?)
    case reorder(orderId: String)
    case trackOrder(orderId: String)
    case getOrderStatus(orderId: String)
    case updateOrderStatus(orderId: String, status: String)
    
    // Payment
    case createPaymentIntent(amount: Double, currency: String)
    case confirmPayment(paymentIntentId: String, paymentMethodId: String?)
    case getPaymentMethods
    case getShippingMethods(addressId: String)
    case calculateShippingCost(addressId: String, items: [[String: Any]])
    
    // Coupons
    case applyCoupon(code: String)
    case validateCoupon(code: String)
    
    public var path: String {
        switch self {
        case .createOrder: return "/orders"
        case .getOrders: return "/orders"
        case .getOrder(let id): return "/orders/\(id)"
        case .cancelOrder(let id, _): return "/orders/\(id)/cancel"
        case .reorder(let orderId): return "/orders/\(orderId)/reorder"
        case .trackOrder(let orderId): return "/orders/\(orderId)/track"
        case .getOrderStatus(let orderId): return "/orders/\(orderId)/status"
        case .updateOrderStatus(let orderId, _): return "/orders/\(orderId)/status"
        case .createPaymentIntent: return "/payments/intent"
        case .confirmPayment(let paymentIntentId, _): return "/payments/\(paymentIntentId)/confirm"
        case .getPaymentMethods: return "/payments/methods"
        case .getShippingMethods(let addressId): return "/shipping/methods"
        case .calculateShippingCost: return "/shipping/calculate"
        case .applyCoupon: return "/coupons/apply"
        case .validateCoupon: return "/coupons/validate"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getOrders, .getOrder, .trackOrder, .getOrderStatus, .getPaymentMethods:
            return .get
        case .createOrder, .cancelOrder, .reorder, .createPaymentIntent, .confirmPayment, .getShippingMethods, .calculateShippingCost, .applyCoupon, .validateCoupon, .updateOrderStatus:
            return .post
        }
    }
    
    public var bodyParameters: [String: Any]? {
        switch self {
        case .createOrder(let items, let shippingAddress, let billingAddress, let paymentMethod, let shippingMethod, let couponCode):
            var params: [String: Any] = [
                "items": items,
                "shipping_address": shippingAddress,
                "billing_address": billingAddress,
                "payment_method": paymentMethod,
                "shipping_method": shippingMethod
            ]
            if let couponCode = couponCode {
                params["coupon_code"] = couponCode
            }
            return params
        
        case .cancelOrder(_, let reason):
            var params: [String: Any] = [:]
            if let reason = reason {
                params["reason"] = reason
            }
            return params
        
        case .confirmPayment(let paymentIntentId, let paymentMethodId):
            var params: [String: Any] = ["payment_intent_id": paymentIntentId]
            if let paymentMethodId = paymentMethodId {
                params["payment_method_id"] = paymentMethodId
            }
            return params
        
        case .getShippingMethods(let addressId):
            return ["address_id": addressId]
        
        case .calculateShippingCost(let addressId, let items):
            return ["address_id": addressId, "items": items]
        
        case .applyCoupon(let code):
            return ["code": code]
        
        case .validateCoupon(let code):
            return ["code": code]
        
        case .updateOrderStatus(_, let status):
            return ["status": status]
        
        default:
            return nil
        }
    }
    
    public var queryParameters: [String: Any]? {
        switch self {
        case .getOrders(let page, let limit, let status):
            var params: [String: Any] = [
                "page": page,
                "limit": limit
            ]
            if let status = status {
                params["status"] = status
            }
            return params
        
        default:
            return nil
        }
    }
}
