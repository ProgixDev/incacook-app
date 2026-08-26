# App Store Connect — IncaCook (FR)

## Identité
- **Nom de l'app** (30 car. max) : `IncaCook`
- **Sous-titre** (30 car. max) : `Repas maison, livrés vite` (26 car.)
- **Bundle ID** : `com.incacook.app`
- **SKU** : `incacook-ios` (ou existant si déjà créé)
- **Catégorie principale** : Food & Drink (Nourriture et boissons)
- **Catégorie secondaire** : Shopping
- **Copyright** : `© 2026 IncaCook`

## Texte promotionnel (170 car. max — modifiable sans nouvelle version)
```
Commandez des plats faits maison près de chez vous, ou devenez vendeur ou livreur IncaCook. Paiement sécurisé, suivi en temps réel.
```

## Description (4000 car. max)
```
IncaCook connecte trois mondes : les gourmands qui veulent manger fait maison, les cuisinier(e)s qui veulent vendre leurs plats, et les livreurs qui veulent gagner de l'argent à leur rythme.

POUR LES ACHETEURS
• Découvrez des plats faits maison près de chez vous
• Commandez en quelques taps et suivez votre livraison en temps réel sur la carte
• Payez en toute sécurité par carte
• Notez et échangez avec les vendeurs via la messagerie intégrée

POUR LES VENDEURS
• Créez votre catalogue de plats en quelques minutes
• Gérez vos commandes, vos revenus et votre abonnement depuis un tableau de bord dédié
• Achetez vos ingrédients via le catalogue fournisseur intégré
• Recevez vos paiements directement sur votre compte bancaire

POUR LES LIVREURS
• Passez en ligne quand vous voulez, acceptez les livraisons disponibles autour de vous
• Suivez votre itinéraire de récupération et de livraison sur la carte
• Configurez vos paiements en quelques minutes et suivez vos gains
• KYC simple et rapide pour démarrer en toute confiance

SÉCURITÉ & CONFIANCE
• Vérification d'identité (KYC) pour les vendeurs et livreurs
• Système de signalement et de blocage pour la messagerie
• Connexion biométrique (Face ID / Touch ID) en option
• Connexion avec Apple ou Google

Le goût de chez toi, près de chez toi.
```

## Mots-clés (100 car. max, séparés par des virgules, sans espace après la virgule)
```
plats maison,livraison repas,cuisine locale,vendeur cuisine,livreur,repas fait maison,foodtech
```
*(vérifier le nombre de caractères exact dans App Store Connect — ajuster si nécessaire)*

## URLs
- **URL marketing** : à définir (site vitrine IncaCook, si disponible — sinon laisser vide)
- **URL du support** : à définir — pas de page `/support` publique sur `incacook-admin.vercel.app` à ce jour ; utiliser une adresse e-mail dédiée en attendant, ou en créer une (le bouton "Obtenir de l'aide" in-app pointe vers `_openSupport()` dans `settings.dart` — vérifier ce qu'il ouvre réellement avant de choisir l'URL ici)
- **URL de la politique de confidentialité** : `https://incacook-admin.vercel.app/privacy`
- **URL de suppression de compte** (si demandée séparément) : `https://incacook-admin.vercel.app/data-deletion`

## Notes de version (What's New) — première soumission
```
Première version d'IncaCook : commandez des plats faits maison, devenez vendeur ou livreur, et suivez tout en temps réel.
```

