//
//  DAO.swift
//  UrbaneTrenz
//

import Foundation

class CartDAO {
    
    private static let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private static let fileURL = URL(fileURLWithPath:"cart",relativeTo: directoryURL).appendingPathExtension("txt")
    
    /// Creates cart file if it doesn't exist
    static func createCart() {
        let fileManager = FileManager.default
        if !(fileManager.fileExists(atPath: fileURL.path)) {
            fileManager.createFile(atPath: fileURL.path, contents: Data("[]".utf8))
            print("Creating file")
        }
    }
    
    /// Writes array of cart items to file
    static func writeToCart(cart : [CartItem]) {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(cart) {
            do {
                try jsonData.write(to: fileURL)
            } catch {
                print("Write Error = \(error.localizedDescription)")
            }
        }
    }
    
    /// Reads and returns cart items from file
    static func readFromCart() -> [CartItem]{
        do {
            let data = try String(contentsOf: fileURL)
            let decoder = JSONDecoder()
            if let cart = try? decoder.decode([CartItem].self,from: data.data(using:.utf8)!) {
                return cart
            }
        } catch {
            print("Read Error = \(error.localizedDescription)")
        }
        return []
    }
    
    /// Changes quantity of given product
    static func modifyProductQuantity(product : Product, newCount : Int) {
        var cart = readFromCart()
        cart = cart.filter{$0.product.ProductID != product.ProductID}
        if newCount > 0 {
            cart.append(CartItem(product: product, productCount: newCount <= product.StockCount ? newCount : product.StockCount))
        }
        cart.sort(by: {$0.id < $1.id})
        writeToCart(cart: cart)
    }
    
    /// Adds products to cart file
    static func addProductToCart(product : Product) {
        var cart = readFromCart()
        let cartItemArray = cart.filter{$0.product.ProductID == product.ProductID}
        if cartItemArray.isEmpty {
            if product.StockCount > 0 {
                cart.append(CartItem(product: product, productCount: 1))
            }
        } else {
            if cartItemArray[0].productCount < product.StockCount {
                let current = cartItemArray[0].productCount
                cart = cart.filter{$0.product.ProductID != product.ProductID}
                cart.append(CartItem(product: product, productCount: current + 1))
            }
        }
        cart.sort(by: {$0.id < $1.id})
        writeToCart(cart: cart)
    }
    
    /// Delete specific product from cart
    static func deleteFromCart(product : Product) {
        var cart = readFromCart()
        cart = cart.filter{$0.product.ProductID != product.ProductID}
        writeToCart(cart: cart)
    }
    
    /// Delete all product from cart
    static func deleteAll() {
        let cart : [CartItem] = []
        writeToCart(cart: cart)
    }
}
