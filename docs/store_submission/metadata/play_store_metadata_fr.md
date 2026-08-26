# Google Play Console — IncaCook (FR)

## Identité
- **Nom de l'application** (30 car. max) : `IncaCook`
- **Package name** : `com.incacook.app`
- **Catégorie** : Food & Drink
- **Coordonnées** : e-mail de support à renseigner (obligatoire dans Play Console)

## Description courte (80 car. max)
```
Plats faits maison livrés près de chez vous. Vendez ou livrez avec IncaCook.
```
(78 caractères)

## Description complète (4000 car. max)
```
IncaCook connecte trois mondes : les gourmands qui veulent manger fait maison, les cuisinier(e)s qui veulent vendre leurs plats, et les livreurs qui veulent gagner de l'argent à leur rythme.

🍲 POUR LES ACHETEURS
• Découvrez des plats faits maison près de chez vous
• Commandez en quelques taps et suivez votre livraison en temps réel sur la carte
• Payez en toute sécurité par carte
• Notez et échangez avec les vendeurs via la messagerie intégrée

👩‍🍳 POUR LES VENDEURS
• Créez votre catalogue de plats en quelques minutes
• Gérez vos commandes, vos revenus et votre abonnement depuis un tableau de bord dédié
• Achetez vos ingrédients via le catalogue fournisseur intégré
• Recevez vos paiements directement sur votre compte bancaire

🛵 POUR LES LIVREURS
• Passez en ligne quand vous voulez, acceptez les livraisons disponibles autour de vous
• Suivez votre itinéraire de récupération et de livraison sur la carte
• Configurez vos paiements en quelques minutes et suivez vos gains
• KYC simple et rapide pour démarrer en toute confiance

🔒 SÉCURITÉ & CONFIANCE
• Vérification d'identité (KYC) pour les vendeurs et livreurs
• Système de signalement et de blocage pour la messagerie
• Connexion avec Google

Le goût de chez toi, près de chez toi.
```

## Éléments graphiques
| Asset | Spécification Play | Fichier fourni |
|---|---|---|
| Icône haute résolution | 512×512 PNG, 32-bit avec alpha | `android/icon_512.png` |
| Feature graphic | 1024×500 PNG/JPEG, sans alpha | `android/feature_graphic_1024x500.png` |
| Captures d'écran téléphone | 2–8, ratio 16:9 à 9:16, min 320px | `android/screenshots_phone/*.png` (1080×1920) |

## Détails du store listing
- **Étiquette de l'application (icône dans le launcher Android)** : déjà "IncaCook" (`android:label` dans `AndroidManifest.xml`)
- **Vidéo promo** : optionnelle, non fournie
- **Public cible** : 18 ans et plus (paiements réels, comptes vendeur/livreur avec KYC) — définir dans "Public cible et contenu"

## Politique de confidentialité
`https://incacook-admin.vercel.app/privacy`

