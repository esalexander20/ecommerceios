//
//  CartEndpoints.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation

// MARK: - Cart Endpoints

public enum CartEndpoint: APIEndpoint {
    case getCart
    case addToCart(productId: String, quantity: Int)
    case removeFromCart(cartItemId: String)
    case updateCartItem(cartItemId: String, quantity: Int)
    case clearCart
    case getCartCount
    case mergeCart(cartItems: [[String: Any]])
    
    public var path: String {
        switch self {
        case .getCart: return "/cart"
        case .addToCart: return "/cart/add"
        case .removeFromCart(let cartItemId): return "/cart/remove"
        case .updateCartItem(let cartItemId, _): return "/cart/update"
        case .clearCart: return "/cart/clear"
        case .getCartCount: return "/cart/count"
        case .mergeCart: return "/cart/merge"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getCart, .getCartCount:
            return .get
        case .addToCart, .mergeCart:
            return .post
        case .removeFromCart, .updateCartItem, .clearCart:
            return .post
        }
    }
    
    public var bodyParameters: [String: Any]? {
        switch self {
        case .addToCart(let productId, let quantity):
            return ["product_id": productId, "quantity": quantity]
        
        case .removeFromCart(let cartItemId):
            return ["cart_item_id": cartItemId]
        
        case .updateCartItem(let cartItemId, let quantity):
            return ["cart_item_id": cartItemId, "quantity": quantity]
        
        case .mergeCart(let cartItems):
            return ["items": cartItems]
        
        default:
            return nil
        }
    }
}
