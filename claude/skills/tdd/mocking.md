# When to Mock

Mock at **system boundaries** only:

- External APIs (payment, email, etc.)
- Databases (sometimes - prefer test DB)
- Time/randomness
- File system (sometimes)

Don't mock:

- Your own classes/modules
- Internal collaborators
- Anything you control

## Designing for Mockability

At system boundaries, design interfaces that are easy to mock:

**1. Use dependency injection**

Pass external dependencies in rather than creating them internally:

JavaScript:

```javascript
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}
```

Python:

```python
def process_payment(order, payment_client):
    return payment_client.charge(order.total)
```

Kotlin:

```kotlin
fun processPayment(order: Order, paymentClient: PaymentClient) =
    paymentClient.charge(order.total)
```

**2. Prefer SDK-style interfaces over generic fetchers**

Create specific functions for each external operation instead of one generic function with conditional logic:

The SDK approach means:
- Each mock returns one specific shape
- No conditional logic in test setup
- Easier to see which endpoints a test exercises
- Better type/contract clarity per endpoint
