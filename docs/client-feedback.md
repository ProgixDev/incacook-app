# Client feedback — to action

Direct feedback from the client after a hands-on review of the app.
Original French quotes are preserved verbatim in blockquotes so nothing
is lost in translation; developer notes sit underneath each item.

Group is by **priority**, not by the order the client wrote them in.

---

## 1. Blockers (must fix first)

### 1.1 Listing photos don't upload, published dishes don't appear

> *"Si je comprends bien, tout n'est pas encore paramétré parce que j'ai
> pas pu insérer des photos de mes plats et je retrouve pas mes plats
> en ligne donc je pense que vous n'avez pas encore fait le lien."*

The seller flow isn't yet plugged into the backend end-to-end.

- The seller's `AddProductSheet` is still UI-only / reads from
  [`SellerProductMockData`](../lib/features/seller/data/seller_product_mock_data.dart).
- [`ListingsRepository`](../lib/features/catalog/data/repositories/listings_repository.dart)
  exists with the right endpoints (`POST/PATCH/DELETE /v1/listings`,
  `GET /v1/listings`, `GET /v1/listings/:id`,
  `GET /v1/sellers/me/listings`) but is **not registered** in
  [`main.dart`](../lib/main.dart) — `Get.find<ListingsRepository>()` will
  throw today.
- Photo upload must go through the two-step
  [`UploadsRepository`](../lib/features/authentication/data/repositories/uploads_repository.dart)
  flow (`POST /v1/uploads` → signed URL → `PUT` to Supabase), then pass
  the returned storage keys in `imageUrls` on the create-listing call.

**To-do**

1. Register `ListingsRepository` in `main.dart` alongside the other
   permanent services.
2. Replace mock data in the seller dashboard and `ClientHomeScreen` with
   real fetches.
3. Wire `AddProductSheet`'s photo picker into `UploadsRepository`, then
   submit the resulting keys to `POST /v1/listings`.

### 1.2 Fait-maison €4.50 cap must be a hard block

> *"… si on est dans le cas de fait Maison il faut que le tarif soit
> bloqué à 4,50 € et l'empêcher de mettre plus, sur l'appli, il est
> possible de mettre plus cher, il y a simplement l'indication de ne pas
> dépasser 4,50 €. Je pense qu'il faut aller au-delà de l'indication
> mais l'interdire pour la rubrique fait maison."*

Today the price field accepts >€4.50 and the form only disables the
submit button (no inline error). The backend already enforces the cap
(`INCACOOK_PRICE_CAP_EXCEEDED`), but the user shouldn't be able to type
the wrong value in the first place.

**To-do**

- In
  [`add_product_controller.dart`](../lib/features/seller/controllers/add_product_controller.dart),
  clamp the price input at the field level when
  `isFaitMaison == true`. Show an inline error / red border at the limit.
- Surface the cap as helper text (`"Plafond fait-maison : 4,50 €"`).
- Keep the `canSubmit` check as a belt-and-braces safety.

### 1.3 Empty filters must show everything

> *"Quand on est Client, et qu'on ne choisit pas de régime alimentaire
> ou bien de type de cuisine, il faut que tous les plats et tous les
> régimes apparaissent."*

The frontend already does this
([`filter_controller.dart`](../lib/features/client/controllers/filter_controller.dart):
`if (f.isEmpty) return source`). Verify the same holds once the buyer
feed is reading from `GET /v1/listings` — absent or empty filter params
must mean "no filter on that dimension", not "narrow to empty".

### 1.4 Order tracking copy must adapt to pickup vs delivery

> *"En tant que client, quand j'ai validé, ma commande est payée,
> lorsque je fais suivre ma commande, même si j'ai mis à retirer sur
> place, on constate qu'on est dans un cas de figure de livraison avec
> l'indication: 'Votre commande est en route.' Adapter ce commentaire
> en fonction de retirer sur place ou à livrer à domicile."*

[`order_bottom_sheet.dart`](../lib/features/orders/presentation/widgets/order_bottom_sheet.dart)
uses the same subtitle (`AppTexts.trackingArrivingSubtitle`) for both
fulfillment paths. The data is already there —
[`order_detail.dart`](../lib/core/models/order_detail.dart) exposes
`isDelivery` / `isPickup`.

