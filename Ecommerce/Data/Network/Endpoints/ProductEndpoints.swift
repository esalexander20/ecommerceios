//
//  ProductEndpoints.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation

// MARK: - Product Endpoints

public enum ProductEndpoint: APIEndpoint {
    // Get products
    case getProducts(page: Int, limit: Int, category: String?, search: String?, sortBy: String?, sortOrder: String?)
    case getProduct(id: String)
    case getFeaturedProducts(limit: Int)
    case getNewArrivals(limit: Int)
    case getBestSellers(limit: Int)
    case getOnSaleProducts(limit: Int)
    case getRelatedProducts(productId: String, limit: Int)
    case getProductsByCategory(categoryId: String, page: Int, limit: Int)
    case getProductsByBrand(brandId: String, page: Int, limit: Int)
    
    // Categories
    case getCategories(parentId: String?)
    case getCategory(id: String)
    
    // Brands
    case getBrands
    case getBrand(id: String)
    
    // Reviews
    case getProductReviews(productId: String, page: Int, limit: Int)
    case addProductReview(productId: String, rating: Int, comment: String)
    
    // Wishlist
    case addToWishlist(productId: String)
    case removeFromWishlist(productId: String)
    case getWishlist(page: Int, limit: Int)
    case isInWishlist(productId: String)
    
    public var path: String {
        switch self {
        case .getProducts: return "/products"
        case .getProduct(let id): return "/products/\(id)"
        case .getFeaturedProducts: return "/products/featured"
        case .getNewArrivals: return "/products/new"
        case .getBestSellers: return "/products/best-sellers"
        case .getOnSaleProducts: return "/products/on-sale"
        case .getRelatedProducts(let productId, _): return "/products/\(productId)/related"
        case .getProductsByCategory(let categoryId, _, _): return "/categories/\(categoryId)/products"
        case .getProductsByBrand(let brandId, _, _): return "/brands/\(brandId)/products"
        case .getCategories: return "/categories"
        case .getCategory(let id): return "/categories/\(id)"
        case .getBrands: return "/brands"
        case .getBrand(let id): return "/brands/\(id)"
        case .getProductReviews(let productId, _, _): return "/products/\(productId)/reviews"
        case .addProductReview(let productId, _, _): return "/products/\(productId)/reviews"
        case .addToWishlist(let productId): return "/wishlist/add"
        case .removeFromWishlist(let productId): return "/wishlist/remove"
        case .getWishlist: return "/wishlist"
        case .isInWishlist(let productId): return "/wishlist/check"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getProducts, .getProduct, .getFeaturedProducts, .getNewArrivals, .getBestSellers, 
             .getOnSaleProducts, .getRelatedProducts, .getProductsByCategory, .getProductsByBrand,
             .getCategories, .getCategory, .getBrands, .getBrand, .getProductReviews, .getWishlist, .isInWishlist:
            return .get
        case .addProductReview, .addToWishlist:
            return .post
        case .removeFromWishlist:
            return .delete
        }
    }
    
    public var queryParameters: [String: Any]? {
        switch self {
        case .getProducts(let page, let limit, let category, let search, let sortBy, let sortOrder):
            var params: [String: Any] = [
                "page": page,
                "limit": limit
            ]
            if let category = category { params["category"] = category }
            if let search = search { params["search"] = search }
            if let sortBy = sortBy { params["sort_by"] = sortBy }
            if let sortOrder = sortOrder { params["sort_order"] = sortOrder }
            return params
        
        case .getFeaturedProducts(let limit):
            return ["limit": limit]
        
        case .getNewArrivals(let limit):
            return ["limit": limit]
        
        case .getBestSellers(let limit):
            return ["limit": limit]
        
        case .getOnSaleProducts(let limit):
            return ["limit": limit]
        
        case .getRelatedProducts(_, let limit):
            return ["limit": limit]
        
        case .getProductsByCategory(_, let page, let limit):
            return ["page": page, "limit": limit]
        
        case .getProductsByBrand(_, let page, let limit):
            return ["page": page, "limit": limit]
        
        case .getProductReviews(let productId, let page, let limit):
            return ["product_id": productId, "page": page, "limit": limit]
        
        case .getWishlist(let page, let limit):
            return ["page": page, "limit": limit]
        
        case .isInWishlist(let productId):
            return ["product_id": productId]
        
        default:
            return nil
        }
    }
    
    public var bodyParameters: [String: Any]? {
        switch self {
        case .addProductReview(_, let rating, let comment):
            return ["rating": rating, "comment": comment]
        
        case .addToWishlist(let productId):
            return ["product_id": productId]
        
        case .removeFromWishlist(let productId):
            return ["product_id": productId]
        
        default:
            return nil
        }
    }
}
