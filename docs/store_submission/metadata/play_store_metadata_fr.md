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

## Data safety (Sécurité des données)
À déclarer dans Play Console → Politique → Sécurité des données (mêmes catégories que la privacy nutrition label iOS, à confirmer avec le backend) :
- **Localisation précise** — collectée, utilisée pour la fonctionnalité de l'app (livraison), partagée avec le livreur pendant une commande active
- **Infos personnelles** (nom, e-mail, téléphone, adresse) — collectées, requises pour créer un compte
- **Photos** (KYC selfie, photos de plats) — collectées, requises pour la fonctionnalité vendeur/livreur
- **Infos financières** — traitées via le prestataire de paiement (Stripe) — préciser si IncaCook les stocke ou seulement le prestataire
- **Messages** (chat acheteur-vendeur) — collectés, non partagés avec des tiers
- Cocher "Les données sont chiffrées en transit" si HTTPS partout (à confirmer)
- Cocher si un mécanisme de suppression des données existe → Oui (#51, suppression de compte)

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

## Points d'attention Google Play
- **Politique sur les données utilisateur sensibles** : le KYC (selfie + détection de visage) doit être justifié dans Data Safety et respecter la Politique relative aux données personnelles et sensibles.
- **Permissions Android** : vérifier que `AndroidManifest.xml` ne demande que les permissions réellement utilisées (localisation, caméra, stockage) — Play Console flague les permissions inutilisées.
- **App bundle** : publier un `.aab` signé (App Bundle), pas un APK brut.
- **Target API level** : vérifier `compileSdkVersion`/`targetSdkVersion` dans `android/app/build.gradle` respecte le minimum Play actuel (API 34+ au moment de la rédaction — à revérifier à la date de soumission).