**To-do**

- Pass the order (or just `isDelivery`) into `OrderBottomSheet`.
- Branch the title + subtitle in `_StageHeader`:
  - **Delivery** — keep "Votre nourriture est en route."
  - **Pickup** — "Votre commande vous attend chez le cuisinier."
    *(confirm exact wording with the client)*
- Add the new string(s) to
  [`text_strings.dart`](../lib/core/constants/text_strings.dart):
  `trackingArrivingSubtitlePickup` (+ title variant if it should differ).
- Also confirm with backend: for pickup orders the stage path should be
  `PREPARED → ARRIVED_PICKUP → DELIVERED` (skip `ON_THE_WAY` /
  `ARRIVED_DROPOFF`). If the backend currently advances every order
  through `ON_THE_WAY`, that's a separate bug to file.

### 1.5 Authentication: Facebook broken, email painful

> *"Connexion impossible avec Facebook. Possible avec Google. Difficile
> avec l'e-mail."*

- **Facebook**: not implemented in the codebase at all. Either remove
  the Facebook button from the sign-in / sign-up screens, or wire up a
  `POST /v1/auth/facebook` flow analogous to the Google one
  ([`AuthRepository.googleSignIn`](../lib/features/authentication/data/repositories/auth_repository.dart)).
  Recommend: **remove the button** until backend support exists, to stop
  promising a feature that doesn't work.
- **Email**: dig into the friction. Likely candidates:
  - Password strength meter blocking common passwords without clear
    explanation.
  - Email OTP verification: the temporary fallback (`/auth/email/*`) was
    added because SMS isn't live yet — confirm the codes actually arrive
    in production, not just dev (`123456` test code).
  - Validation error copy not user-friendly. Catch `ApiFailure.code` and
    show meaningful French copy, not raw `INCACOOK_VALIDATION` messages.
- Have the client walk through the exact email-signup steps so we can
  reproduce what's "difficile".

---

## 2. CGU / CGV (legal)

### 2.1 Wrong product name

> *"Changer le nom IncaCook dans les CGV. CG U."*

`IncaCook` appears somewhere in the CGU/CGV content and must be replaced
with **IncaCook**. These texts are served by the backend
(`GET /v1/charters/active`) — the fix is on the charter-content side
(database / seed migration), not in the Flutter app.

Search the backend repo for `IncaCook` and replace. After updating the
text, bump the **version** of the affected charters (`CGU`, `CGV`) so
existing users are forced to re-accept.

### 2.2 Harden the CGU / CGV to protect the platform

> *"Étoffer les CGU CGV pour se garantir et se prémunir de tout
> problèmes, insister fortement sur la responsabilité du Cuisinier.
> L'obliger à indiquer tous les allergènes et les ingrédients de son
> plat, lui demander de décrire précisément le plat, lui imposer de
> mettre à disposition une portion convenable pour une personne. Tout
> litige sur ces caractéristiques pourrait entraîner l'annulation du
> compte et le remboursement du plat au client."*

Legal text update + product enforcement:

- **Legal text** (backend charter content): add a section emphasising
  the cuisinier's responsibility. Required clauses:
  - Mandatory declaration of all allergens.
  - Mandatory ingredient list.
  - Mandatory accurate dish description.
  - Mandatory "single-person reasonable portion" commitment.
  - Sanctions on dispute: account suspension/termination + full refund
    to the buyer.
- **Product enforcement** (Flutter `AddProductSheet`): make these
  fields server-required and client-required:
  - `description` — non-empty, minimum length (e.g. 40 chars) so
    "Tajine" alone isn't acceptable.
  - `allergens` — at minimum require the seller to **explicitly
    confirm** "no allergens" via a checkbox; otherwise force at least
    one selected. Today an empty list is silently treated as "none
    declared", which is exactly the loophole the client wants closed.
  - `otherAllergens` — free-text fallback for things outside the EU-14.
  - Consider adding an `ingredients` text field if the legal text
    requires it — currently the model doesn't have one.
- Backend: extend `INCACOOK_*` codes if needed to surface "missing
  required allergen confirmation" as its own branchable error.

