# Verify mobile PaymentSheet and order-payment recovery

- **GitHub:** [Verify mobile PaymentSheet and order-payment recovery](https://github.com/ProgixDev/incacook-app/issues/10)
- **Scope:** mobile
- **Mode:** AFK research
- **Depends on:** backend order payment lifecycle
- **Produces:** client/server sequence and failure-handling cases

## Question

Does the Flutter checkout create, present, confirm, and recover Stripe order
payments without fake methods, duplicate orders, stuck pending states, or
client-side success that disagrees with the webhook-authoritative backend?

## Test boundary

Contract and widget tests cover success, cancellation, authentication-required,
network loss after confirmation, webhook delay, and app restart.
