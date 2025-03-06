import SwiftUI

// MARK: - Exercise 1: Social Media Post Class

class Post {
    var author: String
    var content: String
    var likes: Int
    
    init(author: String, content: String, likes: Int = 0) {
        self.author = author
        self.content = content
        self.likes = likes
    }
    
    func display() {
        print("Post by \(author):")
        print("\"\(content)\"")
        print("Likes: \(likes)")
        print(String(repeating: "-", count: 30)) // Separator line for better readability
    }
}

// Create first post
let post1 = Post(author: "Alice", content: "Just finished my first iOS assignment!", likes: 15)

// Create second post
let post2 = Post(author: "Bob", content: "Learning Swift classes is fun!", likes: 7)

// Display both posts
post1.display()
post2.display()

// MARK: - Exercise 2: Using the Singleton Pattern to create a more flexible shopping cart system

// Product Class
class Product {
    let name: String
    let price: Double
    var quantity: Int
    
    init(name: String, price: Double, quantity: Int = 1) {
        self.name = name
        self.price = price
        self.quantity = quantity
    }
}

//MARK: - DiscountStrategy Protocol and Implementations
protocol DiscountStrategy {
    func calculateDiscount(total: Double) -> Double
}

class NoDiscountStrategy: DiscountStrategy {
    func calculateDiscount(total: Double) -> Double {
        return 0.0 // No discount
    }
}

class PercentageDiscountStrategy: DiscountStrategy {
    let percentage: Double
    
    init(percentage: Double) {
        self.percentage = min(percentage, 100.0) // Ensure discount doesn't exceed 100%
    }
    
    func calculateDiscount(total: Double) -> Double {
        return total * (percentage / 100.0)
    }
}

//MARK: - ShoppingCartSingleton Class

class ShoppingCartSingleton {
    // Static property for the singleton instance
    // Using nonisolated(unsafe) as per mentor's feedback for Xcode 16 compatibility
    private static nonisolated(unsafe) var instance: ShoppingCartSingleton?
    
    // Private array to store products (composition)
    private var products: [Product] = []
    
    // Discount strategy
    var discountStrategy: DiscountStrategy = NoDiscountStrategy()
    
    // Private initializer to enforce singleton pattern
    private init() {}
    
    // Method to access the singleton instance
    static func sharedInstance() -> ShoppingCartSingleton {
        if instance == nil {
            instance = ShoppingCartSingleton()
        }
        return instance!
    }
    
    // Method to add a product to the cart
    func addProduct(product: Product, quantity: Int = 1) {
        // Check if the product is already in the cart
        if let index = products.firstIndex(where: { $0.name == product.name }) {
            // If it is, update the quantity
            products[index].quantity += quantity
        } else {
            // If not, add the product with the specified quantity
            let newProduct = Product(name: product.name, price: product.price, quantity: quantity)
            products.append(newProduct)
        }
    }
    
    // Method to remove a product from the cart
    func removeProduct(product: Product) {
        products.removeAll { $0.name == product.name }
    }
    
    // Method to clear the cart
    func clearCart() {
        products.removeAll()
    }
    
    // Method to calculate the total price
    func getTotalPrice() -> Double {
        let subtotal = products.reduce(0.0) { $0 + ($1.price * Double($1.quantity)) }
        let discount = discountStrategy.calculateDiscount(total: subtotal)
        return subtotal - discount
    }
    
    // Helper method to display cart contents
    func displayCart() {
        if products.isEmpty {
            print("Shopping cart is empty.")
            return
        }
        
        print("Shopping Cart Contents:")
        print("------------------------")
        for product in products {
            print("\(product.name) - $\(product.price) x \(product.quantity) = $\(product.price * Double(product.quantity))")
        }
        
        let subtotal = products.reduce(0.0) { $0 + ($1.price * Double($1.quantity)) }
        let discount = discountStrategy.calculateDiscount(total: subtotal)
        
        print("------------------------")
        print("Subtotal: $\(subtotal)")
        print("Discount: $\(discount)")
        print("Total: $\(getTotalPrice())") // Using getTotalPrice() method as suggested by mentor
        print("------------------------")
    }
}

// Get the singleton shopping cart instance
let cart = ShoppingCartSingleton.sharedInstance()

// Create some products
let laptop = Product(name: "Laptop", price: 1299.99)
let phone = Product(name: "Smartphone", price: 799.99)
let charger = Product(name: "USB-C Charger", price: 19.99)

// Add products to the cart
cart.addProduct(product: laptop)
cart.addProduct(product: phone, quantity: 2)
cart.addProduct(product: charger, quantity: 3)

// Display the cart with no discount
print("Cart with no discount:")
cart.displayCart()

// Apply a 10% discount
cart.discountStrategy = PercentageDiscountStrategy(percentage: 10.0)
print("\nCart with 10% discount:")
cart.displayCart()

// Remove a product
cart.removeProduct(product: phone)
print("\nCart after removing smartphones:")
cart.displayCart()

// Clear the cart
cart.clearCart()
print("\nCart after clearing:")
cart.displayCart()

// MARK: - Exercise 3: Payment Processor Protocol

