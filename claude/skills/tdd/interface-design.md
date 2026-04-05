# Interface Design for Testability

Good interfaces make testing natural:

1. **Accept dependencies, don't create them**

   JavaScript:
   ```javascript
   function processOrder(order, paymentGateway) {}
   ```
   Python:
   ```python
   def process_order(order, payment_gateway): ...
   ```
   Kotlin:
   ```kotlin
   fun processOrder(order: Order, paymentGateway: PaymentGateway) {}
   ```

2. **Return results, don't produce side effects**

   JavaScript:
   ```javascript
   function calculateDiscount(cart) {}
   ```
   Python:
   ```python
   def calculate_discount(cart) -> Discount: ...
   ```
   Kotlin:
   ```kotlin
   fun calculateDiscount(cart: Cart): Discount = TODO()
   ```

3. **Small surface area**
   - Fewer methods = fewer tests needed
   - Fewer params = simpler test setup