---

## 3. Cuisinier-declared extras (bread, drinks, sauces)

> *"Ajouter dans la rubrique Cuisinier, à savoir si ils ont du pain, ou
> des boissons disponibles qui pourraient remettre à la vente en
> proposant un prix pour ses articles supplémentaires que le client
> pourrait voir dans son interface."*

> *"Sur les plats quand le client choisit, il va payer les extras
> comme le pain, La sauce piquante sont à mettre uniquement si le
> Cuisinier en dispose, il ne faut pas le mettre par défaut."*

Today the dish detail screen shows hardcoded extras
([`product_detail.dart`](../lib/features/catalog/presentation/screens/product_detail.dart),
`_demoAddOns`). Need real seller-declared extras and they must only
appear when the seller has actually declared them.

**Design**: extras live on the **seller profile** as a small pantry
(bread, drinks, sauces…), not per-dish. A cook who has bread today has
bread for every dish they sell. Each listing automatically exposes the
seller's active extras as add-ons.

**To-do**

- Backend: `seller_extras` table (or similar), with
  `GET / PUT /v1/sellers/me/extras` for seller management. The
  `GET /v1/listings/:id` response should include the seller's active
  extras inline so the client gets them in one round-trip.
- Flutter:
  - New "Mes extras" section in the seller dashboard (separate screen
    or sub-section of `AddProductSheet`).
  - New repository method on `SellersRepository`:
    `getMyExtras()` / `putMyExtras(list)`.
  - Replace `_demoAddOns` in `ProductDetailScreen` with the extras
    returned from `GET /v1/listings/:id`.
  - **When the extras list is empty, hide the entire "Extras" section**
    (not an empty chip row). This satisfies "uniquement si le cuisinier
    en dispose".

---

## 4. Onboarding texts

> *"Le OnBoarding n'a pas été modifié, j'avais fait passer 4 textes
> qu'il fallait modifier. Dans le onboarding il faudrait qu'on comprenne
> bien qu'on peut obtenir avec cette appli des plats faits maison à
> prix très bas !"*

The 4 onboarding strings the client previously sent were never applied.
Action:

1. **Re-request the 4 specific texts from the client** (we don't have
   them on hand any more — they need to be re-sent or recovered from
   the original message).
2. Update the matching keys in
   [`text_strings.dart`](../lib/core/constants/text_strings.dart) —
   they're the ones used by the onboarding pages under
   [`lib/features/onboarding/`](../lib/features/onboarding/).
3. Make sure the overall onboarding copy communicates the value-prop
   explicitly: **plats faits maison à prix très bas**. If none of the
   four screens says that today, the current strings need a top-down
   rewrite, not just a swap.

---

## 5. New features the client wants

These are net-new product work, not bug fixes. Group separately so
priority is clear.

### 5.1 Dish-photo enhancement

> *"Amélioration de photo des plats (flou arrière…)"*

The client wants a polished look for dish photos — likely an automatic
background blur or depth effect so amateur photos look professional.

Options to evaluate:

- **Client-side**: apply a subtle background blur / gradient overlay
  inside the listing card / detail widget. Cheap, no backend work.
- **Upload-time post-processing**: a backend image pipeline (e.g.
  Supabase + a function) that generates a blurred-background variant
  on upload. More work but better results.

Confirm scope with the client before implementing.

### 5.2 Featured listings — "Mise à la Une"

> *"Les options de mise à la Une."*

A paid (presumably) option for sellers to boost a dish to a featured
position in the buyer feed. Needs:

- Data model: `is_featured` flag on `listings` + `featured_until`
  timestamp.
- Backend: feed ranking honors featured items; endpoint to purchase /
  toggle featuring.
- Payment hook: Stripe charge for the boost (one-off or subscription —
  clarify).
- UI: badge on the listing card, "Mettre à la Une" CTA in the seller
  dashboard.

Specifics to gather from client: cost, duration, how many can be
featured at once, who sees them.

### 5.3 Subscriptions

> *"Les abonnements."*

Underspecified — needs a clarifying conversation with the client.
Possibilities:

