# Stripe go-live checklist — IncaCook platform account

Context: platform account `acct_1TdvHCBSdl9ByXxu` is currently a test-mode
placeholder (`business_profile.name = "environnement de test INCACOOK"`,
personal `@yahoo.fr` contact, no url/MCC/support fields set — confirmed via
direct Stripe API query, DEC-7). This is the account other sellers/drivers
connect to via Stripe Connect Express, so verifying *this* account is what
unlocks live-mode keys for the whole platform — not something per-seller.

This is a checklist to take into the Stripe Dashboard yourself
(**Settings → Business settings → Business details**) — none of this can be
done by an agent; Stripe requires the account holder to verify their own
identity.

## 1. Decide account type first

Stripe asks this before anything else — pick based on how IncaCook is
actually legally set up in France:

- [ ] **Individual / auto-entrepreneur** — you personally, trading under
      your own name or a `micro-entreprise` registration.
- [ ] **Company** — a registered legal entity (SARL, SAS, SASU, etc.).

Whichever it is, it must match reality — Stripe cross-checks against
France's business registry (INSEE/SIRENE) and will reject a mismatch.

## 2. Business details Stripe will ask for

- [ ] **Legal business name** (matching your registration exactly)
- [ ] **SIRET number** (14 digits) — or SIREN if SIRET isn't yet issued
- [ ] **Business address** — the real registered address, not a placeholder
- [ ] **Industry / MCC (merchant category code)** — food delivery / marketplace
      is the honest category; picking the wrong one can flag the account
      later
- [ ] **Business website URL** — Stripe checks this is live and describes
      what the business actually does. If IncaCook has no public marketing
      site yet, this is worth having ready before starting (even a simple
      one-pager) — Stripe's review can stall without it
- [ ] **Support contact** — a real business email/phone, not the personal
      `@yahoo.fr` address currently on file
- [ ] **Estimated processing volume / average transaction size** — rough
      honest estimates are fine

## 3. Representative / owner identity verification

- [ ] **Full legal name, date of birth, address** of whoever is registering
      (the account representative)
- [ ] **Government ID** — passport or French ID card, uploaded directly in
      Stripe's flow (never share this with anyone else, including me)
- [ ] If a **Company**: identity details for any beneficial owner holding
      ≥25% — Stripe will ask for each one separately

## 4. Bank account for payouts

- [ ] A **real French IBAN** in the business's name (or the individual's
      name, for sole-trader accounts) — this is where the platform's own
      revenue lands, separate from the Connect payouts to sellers/drivers
- [ ] Stripe may do a small verification deposit/charge — check for it and
      confirm when prompted

## 5. Terms of service acceptance

- [ ] Stripe Connect platform terms (accepting on behalf of the platform,
      not any individual seller/driver)

## 6. What happens after Stripe approves

Stripe's review can take anywhere from minutes to a few business days
depending on the industry/volume flags. Once approved:

- [ ] Live-mode API keys (`sk_live_…`/`pk_live_…`) become available in the
      Dashboard
- [ ] Come back here — the engineering cutover is a separate checklist
      (swapping the deployed keys, re-enabling the K-9 startup guard that's
      currently downgraded to a warning, and setting up a real prod/dev
      environment split on Railway since today there's only one environment
      doing double duty). None of that should happen before Stripe approval
      — flipping keys on an unverified account just moves the same problem.

## Do not do in this session

- Do not paste your SIRET, ID document contents, bank account/IBAN, or any
  Stripe verification codes into this chat. Enter them directly in Stripe's
  own dashboard.