## Classification par âge (Age Rating questionnaire)
Répondre "Non" à tout contenu sensible (violence, contenu adulte, jeux d'argent, etc.) sauf :
- **Interactions utilisateur non modérées / Communication entre utilisateurs** → Oui (messagerie acheteur-vendeur) → déclenche généralement 17+ à cause de "Unrestricted Web Access"/UGC non modéré, MAIS comme la messagerie est modérée (report + block, cf. #54) et fermée (pas de découverte publique d'inconnus), sélectionner les réponses en conséquence dans le nouveau questionnaire (App Store Connect a remplacé l'ancien "4+/9+/12+/17+" par un système de descripteurs — répondre honnêtement, la note en résultera).
- Prévoir 18+ minimum pour créer un compte vendeur/livreur si paiements réels impliqués → cf. section KYC.

## Confidentialité (App Privacy / "Nutrition label")
Types de données confirmés (contenu réel de la politique de confidentialité, `incacook-admin` `app/(public)/privacy/page.tsx`) :
- **Contact Info** : nom, email, téléphone (compte) — Linked to you
- **Location** : position précise (livraison, carte livreur), y compris en arrière-plan pour les livreurs pendant une livraison active — Linked to you
- **Financial Info** : infos de paiement traitées par Stripe (modèle Connect — IncaCook ne stocke pas les données de carte, seul un `stripeCustomerId` de référence est conservé) — Linked to you
- **Sensitive Info** : photo de vérification d'identité (selfie KYC), document d'identité — validation de visage effectuée sur l'appareil avant envoi (cf. #45), consentement explicite requis avant capture (cf. #55) — Linked to you
- **User Content** : messages (chat acheteur/vendeur, modéré avec report/block — #54), photos de plats
- **Identifiers** : ID utilisateur, ID appareil (jeton FCM push)
- **Diagnostics** : aucun SDK de crash-reporting tiers identifié dans `pubspec.yaml` à ce jour — ne pas déclarer Crashlytics/Sentry sauf ajout futur

**Tracking (ATT)** : Non — aucun SDK publicitaire ni d'attribution ne collecte l'IDFA (confirmé, cf. audit App Store 2026-08-24). Ne pas déclencher le prompt App Tracking Transparency.

**Suppression de compte** : implémentée in-app (#51) — mentionner dans "App Privacy" que les utilisateurs peuvent supprimer leur compte et leurs données directement dans l'app.

## Compte de démonstration pour la revue Apple
Fournir dans "App Review Information" :
- Un compte **acheteur** de test (email + mot de passe)
- Un compte **vendeur** de test déjà avec KYC validé (pour montrer le tableau de bord sans blocage)
- Un compte **livreur** de test déjà avec KYC validé
- Note : "Le compte vendeur/livreur nécessite une vérification d'identité (KYC) ; le compte de test fourni est déjà validé pour permettre à l'équipe de revue d'explorer toutes les fonctionnalités."

## Points d'attention Apple (guideline compliance)
- **Paiements** : les paiements de repas/livraison sont des biens/services physiques → autorisés hors In-App Purchase (Guideline 3.1.5). Vérifier qu'aucun contenu numérique n'est vendu via un système de paiement tiers sans IAP.
- **Sign in with Apple** : déjà implémenté (#53) — obligatoire si Google/Facebook Sign-In est proposé (Guideline 4.8). ✅
- **Suppression de compte** : déjà implémenté (#51) — requis par Guideline 5.1.1(v). ✅
- **Contenu généré par les utilisateurs (chat)** : modération + report/block déjà en place (#54) — requis par Guideline 1.2. ✅
- **Permissions runtime — vérifiées le 2026-08-26** :
  - `NSCameraUsageDescription`, `NSFaceIDUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription` : chacune correspond à une fonctionnalité réelle et utilisée. ✅
  - `NSMicrophoneUsageDescription` : **retirée d'`Info.plist`** — aucune fonctionnalité d'enregistrement audio/vidéo n'existe dans le code (seul `ImagePicker().pickImage`, jamais `pickVideo`) ; la description ("video recordings attached to listings") ne correspondait à rien de réel et aurait pu déclencher une question de l'équipe de revue.
  - Incohérence de langue restante (Caméra/Face ID en français, Location/Photos en anglais) : non corrigée dans ce passage (cf. ticket #60), sans impact sur la fonctionnalité.