- **Buyer subscription** (à la Uber One): reduced or free delivery
  fees, exclusive access, etc.
- **Seller subscription**: premium tier unlocking featured listings,
  higher limits, lower commission.
- **Subscription-as-a-product**: a cuisinier sells a weekly menu /
  meal-plan subscription to recurring buyers.

Schedule a scoping call before committing to any data-model work.

### 5.4 Listings with a countdown timer

> *"Le catalogue articles à vendre - annonce avec un compte à rebours…"*

Fait-maison listings already have an `expiresAt` on the model — surface
a visible countdown timer on the listing card and detail screen
("Disponible encore 2h 14min"). For permanent-menu items (`expiresAt`
is null), don't render a countdown.

**To-do**

- Add a countdown widget driven by `listing.expiresAt`.
- Auto-refresh / auto-hide the listing once the timer hits 0 (client
  side) — backend already excludes expired listings from the feed.

### 5.5 "Three rubrics" on the client home — explain or rename

> *"Quand on est Client, on voit trois rubriques, « plats près de toi »,
> « cuisine près de toi » et « partage solitaire » : à quoi ça
> correspond ?"*

The client doesn't understand what the three sections mean. Either:

- **Rename** them to something self-explanatory, or
- **Add a short subtitle / tooltip** on each rubric explaining the
  difference.

In particular, **"partage solitaire"** is opaque — clarify what it's
meant to represent (a single-portion sharing flow? solo-meal listings?)
and either rename it to match its actual behaviour or drop it if the
underlying feature isn't built yet.

Check the labels in
[`client_home.dart`](../lib/features/client/presentation/screens/client_home.dart)
and the strings in
[`text_strings.dart`](../lib/core/constants/text_strings.dart).
Confirm wording with the client.

---

## 6. Quick reference — files most often touched

| Area | File |
|---|---|
| Add-product form | [`add_product_controller.dart`](../lib/features/seller/controllers/add_product_controller.dart), [`add_product_sheet.dart`](../lib/features/seller/presentation/widgets/add_product_sheet.dart) |
| Buyer feed | [`client_home.dart`](../lib/features/client/presentation/screens/client_home.dart), [`filter_controller.dart`](../lib/features/client/controllers/filter_controller.dart) |
| Dish detail | [`product_detail.dart`](../lib/features/catalog/presentation/screens/product_detail.dart) |
| Order tracking | [`order_bottom_sheet.dart`](../lib/features/orders/presentation/widgets/order_bottom_sheet.dart), [`order_detail.dart`](../lib/core/models/order_detail.dart) |
| Listings backend | [`listings_repository.dart`](../lib/features/catalog/data/repositories/listings_repository.dart) (not yet registered) |
| Photo uploads | [`uploads_repository.dart`](../lib/features/authentication/data/repositories/uploads_repository.dart) |
| GetX registration | [`main.dart`](../lib/main.dart) |
| Onboarding copy | [`text_strings.dart`](../lib/core/constants/text_strings.dart), [`lib/features/onboarding/`](../lib/features/onboarding/) |
| Charters (CGU / CGV) | served by backend `GET /v1/charters/active`; content lives in backend repo |

---

## 7. Suggested order of work

1. **§1.1** — register `ListingsRepository`, wire `AddProductSheet` to
   it, hook up `UploadsRepository` for photos. Unblocks everything else
   seller-side.
2. **§1.2** — hard-block fait-maison price input at €4.50.
3. **§1.3 + §1.4** — empty-filter sanity check + pickup-vs-delivery
   tracking copy. Both small, both improve immediate buyer UX.
4. **§1.5** — remove the Facebook button (or wire it up); diagnose the
   email-signup friction.
5. **§2** — coordinate with legal to rewrite CGU/CGV (rename IncaCook →
   IncaCook, add cuisinier-responsibility clauses); bump charter
   versions to force re-acceptance.
6. **§3** — seller-declared extras (backend table + endpoints, then
   Flutter UI + dish-detail integration).
7. **§4** — onboarding text rewrite (after recovering the 4 strings
   from the client).
8. **§5** — net-new features (photo enhancement, mise à la Une,
   subscriptions, countdown, rubric renaming). Scope each with the
   client before building.
