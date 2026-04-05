# Good and Bad Tests

## Good Tests

Integration-style: verify observable behavior via public APIs.

JavaScript:

```javascript
test("checkout confirms valid cart", async () => {
  const result = await checkout(cartWith(product), paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Python:

```python
def test_checkout_confirms_valid_cart():
    result = checkout(cart_with(product), payment_method)
    assert result.status == "confirmed"
```

Kotlin:

```kotlin
@Test
fun checkoutConfirmsValidCart() {
    val result = checkout(cartWith(product), paymentMethod)
    assertEquals("confirmed", result.status)
}
```

Characteristics:

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

## Bad Tests

Implementation-detail tests are brittle.

Red flags:

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts/order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Verifying through external means instead of interface
