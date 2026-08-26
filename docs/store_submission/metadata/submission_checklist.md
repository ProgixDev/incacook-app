# IncaCook — checklist de soumission App Store / Play Store

## Ce qui a été généré dans ce dossier
```
docs/store_submission/
├── ios/
│   ├── icon_1024.png                 — icône App Store (1024×1024, sans alpha)
│   └── screenshots_6.9in/            — 4 captures, 1320×2868 (iPhone 6.9")
├── android/
│   ├── icon_512.png                  — icône Play Store (512×512)
│   ├── feature_graphic_1024x500.png  — bannière "feature graphic"
│   └── screenshots_phone/            — 4 captures, 1080×1920
├── metadata/
│   ├── app_store_metadata_fr.md      — fiche App Store Connect complète
│   ├── play_store_metadata_fr.md     — fiche Play Console complète
│   └── submission_checklist.md       — ce fichier
└── generate_assets.py                — script régénérant tout ce qui précède
```

## ⚠️ Avant de publier — à vérifier vous-même
1. **Résolution source des captures d'écran.** Les 4 captures fournies (WhatsApp) ne font que 592×1280 px — nettement en dessous de la résolution cible (1320×2868 / 1080×1920). Le rendu reste net à l'écran normal, mais si vous zoomez sur les stores, ça se voit. **Recommandé avant la vraie soumission** : recapturer ces 4 écrans nativement en pleine résolution (simulateur iPhone 16 Pro Max ou `xcrun simctl io booted screenshot`, émulateur Android Pixel), puis relancer `python3 docs/store_submission/generate_assets.py` en pointant vers les nouveaux fichiers dans `assets/screenshots/`.
2. **Capture 4 (adresse)** contenait une adresse réelle ("Bd André Malraux, 78990 Élancourt") — elle a été masquée par un bandeau "Adresse masquée" dans la version générée. Si vous recapturez cet écran, utilisez une adresse fictive dès le départ pour éviter tout problème.
3. **Nombre de captures** : Apple exige 3 à 10 captures par taille d'affichage, Google 2 à 8. 4 suffisent pour publier mais 6–8 convertissent mieux (ajoutez des écrans de menu plats, chat, notation, etc. si disponibles).
4. **`Info.plist`** : les textes `NSPhotoLibraryUsageDescription`/`NSMicrophoneUsageDescription` sont en anglais alors que le reste de l'app est en français — pas bloquant pour la revue, mais à uniformiser en français par cohérence produit.
5. **Comptes de démo** pour la revue Apple : préparez un compte acheteur + un compte vendeur/livreur déjà KYC-validé (voir `app_store_metadata_fr.md`), sinon la revue sera bloquée dès qu'elle atteint un écran nécessitant une vérification d'identité.
6. **Data Safety / App Privacy** : les tableaux dans les deux fichiers de métadonnées sont une base — à faire valider par la personne qui connaît précisément ce que le backend stocke (Stripe, Firebase, etc.) avant de cocher les cases dans les consoles.
7. **App Bundle Android** : publier un `.aab` signé, pas un APK.
8. **Version courante** : `pubspec.yaml` est à `1.0.0+30` — vérifiez que c'est bien le numéro de build que vous voulez pour la première soumission publique (30 builds internes suggère que ce n'est probablement pas votre première release TestFlight/interne — normal, juste à confirmer).

## Ordre de soumission recommandé
1. Créer les fiches (App Store Connect + Play Console) avec les textes fournis.
2. Uploader icônes + captures + feature graphic.
3. Remplir Data Safety (Android) et App Privacy (iOS) avec la bonne personne côté backend.
4. Build + upload (`flutter build ipa`, `flutter build appbundle`).
5. Renseigner comptes de démo + notes pour la revue Apple.
6. Soumettre en review interne (TestFlight / Internal testing) avant la review publique.

## Régénérer les assets après modification
```bash
python3 docs/store_submission/generate_assets.py
```
Remplacez les fichiers dans `assets/screenshots/` (garder les mêmes noms de suffixe `23.42.20`, `23.42.20 (1)`, `(2)`, `(3)`, ou éditez le mapping en bas de `generate_assets.py`) puis relancez le script.