## Compte utilisateur / Suppression de compte (section "Username and other authentication")
- **"Mon app ne permet pas aux utilisateurs de créer un compte"** → Ne pas cocher — l'app permet la création de compte (acheteur/vendeur/livreur).
- **Delete account URL** : `https://incacook-admin.vercel.app/data-deletion`
  - Cette page (mise à jour le 2026-08-26) satisfait les 3 exigences de Google : elle nomme IncaCook, détaille les étapes (in-app en priorité : Réglages → "Supprimer mon compte" ; e-mail en solution de secours), et précise explicitement quelles données sont supprimées immédiatement (KYC, avatar, jetons push, profil acheteur, accès de connexion) vs anonymisées et conservées indéfiniment (commandes, avis, portefeuille, profil vendeur/livreur, journal d'audit) vs soumises à une obligation légale de conservation (comptable/fiscale).
  - Ne pas confondre avec l'URL de la politique de confidentialité (champ séparé, ci-dessus) — Play Console demande les deux.

## Data safety (Sécurité des données)
À déclarer dans Play Console → Politique → Sécurité des données :
- **Localisation précise** — collectée ET partagée avec le livreur pendant une commande active ; utilisée pour la fonctionnalité de l'app (livraison), pas pour la pub. Le tracking en arrière-plan (livreur) est justifié par un foreground service Android réel (`ACCESS_BACKGROUND_LOCATION` + `FOREGROUND_SERVICE_LOCATION`, notification persistante "Livraison en cours" — vérifié dans le code, cf. section Permissions ci-dessous).
- **Infos personnelles** (nom, e-mail, téléphone, adresse) — collectées, requises pour créer un compte.
- **Infos et documents d'identité (sensibles)** — selfie KYC + pièce d'identité, requis pour la fonctionnalité vendeur/livreur. Validation de visage sur l'appareil avant envoi ; consentement explicite requis avant capture (#55). À déclarer dans la catégorie "Informations sur la santé/vérification d'identité" si Play Console la propose séparément des "Photos".
- **Infos financières** — traitées via Stripe (modèle Connect) ; IncaCook ne stocke pas les données de carte, uniquement une référence `stripeCustomerId`.
- **Messages** (chat acheteur-vendeur) — collectés, non partagés avec des tiers, modérés avec report/block (#54).
- **Chiffrement en transit** : cocher Oui — toutes les requêtes API passent par HTTPS (aucun endpoint `http://` non chiffré identifié dans le code, cf. audit App Store 2026-08-24).
- **Suppression de compte in-app** : cocher Oui — implémenté (#51) ; référencer l'URL ci-dessus.
- **Publicité / tracking tiers** : cocher Non — aucun SDK publicitaire ou d'attribution identifié.

## Classification du contenu (content rating questionnaire — IARC)
- Catégorie : Utilitaires / Productivité / Shopping (pas "Réseaux sociaux" à moins que le chat soit public)
- Répondre "Non" aux contenus violence/sexe/drogue
- "L'app permet-elle aux utilisateurs de communiquer entre eux ?" → **Oui** (chat acheteur-vendeur, modéré avec report/block)
- "L'app partage-t-elle la localisation avec d'autres utilisateurs ?" → **Oui** (livraison en temps réel)
→ Résultat attendu : PEGI 12 ou équivalent selon les réponses exactes (interactions utilisateurs non modérées peuvent monter la note — préciser que la modération existe si le questionnaire le permet)

## Notes de version — première publication
```
Première version d'IncaCook : commandez des plats faits maison, devenez vendeur ou livreur, et suivez tout en temps réel.
```

## Permissions Android — audit de nécessité (vérifié 2026-08-26)

Chaque permission déclarée dans `android/app/src/main/AndroidManifest.xml` a été
vérifiée contre le code réel — aucune permission inutilisée trouvée, aucune
permission manquante identifiée :

| Permission | Justifiée par | Statut |
|---|---|---|
| `INTERNET` | Tous les appels API | ✅ |
| `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` | `geolocator` — carte livreur, suivi de livraison, recherche d'adresse ("utiliser ma position") | ✅ |
| `ACCESS_BACKGROUND_LOCATION` | `location_service.dart` — suivi de position du livreur pendant une livraison active, app en arrière-plan | ✅ |
| `FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_LOCATION` | Foreground service Android réel confirmé dans le code (`ForegroundNotificationConfig`, `location_service.dart:141-157`) avec notification persistante "Livraison en cours" — pas une déclaration "au cas où" | ✅ |
| `CAMERA` | Photos de plats, selfie KYC (`image_picker`) | ✅ |
| `POST_NOTIFICATIONS` | Push FCM (commandes, statut livraison) | ✅ |
| `USE_BIOMETRIC` / `USE_FINGERPRINT` | Connexion biométrique optionnelle (`local_auth`) | ✅ |

**Pas de `RECORD_AUDIO`** sur Android — cohérent avec le retrait de
`NSMicrophoneUsageDescription` côté iOS le même jour : le bouton micro dans le
chat (`chat_input_field.dart`) est un `onPressed: widget.onMic ?? () {}` —
un no-op, aucune fonctionnalité d'enregistrement audio n'existe.

**Pas de `READ/WRITE_EXTERNAL_STORAGE`** — non nécessaire, `image_picker` et
`path_provider` utilisent le stockage scoped de l'app.

## Points d'attention Google Play
- **Politique sur les données utilisateur sensibles** : le KYC (selfie + détection de visage) doit être justifié dans Data Safety et respecter la Politique relative aux données personnelles et sensibles.
- **App bundle** : publier un `.aab` signé (App Bundle), pas un APK brut — `melos run build:android:aab`.
- **Target API level** : `targetSdk`/`compileSdk` sont hérités du SDK Flutter installé (`android/app/build.gradle.kts:53,72-73`), pas de valeur fixe dans le repo — vérifier avec `melos run verify:android:manifest` sur la machine qui produit réellement le build de soumission (cf. #62, toujours ouvert).