// Custom Error Type for Payment Processing
enum PaymentError: Error {
    case insufficientFunds
    case invalidCard
    case cardExpired
    case networkError
    case paymentLimitExceeded
    case cashRegisterEmpty
    
    var message: String {
        switch self {
        case .insufficientFunds:
            return "Insufficient funds to complete the transaction."
        case .invalidCard:
            return "The card information is invalid."
        case .cardExpired:
            return "The card has expired."
        case .networkError:
            return "Network error occurred during payment processing."
        case .paymentLimitExceeded:
            return "The payment amount exceeds the allowed limit."
        case .cashRegisterEmpty:
            return "Cash register is empty and cannot provide change."
        }
    }
}

// Payment Processor Protocol
protocol PaymentProcessor {
    func processPayment(amount: Double) throws
    var name: String { get }
}

// Credit Card Processor
class CreditCardProcessor: PaymentProcessor {
    let name = "Credit Card"
    private let cardNumber: String
    private let expiryDate: String
    private let cvv: String
    private let balance: Double
    
    init(cardNumber: String, expiryDate: String, cvv: String, balance: Double) {
        self.cardNumber = cardNumber
        self.expiryDate = expiryDate
        self.cvv = cvv
        self.balance = balance
    }
    
    func processPayment(amount: Double) throws {
        // Validate the amount
        if amount <= 0 {
            throw PaymentError.invalidCard
        }
        
        // Check for payment limits
        if amount > 10000 {
            throw PaymentError.paymentLimitExceeded
        }
        
        // Simulate card validation
        if cardNumber.count != 16 {
            throw PaymentError.invalidCard
        }
        
        // Simulate expiry date check (very basic simulation)
        if expiryDate == "01/20" {
            throw PaymentError.cardExpired
        }
        
        // Check for sufficient funds
        if amount > balance {
            throw PaymentError.insufficientFunds
        }
        
        // Simulate random network error (10% chance)
        if Double.random(in: 0...1) < 0.1 {
            throw PaymentError.networkError
        }
        
        // If we reach here, payment is successful
        print("Credit card payment of $\(amount) processed successfully.")
    }
}

// Cash Processor
class CashProcessor: PaymentProcessor {
    let name = "Cash"
    private var cashInRegister: Double
    
    init(cashInRegister: Double) {
        self.cashInRegister = cashInRegister
    }
    
    func processPayment(amount: Double) throws {
        // Validate the amount
        if amount <= 0 {
            throw PaymentError.invalidCard  // Reusing error for simplicity
        }
        
        // Check if providing change is possible
        if cashInRegister < amount {
            throw PaymentError.cashRegisterEmpty
        }
        
        // Processing payment
        cashInRegister -= amount
        
        // If below messages display, payment is successful
        print("Cash payment of $\(amount) processed successfully.")
        print("Remaining cash in register: $\(cashInRegister)")
    }
}

// Create payment processors
let creditCardProcessor = CreditCardProcessor(
    cardNumber: "1234567890123456",
    expiryDate: "12/25",
    cvv: "123",
    balance: 5000.0
)

let expiredCardProcessor = CreditCardProcessor(
    cardNumber: "9876543210987654",
    expiryDate: "01/20",
    cvv: "456",
    balance: 1000.0
)

let cashProcessor = CashProcessor(cashInRegister: 200.0)

// Process payments with try-catch blocks as per exercise requirements
print("\n--- Payment Processing Examples ---")

// Example 1: Successful credit card payment
print("\nAttempting credit card payment of $50.00:")
do {
    try creditCardProcessor.processPayment(amount: 50.0)
    print("✅ Transaction completed successfully")
} catch let error as PaymentError {
    print("❌ Payment Error: \(error.message)")
} catch {
    print("❌ Unexpected error: \(error.localizedDescription)")
}

// Example 2: Payment exceeding limit
print("\nAttempting large credit card payment of $20000.00:")
do {
    try creditCardProcessor.processPayment(amount: 20000.0)
    print("✅ Transaction completed successfully")
} catch let error as PaymentError {
    print("❌ Payment Error: \(error.message)")
} catch {
    print("❌ Unexpected error: \(error.localizedDescription)")
}

// Example 3: Expired card
print("\nAttempting payment with expired card:")
do {
    try expiredCardProcessor.processPayment(amount: 30.0)
    print("✅ Transaction completed successfully")
} catch let error as PaymentError {
    print("❌ Payment Error: \(error.message)")
} catch {
    print("❌ Unexpected error: \(error.localizedDescription)")
}

// Example 4: Successful cash payment
print("\nAttempting cash payment of $75.00:")
do {
    try cashProcessor.processPayment(amount: 75.0)
    print("✅ Transaction completed successfully")
} catch let error as PaymentError {
    print("❌ Payment Error: \(error.message)")
} catch {
    print("❌ Unexpected error: \(error.localizedDescription)")
}

// Example 5: Cash payment exceeding register amount
print("\nAttempting cash payment of $300.00 (register only has $200.00):")
do {
    try cashProcessor.processPayment(amount: 300.0)
    print("✅ Transaction completed successfully")
} catch let error as PaymentError {
    print("❌ Payment Error: \(error.message)")
} catch {
    print("❌ Unexpected error: \(error.localizedDescription)")
}

