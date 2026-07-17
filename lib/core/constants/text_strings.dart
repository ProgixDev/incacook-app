class AppTexts {
  //* welcome screen
  static const String welcomeBrand = "IncaCook";
  static const String welcomeTagline = "Le goût de chez toi, près de chez toi";
  static const String welcomeSkip = "Passer";
  // static const String welcomeContinueWith = "Continuer";
  static const String welcomeContinueWithFacebook = "Facebook";
  static const String welcomeContinueWithGoogle = "Google";
  static const String welcomeSignUpEmail = "S'inscrire avec e-mail";
  static const String welcomeAlreadyAccount = "Déjà un compte ?";

  //* social auth — complete email step (OAuth identity returned no email)
  static const String completeEmailTitle = "Ajoutez votre adresse e-mail";
  static const String completeEmailSubtitle =
      "Votre connexion n'a pas communiqué d'adresse e-mail. Ajoutez-en une "
      "pour finaliser votre inscription.";
  static const String completeEmailLabel = "Adresse e-mail";
  static const String completeEmailSendCta = "Envoyer le code";
  static const String completeEmailSendLinkCta =
      "Envoyer le lien de vérification";
  static const String completeEmailLinkSent =
      "Un lien de vérification a été envoyé à votre email. Cliquez sur le lien "
      "pour continuer.";
  static const String completeEmailVerifiedButton = "J'ai vérifié mon email";
  static const String completeEmailVerifiedSuccess =
      "Email vérifié avec succès";
  static const String completeEmailNotVerifiedYet =
      "Pas encore vérifié. Ouvrez le lien reçu par email, puis revenez ici.";
  static const String completeEmailHaveCode = "J'ai reçu un code à la place";
  // Button states for the "open the link, then come back" flow.
  static const String completeEmailWaiting = "En attente de vérification…";
  static const String completeEmailContinueCta = "Continuer";
  static const String completeEmailCheckNow = "Vérifier maintenant";
  static const String completeEmailDetected =
      "Email vérifié ✓ Appuyez sur « Continuer » pour finaliser.";
  static const String completeEmailInvalid = "Adresse e-mail invalide.";
  static const String completeEmailOtpTitle = "Vérifiez votre e-mail";
  static const String completeEmailVerifyCta = "Vérifier";
  static const String completeEmailResendCta = "Renvoyer le code";
  static const String completeEmailChangeCta = "Modifier l'adresse";
  static const String completeEmailError =
      "Une erreur est survenue. Veuillez réessayer.";
  static const String completeEmailInvalidCode = "Code invalide. Réessayez.";
  static String completeEmailOtpSubtitle(String email) =>
      "Entrez le code à 6 chiffres envoyé à $email.";

  //* social auth — error copy
  static const String googleSignInTitle = "Connexion Google";
  static const String googleSignInError =
      "Connexion Google impossible. Veuillez réessayer.";
  static const String facebookSignInTitle = "Connexion Facebook";
  static const String facebookSignInError =
      "Connexion Facebook impossible. Veuillez réessayer.";
  static const String facebookNoEmailError =
      "Connexion Facebook impossible : Facebook n'a pas retourné d'adresse "
      "e-mail. Vérifiez que le compte Facebook possède une adresse e-mail "
      "confirmée.";

  //* social auth — Facebook missing-email manual fallback (OTP by e-mail)
  static const String fbEmailFallbackNotice =
      "Facebook n'a pas retourné votre adresse e-mail. Vous pouvez continuer "
      "en saisissant votre e-mail manuellement.";
  static const String fbEmailStepTitle = "Adresse e-mail requise";
  static const String fbEmailStepMessage =
      "Facebook n'a pas retourné votre adresse e-mail. Veuillez saisir une "
      "adresse e-mail pour continuer.";
  static const String fbEmailLabel = "Adresse e-mail";
  static const String fbEmailSendCodeCta = "Recevoir le code";
  static const String fbEmailInvalid =
      "Veuillez saisir une adresse e-mail valide.";
  static const String fbOtpStepTitle = "Vérification de l'e-mail";
  static const String fbOtpStepMessage = "Entrez le code reçu par e-mail.";
  static const String fbOtpLabel = "Code OTP";
  static const String fbOtpVerifyCta = "Vérifier";
  static const String fbOtpResendCta = "Renvoyer le code";
  static const String fbEmailChangeCta = "Modifier l'adresse";
  static const String fbEmailCancelCta = "Annuler";
  static const String fbEmailGenericError =
      "Une erreur est survenue. Veuillez réessayer.";
  static const String fbEmailInvalidCode = "Code invalide ou expiré.";
  static const String fbEmailCodeSent =
      "Un code à 6 chiffres a été envoyé à votre adresse e-mail.";
  static const String fbEmailVerifiedSuccess = "Adresse e-mail vérifiée.";

  //* network — transport error copy
  static const String serverUnreachableError =
      "Connexion au serveur impossible. Vérifiez que le backend est lancé.";
  static const String serverTimeoutError =
      "Le serveur met trop de temps à répondre. Veuillez réessayer.";

  //* on boarding text
  static const String onBoardingTitle1 = "Découvrez des plats faits maison";
  static const String onBoardingTitle2 = "Aidez votre communauté";
  static const String onBoardingTitle3 = "Luttez contre le gaspillage";

  static const String onBoardingTitle11 = "Notre philo";
  static const String onBoardingTitle21 = "Sauve Ton Plat";
  static const String onBoardingTitle31 = "L’Atelier Traiteur";
  static const String onBoardingTitle41 = "Le Bon Fait Maison";

  static const String onBoardingSubTitle1 =
      "Explorez une grande variété de plats préparés avec amour par des cuisiniers locaux. Trouvez chaque jour de nouvelles saveurs à savourer.";
  static const String onBoardingSubTitle2 =
      "En commandant, vous soutenez les vendeurs locaux et contribuez à une économie de partage solidaire.";
  static const String onBoardingSubTitle3 =
      "Chaque commande aide à sauver des invendus et à réduire le gaspillage alimentaire. Ensemble, faisons la différence.";

  static const String onBoardingSubTitle11 =
      "Chaque commande compte. Moins de gaspillage, plus de partage et une récompense plus juste pour ceux qui cuisinent avec passion.";
  static const String onBoardingSubTitle21 =
      "Les meilleurs plats ne devraient jamais finir à la poubelle. Retrouvez les surplus du jour de vos restaurants préférés et savourez des repas de qualité à prix réduit.";
  static const String onBoardingSubTitle31 =
      "Un cocktail, une réception, un événement ? Nos traiteurs vous proposent des créations gourmandes faites maison, prêtes à régaler vos invités.";
  static const String onBoardingSubTitle41 =
      "Oups, j'en ai préparé un peu trop pour ma famille ! Plutôt que de gaspiller ces bons petits plats faits maison, je vous propose d'en profiter.";

  //* authentication Forum text
  static const String firstName = "Prénom";
  static const String lastName = "Nom de famille";
  static const String email = "E-mail";
  static const String password = "Mot de passe";
  static const String username = "Nom d'utilisateur";
  static const String phoneNumber = "Numéro de téléphone";
  static const String rememberMe = "Se souvenir de moi";
  static const String forgetPassword = "Mot de passe oublié?";
  static const String signIn = "Se connecter";
  static const String createAccount = "Créer un compte";
  static const String orSignInWith = "Ou se connecter avec";
  static const String orSignUpWith = "Ou s'inscrire avec";
  static const String verificationCode = "Code de vérification";
  static const String iAgreeTo = "J'accepte";
  static const String privacy = "Politique de confidentialité";
  static const String and = "et";
  static const String terms = "Conditions d'utilisation";

  //* authentication heading text
  static const String loginTitle = "Bienvenue!";
  static const String loginSubtitle = "Reconnectez-vous à votre compte";
  static const String signUpTitile = "Créons votre compte";

  //* user type selection
  static const String userTypeHeading =
      "À table, aux fourneaux ou sur la route ?";
  static const String userTypeSubHeading =
      "Choisissez l'option qui vous convient le mieux. Vous pouvez toujours contacter le support pour la modifier plus tard";

  static const String userTypeSellerTitle = "Restaurateur / Cuisinier";
  static const String userTypeSellerSubtitle =
      "Cuisinier passionné ou restaurateur ? Partagez vos plats et attirez les gourmands du quartier";

  static const String userTypeClientTitle = "j’ai faim…";
  static const String userTypeClientSubtitle =
      "Votre prochain coup de cœur culinaire est à portée de clic !";

  static const String userTypeDeliveryTitle = "C'est moi qui livre !";
  static const String userTypeDeliverySubtitle =
      "Prenez la route, livrez des plats chauds et gérez votre temps comme vous voulez";

  //* seller-specific fields
  static const String restaurantName = "Nom du restaurant";
  static const String restaurantAddress = "Adresse du restaurant";

  //* delivery-specific fields
  static const String vehicleType = "Type de véhicule";
  static const String licenseNumber = "Numéro de permis";

  //* forgot password screen
  static const String forgetPasswordTitle = "Mot de passe oublié ?";
  static const String forgetPasswordSubTitle =
      "Saisis ton e-mail : nous t'enverrons un code de réinitialisation à 6 chiffres.";
  static const String submit = "Soumettre";

  //* reset password (code + new password) screen
  static const String resetPasswordTitle = "Réinitialise ton mot de passe";
  static const String resetPasswordSubTitle =
      "Saisis le code reçu par e-mail et choisis un nouveau mot de passe.";
  static const String resetCodeLabel = "Code de vérification";
  static const String resetCodeRequired = "Code requis";
  static const String resetCodeInvalid = "Code à 6 chiffres";
  static const String newPasswordLabel = "Nouveau mot de passe";
  static const String confirmNewPasswordLabel = "Confirme le mot de passe";
  static const String passwordsDoNotMatch =
      "Les mots de passe ne correspondent pas";
  static const String resetPasswordCta = "Réinitialiser";
  static const String resendCode = "Renvoyer le code";
  static const String resetPasswordSuccess =
      "Mot de passe modifié. Connecte-toi avec ton nouveau mot de passe.";
  static const String resetCodeInvalidOrExpired = "Code invalide ou expiré.";

  static const String changeYourPasswordTitle =
      "E-mail de réinitialisation du mot de passe envoyé !";
  static const String changeYourPasswordSubTitle =
      "Honnêtement, je n'ai rien à dire ici";
  static const String sayDone = "Terminé";
  static const String resendEmail = "Renvoyer l'e-mail";

  static const String confirmEmail = "Vérifiez votre adresse e-mail !";
  static const String confirmEmailSubtitle =
      "Félicitations ! Votre compte vous attend, veuillez vérifier votre e-mail pour commencer à l'utiliser";

  static const String sayContinue = "Continuer";

  //* success screen
  static const String yourAccountCreatedTitle =
      "Votre compte a été créé avec succès !";
  static const String yourAccountCreatedSubtitle =
      "Félicitations, vous pouvez maintenant commencer à explorer l'application";

  //* home appbar title
  static const String clientHomeAppbarTitle = "Bonjour";
  static const String clientHomeAppbarSubtitle =
      "Vous vous sentez bien aujourd'hui ?";

  //* profile screen
  static const String profileTitle = "Profil";
  static const String profileSectionSettings = "Paramètres";
  static const String profileSectionSupport = "Support";
  static const String profileEditAccount = "Modifier le compte";
  static const String profileActionEditProfile = "Profil";
  static const String profileActionPreferences = "Préférences";
  static const String profileActionPayment = "Paiement";

  //* Settings menu — account
  static const String settingsWallet = "Mon portefeuille";
  static const String settingsOrders = "Vos commandes";
  static const String settingsPay = "Payer avec Cravk";
  static const String settingsVouchers = "Bons de réduction";
  static const String settingsPro = "Cravk pro";

  //* Settings menu — support
  static const String settingsAddresses = "Mes adresses";
  static const String settingsAppearance = "Apparence";
  static const String settingsGetHelp = "Obtenir de l'aide";
  static const String settingsAboutApp = "À propos de l'application";
  // Support contact opened by "Obtenir de l'aide" (mailto). CONFIRM this is the
  // real support address before release.
  static const String supportEmail = "support@incacook.app";
  static const String supportEmailSubject = "Aide IncaCook";
  static const String supportUnavailable =
      "Aucune application e-mail. Écrivez-nous à support@incacook.app";
  static const String appName = "IncaCook";
  static const String appLegalese = "© 2026 IncaCook";
  static const String settingsLogout = "Se déconnecter";
  static const String settingsLogoutConfirmTitle = "Se déconnecter";
  static const String settingsLogoutConfirmBody =
      "Tu devras te reconnecter pour accéder à ton compte.";
  static const String settingsLogoutConfirmCancel = "Annuler";
  static const String settingsLogoutConfirmAction = "Se déconnecter";

  //* Appearance sheet
  static const String appearanceSheetTitle = "Apparence";
  static const String appearanceSystem = "Système";
  static const String appearanceLight = "Clair";
  static const String appearanceDark = "Sombre";

  //* Saved addresses sheet
  static const String addressesSheetTitle = "Mes adresses";
  static const String addressesAddNew = "Ajouter une adresse";
  static const String addressesEmpty = "Aucune adresse enregistrée";

  //* profile placeholders (until real user data is wired)
  static const String profileSampleName = "Marc Jean";
  static const String profileSampleAddress = "745 Lincoln Pl, New York";

  //* product detail
  static const String productFreeDelivery = "Livraison gratuite";
  static const String productPrepTime = "20-25 min";
  static const String productCalories = "162 Kcal";
  static const String productQuickChoices = "Essayez ces choix rapides";
  static const String productDescription = "Description";
  static const String productReadMore = "Plus...";
  static const String productOftenOrderedWith = "Souvent commandé avec";
  static const String productAddToCart = "Ajouter au panier";
  static const String productOrder = "Commander";
  static const String productDelivererRole = "Livreur";

  //* chat list
  static const String chatListTitle = "Liste des discussions";
  static const String chatSearchHint = "Rechercher des magasins populaires";
  static const String chatTypingSuffix = "est en train d'écrire...";

  //* chat list sample data
  static const String chatSample1Name = "Supermarché Frais Mart";
  static const String chatSample1Msg =
      "Bonjour, j'aimerais avoir des informations sur vos délais de livraison";
  static const String chatSample2Name = "Épicerie du quotidien";
  static const String chatSample2Msg =
      "Pourriez-vous me dire si les tomates sont disponibles ?";
  static const String chatSample3Name = "Épicerie Green Cart";
  static const String chatSample3Msg =
      "Bienvenue ! Comment puis-je vous aider ?";
  static const String chatSample4Name = "Support Duck go";
  static const String chatSample4Msg =
      "J'apprécierais de recevoir un remboursement pour ma dernière commande";
  static const String chatSample5Name = "Pharmacie Soins";
  static const String chatSample5Msg =
      "Veuillez fournir des informations sur l'ordonnance";
  static const String chatSample6Name = "ShopNest E-Commerce";

  //* order tracking
  static const String trackingPreparingTitle =
      "Votre commande est en cours de préparation";
  static const String trackingPreparingSubtitle =
      "Le chef met de la magie dans votre plat. Tenez bon !";
  static const String trackingArrivingPrefix = "Arrivée dans";
  static const String trackingMinutesSuffix = "minutes";
  static const String trackingArrivingSubtitle =
      "Asseyez-vous et détendez-vous, votre nourriture est en route.";
  // Leg-specific copy. Phase 1: driver is heading to the seller to
  // pick the food up. Phase 2: driver picked up the food and is on
  // the way to the buyer. Surfaces in the tracking bottom sheet so
  // the buyer knows which leg the map polyline represents.
  static const String trackingAwaitingPickupTitle =
      "Le livreur récupère ta commande";
  static const String trackingAwaitingPickupSubtitle =
      "Il est en route vers le vendeur — tu peux suivre son trajet sur la carte.";
  static const String trackingEnRouteTitle = "Ta commande est en chemin !";
  static const String trackingEnRouteSubtitle =
      "Le livreur a récupéré ta commande et arrive vers toi.";
  static const String trackingDeliveredTitle = "Votre commande est arrivée";
  static const String trackingDeliveredSubtitle =
      "Bon appétit ! Nous espérons que vous aimez.";
  static const String trackingStagePrepared = "Préparé";
  static const String trackingStageOnTheWay = "En route";
  static const String trackingStageDelivered = "Livré";
  /// The driver's experience line on the tracking card, from their real
  /// lifetime delivery count. A driver on their first job is named as new
  /// rather than shown a bare "0 livraisons".
  static String trackingDelivererMeta(int totalDeliveries) =>
      switch (totalDeliveries) {
        <= 0 => "Nouveau livreur",
        1 => "1 livraison",
        _ => "$totalDeliveries livraisons",
      };

  //* cart screen
  static const String cartTitle = "Panier";
  static const String cartEmptyTitle = "Votre panier est vide";
  static const String cartEmptySubtitle =
      "Parcourez le menu et ajoutez de savoureux choix à votre panier";
  static const String cartPromoHint = "Code promo";
  static const String cartApply = "Appliquer";
  static const String cartOrderSummary = "Résumé de la commande";
  static const String cartSubTotal = "Sous-total";
  static const String cartShipping = "Livraison";
  static const String cartTotal = "Total";
  static const String cartContinuePay = "Continuer le paiement";

  //* cart placeholder items
  static const String cartItem1Name = "Poitrine de poulet grillée";
  static const String cartItem1Desc =
      "Poitrine de poulet tendre et assaisonnée.";
  static const String cartItem2Name = "Taco Suprême Croquant";
  static const String cartItem2Desc =
      "Un Taco Suprême croquant et savoureux garni d'une garniture assaisonnée";
  static const String cartItem3Name = "Le Combo";
  static const String cartItem3Desc =
      "Régulier, Quesadilla au poulet grillé, Nacho & Fromage, Pepsi Zéro";
  static const String cartItem4Name = "Repas Gusco Griller";
  static const String cartItem4Desc =
      "Un savoureux repas Gusco Griller garni de poulet grillé juteux, de garnitures fraîches.";

  //* product detail sample data (placeholders)
  static const String productSampleName = "Poitrine de poulet grillée";
  static const String productSampleShortDesc =
      "Poitrine de poulet tendre et assaisonnée.";
  static const String productSampleLongDesc =
      "Poitrine de poulet de qualité supérieure marinée et grillée à la perfection. Chaque bouchée est savoureuse, maigre et incroyablement tendre. Idéal pour tous ceux qui aiment la nourriture réconfortante et saine";
  static const String productSampleDelivererName = "Alice Johnson";

  //* seller (product page)
  static const String productSampleSellerName = "La Cuisine d'Alice";
  // Neutral fallback when the real seller name is missing — never a mock name.
  static const String productSellerFallbackName = "Cuisinier";
  static const double productSampleSellerRating = 4.8;
  static const int productSampleSellerOrdersCompleted = 1284;
  static const String productSellerOrdersSuffix = "commandes terminées";

  //* reviews section
  static const String productReviewsTitle = "Avis";
  static const String productReviewsSeeAll = "Voir tout";
  static const String productReviewsBasedOn = "Basé sur";
  static const String productReviewsWordReviews = "avis";

  //* sample review data
  static const String productReview1Author = "Sophie M.";
  static const String productReview1Body =
      "Les saveurs étaient au rendez-vous et la portion était parfaite. Je commanderai à nouveau sans hésiter.";
  static const String productReview1Time = "Il y a 2 jours";

  static const String productReview2Author = "Marcus L.";
  static const String productReview2Body =
      "Arrivé chaud et frais. Le poulet était super tendre — exactement comme décrit.";
  static const String productReview2Time = "Il y a 5 jours";

  static const String productReview3Author = "Lina K.";
  static const String productReview3Body =
      "Excellent rapport qualité-prix. L'assaisonnement était un peu doux mais la viande était juteuse.";
  static const String productReview3Time = "Il y a 1 semaine";

  //* home — shared
  static const String clientHomeSearchHint = "Chercher un plat, un traiteur...";

  //* home — category tabs (compact pill labels)
  static const String homeCategoryAll = "Tout";
  static const String homeCategorySocialShort = "Fait Maison";
  static const String homeCategoryTraiteurShort = "Traiteurs";
  static const String homeCategoryRestaurantShort = "Restaurants";

  //* category — full official names (filter screens, headers)
  static const String homeCategorySocial = "Le Bon Fait Maison";
  static const String homeCategoryTraiteur = "L'Atelier Traiteur";
  static const String homeCategoryRestaurant = "Sauve Ton Plat";

  //* home — subcategory group titles
  static const String categoryGroupCuisine = "Type de cuisine";
  static const String categoryGroupDiet = "Régime alimentaire";
  static const String categoryGroupDish = "Type de plat";

  //* home — section titles
  static const String clientHomeSectionFoodNearYou = "Plats près de chez toi";
  static const String clientHomeSectionKitchensNearYou = "Autres suggestions";
  static const String clientHomeSectionSolidarity = "Partages solidaires";

  //* home — kitchen card labels
  static const String kitchenFreeDelivery = "Livraison gratuite";

  //* home — feed card labels (also used in map sheet)
  static const String feedExpireAt = "Expire à";
  static const String feedPortions = "portions";
  static const String feedPortion = "portion";
  static const String feedPortionsLeft = "portions restantes";
  static const String feedPortionLeft = "portion restante";
  static const String feedPriceFree = "Gratuit";

  //* home — dietary tag labels
  static const String dietaryHalal = "Halal";
  static const String dietaryVegan = "Végan";
  static const String dietaryGlutenFree = "Sans gluten";
  static const String dietaryKosher = "Casher";

  //* filters — sheet chrome
  static const String filterSheetTitle = "Filtres";
  static const String filterReset = "Réinitialiser";
  static const String filterApply = "Appliquer";
  static const String filterSeeResults = "Voir les résultats";
  static const String filterDistanceAll = "Tous";
  static const String filterDistanceUpTo = "Jusqu'à";
  static const String filterDistanceKmSuffix = "km";
  static const String filterDistanceMaxSuffix = "km max";

  //* filters — section labels
  static const String filterCategoryLabel = "Catégorie";
  static const String filterCuisineLabel = "Type de cuisine";
  static const String filterDietLabel = "Régime alimentaire";
  static const String filterDishLabel = "Type de plat";
  static const String filterDistanceLabel = "Distance";
  static const String filterAvailabilityLabel = "Disponibilité";
  static const String filterInStockOnly = "En stock uniquement";
  static const String filterAllergensLabel = "Allergènes";

  //* filters — cuisine types
  static const String cuisineOrientale = "Orientale";
  static const String cuisineFrancaise = "Française";
  static const String cuisineAfricaine = "Africaine";
  static const String cuisinePortugaise = "Portugaise";
  static const String cuisineItalienne = "Italienne";
  static const String cuisineEspagnole = "Espagnole";
  static const String cuisineLatine = "Latine";

  //* filters — dish types
  static const String dishStarter = "Entrée";
  static const String dishMain = "Plat";
  static const String dishDessert = "Desserts";
  static const String dishCocktail = "Cocktail dinatoire";
  static const String dishDrink = "Boisson";

  //* allergens (regulatory declaration on every listing)
  static const String allergenGluten = "Céréales contenant du gluten";
  static const String allergenCrustaceans = "Crustacés";
  static const String allergenEggs = "Œufs";
  static const String allergenFish = "Poissons";
  static const String allergenPeanuts = "Arachides";
  static const String allergenSoy = "Soja";
  static const String allergenMilk = "Lait";
  static const String allergenNuts = "Fruits à coque";
  static const String allergenCelery = "Céleri";
  static const String allergenMustard = "Moutarde";
  static const String allergenSesame = "Graines de sésame";
  static const String allergenSulfites = "Sulfites";
  static const String allergenLupin = "Lupin";
  static const String allergenMolluscs = "Mollusques";
  static const String allergenOther = "Autres";
  static const String allergenNone = "Aucun";

  //* map screen
  static const String mapLocationCurrent = "Paris 11ème";
  static const String mapCategoryUrgent = "Urgent";
  static const String mapRadiusLabel = "Rayon";
  static const String mapSheetDetailCta = "Voir le détail";
  static const String mapSheetOrderCta = "Commander";

  //* seller profile — hero + promo
  static const String sellerProfileFirstOrderPromo =
      "Première commande livrée gratuitement";
  static const String sellerProfilePrepTimePrefix = "Prêt dans";
  static const String sellerProfileDeliveryFeePrefix = "Livraison";
  static const String sellerProfileFreeLabel = "Gratuit";

  //* seller profile — trust stats
  static const String sellerTrustAverageRating = "Note\nmoyenne";
  static const String sellerTrustFastResponse = "Réponse\nrapide";
  static const String sellerTrustMealsSold = "Repas\nvendus";
  static const String sellerTrustMealsSaved = "Repas sauvés";

  //* seller profile — performance bars
  //* seller profile — ratings (Évaluations)
  static const String ratingsTitle = "Évaluations";
  static const String ratingHygiene = "Hygiène";
  static const String ratingFoodQuality = "Qualité du plat";
  static const String ratingPackaging = "Emballage";
  static const String ratingScoreSuffix = "/5";
  static const String ratingPercentSuffix = "%";
  static const String ratingVerifiedOrders = "commandes vérifiées";
  static const String ratingBasedOn = "Basé sur";
  static const String ratingReviews = "avis";

  //* seller profile — listings
  static const String sellerListingsTitle = "Disponible maintenant";
  static const String sellerListingsSubtitle =
      "Offres du jour à ne pas manquer";

  //* seller profile — bio
  static const String sellerBioTitlePrefix = "À propos de";
  static const String sellerBioSeeMore = "Voir plus";
  static const String sellerBioLanguagesLabel = "Langues parlées :";
  static const String sellerBioMemberSincePrefix = "Membre depuis :";
  static const String sellerBioLastActivePrefix = "Dernière connexion :";

  //* seller profile — verifications
  static const String sellerVerificationsTitle = "Vérifications";
  static const String sellerVerificationIdentity = "Identité vérifiée";
  static const String sellerVerificationHygieneCharter =
      "Charte d'hygiène signée";
  static const String sellerVerificationPhone = "Numéro de téléphone confirmé";
  static const String sellerVerificationAddress = "Adresse vérifiée";
  static const String sellerVerificationsSeeAll = "Voir les certifications";

  //* seller profile — reviews
  static const String sellerReviewsTitlePrefix = "Avis";
  static const String sellerReviewsWhatPeopleSay = "Ce que les clients disent";
  static const String sellerReviewsHelpfulSuffix =
      "personnes ont trouvé cet avis utile";
  static const String sellerReviewsSeeAllPrefix = "Voir tous les";
  static const String sellerReviewsSeeAllSuffix = "avis";

  //* seller profile — location
  static const String sellerLocationTitle = "Où retirer";
  static const String sellerLocationExactNote =
      "(adresse exacte après commande)";
  static const String sellerLocationDeliveryRadiusPrefix =
      "Zone de livraison :";
  static const String sellerLocationSchedulePrefix = "Disponible :";

  //* seller profile — bottom action bar
  static const String sellerActionMessage = "Message";
  static const String sellerActionOrder = "Commander";

  //* order — success / confirmation
  static const String successTitle = "Commande confirmée !";
  static const String successOrderNumberPrefix = "Commande";
  static const String successDeliveryEstimateLabel = "Livraison estimée";
  static const String successPickupEstimateLabel =
      "À récupérer au point de retrait";
  static const String successExpectedArrivalPrefix = "Arrivée prévue :";
  static const String successExpectedPickupPrefix = "Retrait prévu :";
  static const String successImpactMessage =
      "Tu viens de sauver un repas du gaspillage. Merci !";
  static const String successRecapTitle = "Récapitulatif";
  static const String successRecapServiceLabel = "Service";
  static const String successTotalPaidLabel = "Total payé";
  static const String successTrackOrderCta = "Suivre ma commande";
  static const String successBackHomeCta = "Retour à l'accueil";

  static String successStatusPreparing(String sellerName) =>
      "$sellerName prépare ta commande";

  static String successDeliveryWindow(int minMinutes, int maxMinutes) =>
      "entre $minMinutes et $maxMinutes min";

  //* payment — processing + error state
  static const String paymentProcessingTitle = "Paiement en cours...";
  static const String paymentProcessingSecurity = "Paiement sécurisé";
  static const String paymentErrorTitle = "Paiement échoué";
  static const String paymentErrorBody =
      "Ta carte a été refusée. Essaie une autre méthode.";
  static const String paymentErrorRetry = "Réessayer";
  static const String paymentErrorChooseMethod = "Choisir une autre méthode";

  //* payment — method selection
  static const String paymentTitle = "Paiement";
  static const String paymentTotalLabel = "Total à payer";
  static const String paymentMethodLabel = "Méthode de paiement";
  static const String paymentWalletLabel = "Mon portefeuille";
  static const String paymentWalletBalancePrefix = "Solde :";
  static const String paymentWalletAfterPrefix = "Après paiement :";
  static const String paymentWalletInsufficientPrefix = "Il manque";
  static const String paymentCardLabelPrefix = "Carte";
  static const String paymentCardExpiryPrefix = "Expire";
  static const String paymentApplePayLabel = "Apple Pay";
  static const String paymentApplePayHint = "Face ID / Touch ID";
  static const String paymentGooglePayLabel = "Google Pay";
  static const String paymentGooglePayHint = "Biométrie";
  static const String paymentPayPalLabel = "PayPal";
  static const String paymentAddCard = "Ajouter une nouvelle carte";
  static const String paymentSecureNote = "Paiement sécurisé via Stripe";
  static const String paymentTermsPrefix = "En confirmant, tu acceptes les";
  static const String paymentTermsLink = "Conditions générales d'utilisation";
  static const String paymentPayCtaPrefix = "Payer";

  //* CGU/CGV consent — required at dish publication + order purchase
  static const String termsAcceptCheckbox = "J'accepte les CGU/CGV";
  static const String termsReadLink = "Lire les CGU/CGV";
  static const String legalTermsTitle = "CGU / CGV";

  //* KYC validation — clean French messages replacing the raw
  //* "KYC_NOT_APPROVED" backend gate (Traiteur / Restaurant sellers).
  static const String kycPendingMessage =
      "Votre compte professionnel est en attente de validation KYC.";
  static const String kycRejectedMessage =
      "Votre validation KYC a été refusée. Veuillez vérifier vos documents.";

  //* checkout — order summary
  static const String checkoutTitle = "Récapitulatif";
  static const String checkoutOrderSection = "Ta commande";
  static const String checkoutDeliverySection = "Livraison";
  static const String checkoutPickupSection = "Retrait";
  static const String checkoutSellerSection = "Vendeur";
  static const String checkoutPriceSection = "Détail du prix";
  static const String checkoutEditCart = "Modifier le panier";
  static const String checkoutEdit = "Modifier";
  static const String checkoutDeliveryHomeMode = "Livraison à domicile";
  static const String checkoutPickupMode = "À récupérer";
  static const String checkoutPriceArticles = "Articles";
  static const String checkoutPriceDelivery = "Frais de livraison";
  static const String checkoutPriceService = "Frais de service";
  static const String checkoutPriceTotal = "Total";
  static const String checkoutImpactMessage =
      "En commandant ici, tu sauves un repas du gaspillage";
  static const String checkoutContinuePayment = "Continuer vers le paiement";
  static const String checkoutNoteForPrefix = "Note pour";

  static String checkoutDeliveryAsapEta(int minutes) =>
      "Dès que possible (~$minutes min)";

  //* delivery — address confirmation
  static const String addressTitle = "Adresse de livraison";
  static const String addressDeliverTo = "Livrer à";
  static const String addressAdd = "Ajouter une adresse";
  static const String addressAddFirst = "Ajouter ta première adresse";
  static const String addressNoSavedTitle = "Aucune adresse enregistrée";
  static const String addressTypeHome = "Domicile";
  static const String addressTypeWork = "Bureau";
  static const String addressTypeOther = "Autre";
  static const String addressInstructionsLabel = "Instructions pour le livreur";
  static const String addressInstructionsHint = "Ex: 3e étage, code 1234...";
  static const String addressWhenLabel = "Quand ?";
  static const String addressWhenAsap = "Dès que possible";
  static const String addressWhenLater = "Plus tard";
  static const String addressToday = "Aujourd'hui";
  static const String addressTomorrow = "Demain";
  static const String addressOutOfRange =
      "Cette adresse est hors de la zone de livraison. Essaie une autre adresse ou choisis la récupération.";
  static const String addressContinueCta = "Continuer";

  //* fulfillment — choice sheet
  static const String fulfillmentTitle =
      "Comment veux-tu recevoir ta commande ?";
  static const String fulfillmentDeliveryLabel = "Livraison";
  static const String fulfillmentDeliveryFeePrefix = "Frais :";
  static const String fulfillmentPickupLabel = "À récupérer";
  static const String fulfillmentPickupFree = "Gratuit";
  static const String fulfillmentNoAddress =
      "Ajoute une adresse pour la livraison";
  static const String fulfillmentContinueCta = "Continuer";

  static String fulfillmentDeliveryWindow(int minMinutes, int maxMinutes) =>
      "Entre $minMinutes et $maxMinutes min";

  //* cart — new French flow
  static const String cartTitleFr = "Mon panier";
  static const String cartSellerLabel = "Vendeur";
  static const String cartAddMoreItems = "Ajouter d'autres articles";
  static const String cartSubtotalLabel = "Sous-total";
  static const String cartContinueCta = "Continuer";
  static const String cartEmptyTitleFr = "Ton panier est vide";
  static const String cartEmptyCtaHomeFr = "Retour à l'accueil";
  static const String cartFloatingArticlesPlural = "articles";
  static const String cartFloatingArticleSingular = "article";
  static const String cartFloatingSeeCart = "Voir le panier";
  static const String cartFloatingTotalPrefix = "Total :";
  static const String cartUnavailableBody = "Cet article n'est plus disponible";
  static const String cartUnavailableRemove = "Retirer";
  static const String cartDifferentSellerTitle = "Changer de vendeur ?";
  static const String cartDifferentSellerConfirm = "Vider et recommencer";
  static const String cartDifferentSellerCancel = "Annuler";
  static const String cartReviewSuffix = "avis";
  static const String cartOrderSummaryTitle = "Récapitulatif";
  static const String cartShippingLabel = "Livraison";
  // Shown at the cart stage where delivery-vs-pickup (and its fee) isn't chosen
  // yet — the real breakdown appears on the summary screen after the choice.
  static const String cartFeesDeferredHint = "Calculés à l'étape suivante";
  static const String cartTotalLabel = "Total";
  // Flat delivery fee (3,50 €) — mirrors the backend DELIVERY_FEE_CENTS=350.
  static const double cartShippingFee = 3.50;
  // Platform buyer fee: 5% added on top of (subtotal + delivery). Mirrors the
  // backend PLATFORM_BUYER_FEE_BPS=500. Backend is the source of truth; this
  // matches its formula so the displayed total equals the Stripe charge.
  static const double platformFeeRate = 0.05;
  static const String cartPlatformFeeLabel = "Frais plateforme (5%)";

  static String cartDifferentSellerBody(String sellerName) =>
      "Tu as déjà un panier chez $sellerName. Veux-tu le vider et recommencer ?";

  //* seller — home dashboard
  static const String sellerHomeTodayLabel = "Aujourd'hui";
  static const String sellerHomeTodayRevenue = "Revenus";
  static const String sellerHomeTodayOrders = "Commandes";
  static const String sellerHomeTodayPortions = "Portions";
  static const String sellerHomeTodayImpact =
      "Vous avez sauvé 18 portions du gaspillage aujourd'hui";

  //* seller — order requests section
  static const String sellerOrderRequestsTitle = "Demandes de commande";
  static const String sellerOrderActionReject = "Refuser";
  static const String sellerOrderActionAccept = "Accepter";
  static const String sellerOrderSeeMore = "Voir plus";
  static const String sellerOrderNotePrefix = "note :";
  static const String sellerOrderPaymentStatusLabel = "Statut du paiement";
  static const String sellerOrderDeliverToLabel = "Livrer à";
  static const String sellerOrderEmptyMessage =
      "Vous n'avez encore aucune commande";

  //* seller — accepted orders / history screen
  static const String sellerOrdersTabToAccept = "À accepter";
  static const String sellerOrdersTabAccepted = "En cours";
  static const String sellerOrdersTabHistory = "Historique";
  static const String sellerOrdersFilterAll = "Tout";
  static const String sellerOrdersFilterReadyToPickup = "Prêt à récupérer";
  static const String sellerOrdersFilterPreparing = "En préparation";
  static const String sellerOrdersFilterCompleted = "Terminé";
  static const String sellerOrdersBadgeToAccept = "À accepter";
  static const String sellerOrdersBadgePickedUp = "Récupérée";
  static const String sellerOrdersBadgeInDelivery = "En livraison";
  static const String sellerOrdersBadgeCancelled = "Annulée";
  static const String sellerOrdersSortByLabel = "Trier par";
  static const String sellerOrdersSortAcceptedTime = "Heure d'acceptation";
  static const String sellerOrdersSortTotalPrice = "Prix total";
  static const String sellerOrdersMinutesSuffix = "min";
  static const String sellerOrdersEmptyMessage = "Aucune commande à afficher";

  //* seller — order details sheet
  static const String sellerOrderDetailsTitle = "Détails de la commande";
  static const String sellerOrderDetailsItemsLabel = "Articles";
  static const String sellerOrderDetailsFulfillmentLabel = "Mode";
  static const String sellerOrderDetailsFulfillmentDelivery = "Livraison";
  static const String sellerOrderDetailsFulfillmentPickup =
      "À récupérer sur place";
  static const String sellerOrderDetailsBuyerTotalLabel =
      "Total payé par le client";
  static const String sellerOrderDetailsEarningsLabel = "Vos revenus";
  static const String sellerOrderDetailsNoItems = "Aucun article";

  //* seller — add product sheet
  static const String addProductSheetTitle = "Ajouter un plat";
  static const String addProductSectionPhotos = "Photos";
  static const String addProductSectionBasic = "Infos de base";
  static const String addProductSectionClassification = "Classification";
  static const String addProductSectionAllergens = "Allergènes";
  static const String addProductSectionAvailability = "Disponibilité";
  static const String addProductSectionPickup = "Mode de récupération";
  static const String addProductPhotosHint =
      "Ajoutez 1 à 4 photos. La première est mise en avant dans le fil.";
  static const String addProductFieldTitle = "Titre du plat";
  static const String addProductFieldDescription = "Description";
  static const String addProductFieldPrice = "Prix";
  static const String addProductFieldPortions = "Portions disponibles";
  static const String addProductFieldPrepMinutes = "Temps de préparation (min)";
  static const String addProductPriceCapNote =
      "Plafond : €4,50 pour Le Bon Fait Maison. Libre pour Traiteur et Restaurant.";
  // Category-specific price notes (shown under the price field based on the
  // connected seller's category).
  static const String addProductPriceCapNoteFaitMaison =
      "Plafond : 4,50 € pour Le Bon Fait Maison.";
  static const String addProductPriceFreeNote =
      "Prix libre pour cette catégorie.";
  static const String addProductPriceCapError =
      "Le prix d'un plat fait-maison ne peut pas dépasser €4,50.";
  static const String addProductFieldCategory = "Catégorie";
  static const String addProductCategoryAutoNote =
      "Reprise depuis votre profil de cuisinier.";
  // Fallback when the seller's category can't be resolved from their profile.
  static const String addProductCategoryUnavailable = "Catégorie indisponible";
  static const String addProductFieldCuisine = "Type de cuisine";
  static const String addProductFieldDiets = "Régime alimentaire";
  static const String addProductFieldDishType = "Type de plat";
  static const String addProductAllergensRequiredHint =
      "Au moins une case doit être cochée.";
  static const String addProductAllergenOtherHint = "Précisez l'allergène";
  static const String addProductFieldPickupStart = "Heure de retrait";
  static const String addProductFieldPickupEnd = "Heure limite de retrait";
  static const String addProductPickupTimeNote =
      "L'heure limite ne peut pas dépasser minuit.";
  static const String addProductPickupOnSite = "À récupérer sur place";
  static const String addProductPickupOnSiteHint = "Gratuit";
  static const String addProductPickupDelivery = "Livraison";
  static const String addProductPickupDeliveryHint = "€2,50";
  static const String addProductSaveCta = "Publier le plat";
  static const String addProductPublishSuccess = "Plat publié avec succès.";
  static const String addProductUpdateSuccess = "Plat mis à jour avec succès.";
  static const String addProductEditCta = "Enregistrer";

  //* seller — product detail seller actions
  static const String sellerProductEditCta = "Modifier";
  static const String sellerProductDeleteCta = "Supprimer";
  static const String sellerProductDeleteConfirmTitle = "Supprimer ce plat ?";
  static const String sellerProductDeleteConfirmBody =
      "Le plat sera retiré de ta vitrine. Les commandes existantes restent intactes.";
  static const String sellerProductDeleteConfirmCancel = "Annuler";
  static const String sellerProductDeleteConfirmCta = "Supprimer";
  static const String sellerProductDeletedMessage = "Plat supprimé.";
  static const String sellerProductsLoadError =
      "Impossible de charger tes plats.";

  //* seller — products / catalog screen
  static const String sellerProductsAddCta = "Ajouter un plat";
  static const String sellerProductsTabAvailable = "Disponible";
  static const String sellerProductsTabNotAvailable = "Indisponible";
  static const String sellerProductsAvailableLabel = "Disponible";
  static const String sellerProductsNotAvailableLabel = "Indisponible";
  static const String sellerProductsPrepSuffix = "min";
  static const String sellerProductsEmptyMessage = "Aucun plat à afficher";

  //* delivery — driver dashboard (Drive sheet + nav bar)
  static const String deliveryDashboardDriveTab = "Conduire";
  static const String deliveryDashboardSettingsTab = "Paramètres";
  static const String deliveryDashboardNextPickupLabel = "Prochain ramassage";
  static const String deliveryDashboardNavigateCta = "Itinéraire";
  static const String deliveryDashboardTodayLabel = "Aujourd'hui";
  static const String deliveryDashboardOnlineLabel = "En ligne";
  static const String deliveryDashboardDeliveriesLabel = "Livraisons";

  //* delivery — issue report sheet
  static const String issueSheetTitle = "Signaler un problème";
  static const String issueSheetSectionAbort = "Annuler la livraison";
  static const String issueSheetSectionReport = "Signaler";
  static const String issueSheetOtherInputTitle = "Décrire le problème";
  static const String issueSheetOtherInputHint = "Expliquez ce qui s'est passé";
  static const String issueSheetContinueCta = "Continuer";
  static const String issueSheetConfirmTitle = "Êtes-vous sûr ?";
  static const String issueSheetConfirmAbortSubtitle =
      "Cette action annule la livraison.";
  static const String issueSheetConfirmReportSubtitle =
      "Le problème sera signalé.";
  static const String issueSheetCancelCta = "Annuler";
  static const String issueSheetConfirmCta = "Confirmer";
  static const String issueSheetReportedToast = "Problème signalé";
  static const String issueRestaurantClosed = "Restaurant fermé";
  static const String issueOrderUnavailable = "Commande non disponible";
  static const String issueOrderNotReady = "Commande pas prête";
  static const String issueMissingItem = "Article manquant";
  static const String issueCustomerUnreachable = "Client introuvable";
  static const String issueWrongAddress = "Mauvaise adresse";
  static const String issueCustomerRefused = "Client refuse la commande";
  static const String issueVehicleProblem = "Problème de véhicule";
  static const String issueOther = "Autre";

  //* delivery — QR handoff sheet
  static const String qrHandoffContinueCta = "Continuer";

  //* delivery — job lifecycle card
  static const String jobStageGoingToPickup = "Direction ramassage";
  static const String jobStageAtPickup = "Au point de ramassage";
  static const String jobStageGoingToDropoff = "Direction client";
  static const String jobStageAtDropoff = "Chez le client";
  static const String jobStageDelivered = "Livraison terminée";
  static const String jobStageFailed = "Livraison échouée";
  static const String jobCtaArrivedPickup = "Arrivé au ramassage";
  static const String jobCtaPickedUp = "Commande récupérée";
  static const String jobCtaArrivedDropoff = "Arrivé chez le client";
  static const String jobCtaConfirmDelivery = "Confirmer la livraison";
  static const String jobCtaFinish = "Terminé";
  static const String jobReportIssue = "Signaler un problème";
  static const String jobInstructionsLabel = "Instructions client";
  static const String jobOrderNumberPrefix = "Commande";

  //* delivery — incoming order modal
  static const String incomingOrderTitle = "Nouvelle commande";
  static const String incomingOrderPickupLabel = "Ramassage";
  static const String incomingOrderDropoffLabel = "Livraison";
  static const String incomingOrderDistanceSuffix = "km";
  static const String incomingOrderEtaSuffix = "min";
  static const String incomingOrderItemsSuffix = "articles";
  static const String incomingOrderItemSuffix = "article";
  static const String incomingOrderAcceptCta = "Accepter";
  static const String incomingOrderDeclineCta = "Refuser";
  // Shown on the offer when the driver hasn't completed Stripe payout setup:
  // the "Accepter" button is disabled and this CTA opens onboarding.
  static const String incomingOrderPayoutRequired =
      "Configurez vos paiements avant d'accepter des livraisons.";
  static const String incomingOrderConfigurePaymentsCta =
      "Configurer mes paiements";
  // Generic claim failure (e.g. another driver won the race, or a backend
  // guard other than payout). Never surfaces the raw backend error.
  static const String incomingOrderClaimFailed =
      "Impossible d'accepter cette livraison. Réessayez.";
  // Wallet — payout (Stripe Connect) setup prompt. Shown only when the driver
  // hasn't configured payouts; delivering/earning does NOT require it.
  static const String walletPayoutSetupTitle = "Recevoir mes paiements";
  static const String walletPayoutSetupBody =
      "Vous pouvez livrer maintenant. Configurez vos paiements uniquement "
      "lorsque vous souhaitez retirer vos gains.";
  // Pending variant (DEC-4): details submitted, Stripe still verifying.
  static const String walletPayoutPendingTitle = "Vérification en cours";
  static const String walletPayoutPendingBody =
      "Vos informations ont été transmises à Stripe. Vous pourrez retirer "
      "vos gains dès que la vérification sera terminée.";
  static const String walletPayoutPendingCta = "Vérifier le statut";
  // QR scanner (driver) — shared manual-entry fallback.
  static const String commonCancel = "Annuler";
  static const String commonValidate = "Valider";
  static const String qrScanManualCta = "Saisir le code manuellement";
  static const String qrScanManualTitle = "Code";
  static const String qrScanManualHint = "Collez ou saisissez le code";
  // Seller pickup proof QR — seller shows, driver scans.
  static const String sellerPickupQrCta = "QR de retrait livreur";
  static const String pickupQrSheetTitle = "QR de retrait";
  static const String pickupQrSheetInstruction =
      "Montrez ce code au livreur pour confirmer la remise de la commande.";
  static const String pickupQrSheetClose = "Fermer";
  // Manual fallback: the raw proof code shown under the QR so the handoff still
  // works when the camera can't read the image.
  static const String qrTokenFallbackLabel =
      "QR illisible ? Communiquez ce code au livreur :";
  static const String pickupScanTitle = "Scanner le QR vendeur";
  static const String pickupScanInstruction =
      "Scannez le QR affiché par le vendeur pour confirmer le retrait.";
  static const String pickupConfirmedMessage =
      "Retrait confirmé — en livraison";
  static const String pickupQrUnavailable =
      "QR de retrait indisponible pour le moment.";
  // Buyer delivery (reception) proof QR — buyer shows, driver scans.
  static const String buyerDeliveryQrCta = "QR de réception";
  static const String deliveryQrSheetTitle = "QR de réception";
  static const String deliveryQrSheetInstruction =
      "Montrez ce QR code au livreur pour confirmer la réception.";
  static const String deliveryQrSheetClose = "Fermer";
  static const String deliveryScanTitle = "Scanner le QR client";
  static const String deliveryScanInstruction =
      "Scannez le QR affiché par le client pour confirmer la livraison.";
  static const String deliveryConfirmedMessage = "Livraison confirmée";
  static const String deliveryQrUnavailable =
      "QR de réception indisponible pour le moment.";
  static const String deliveryDemoJobUnavailable =
      "Job de démonstration — aucune livraison réelle à confirmer.";
  // Client-absent dropoff (driver) — photo + GPS proof.
  static const String absentDropoffCta = "Client absent";
  static const String absentDropoffTitle = "Client absent";
  static const String absentDropoffIntro =
      "Le client est absent ? Déposez la commande à l'adresse avec une preuve "
      "photo et la position GPS.";
  static const String absentDropoffTakePhoto = "Prendre une photo";
  static const String absentDropoffRetakePhoto = "Reprendre la photo";
  static const String absentDropoffNoteHint = "Note (optionnel)";
  static const String absentDropoffSubmit = "Confirmer le dépôt";
  static const String absentDropoffGpsCapturing =
      "Récupération de la position GPS…";
  static const String absentDropoffGpsReady = "Position GPS enregistrée";
  static const String absentDropoffGpsMissing =
      "Position GPS indisponible. Activez la localisation et réessayez.";
  static const String absentDropoffPhotoRequired = "Photo obligatoire.";
  static const String absentDropoffSuccess =
      "Livraison confirmée (client absent).";
  static const String absentDropoffUploadFailed =
      "Échec de l'envoi de la photo.";
  // No driver available — buyer decision (switch to pickup / cancel+refund).
  static const String noDriverTitle = "Aucun livreur disponible";
  static const String noDriverText =
      "Vous pouvez récupérer votre commande en ramassage, ou annuler et être remboursé.";
  static const String noDriverSwitchPickup = "Passer en ramassage";
  static const String noDriverCancelRefund = "Annuler et rembourser";
  static const String noDriverSwitchedMessage =
      "Votre commande est passée en ramassage.";
  static const String noDriverCancelledMessage =
      "Votre commande a été annulée et remboursée.";
  static const String noDriverDecisionFailed =
      "Action impossible pour le moment.";
  static const String sellerNoDriverWaiting =
      "Aucun livreur disponible — en attente de décision client";
  // Seller-unavailable-at-pickup report (driver).
  static const String sellerUnavailableCta =
      "Vendeur absent / plat indisponible";
  static const String sellerUnavailableTitle = "Vendeur indisponible";
  static const String sellerUnavailableIntro =
      "Le vendeur est absent ou le plat n'est pas disponible ? Signalez-le avec "
      "votre position — vous serez indemnisé pour le déplacement.";
  static const String sellerUnavailableReasonLabel = "Motif";
  static const String sellerUnavailableReasonAbsent = "Vendeur absent";
  static const String sellerUnavailableReasonNoFood = "Plat non disponible";
  static const String sellerUnavailableSubmit = "Envoyer le signalement";
  static const String sellerUnavailableSuccess =
      "Signalement envoyé. Vous serez indemnisé pour le déplacement.";
  // Order-cancelled states surfaced to buyer/seller.
  static const String orderCancelledRefunded =
      "Commande annulée et remboursée.";
  static const String buyerSellerUnavailableCancelled =
      "Commande annulée et remboursée : vendeur indisponible.";
  static const String sellerOrderCancelledNoFood =
      "Commande annulée : plat non disponible au retrait.";
  static const String sellerOrderCancelledGeneric =
      "Commande annulée : consultez les détails de la commande.";
  // No driver ever accepted the delivery → the order was cancelled + refunded.
  static const String sellerOrderCancelledNoDriver =
      "Commande annulée : aucun livreur n'a pris la course.";
  // Driver disappeared after pickup.
  static const String buyerDriverDisappearedRefunded =
      "Commande remboursée : livraison non effectuée.";
  static const String sellerDriverIncidentMaintained =
      "Incident livreur : paiement maintenu.";
  // Seller proactive cancellation — "Je ne peux pas fournir".
  static const String sellerCannotProvideCta = "Je ne peux pas fournir";
  static const String sellerCannotProvideTitle = "Je ne peux pas fournir";
  static const String sellerCannotProvideConfirm =
      "La commande sera annulée et le client remboursé. Un strike sera ajouté à votre compte.";
  static const String sellerCannotProvideNoteHint = "Note (optionnel)";
  static const String sellerCannotProvideConfirmCta = "Confirmer l'annulation";
  static const String sellerCannotProvideSuccess =
      "Commande annulée. Le client a été remboursé.";
  static const String sellerCannotProvideBanner =
      "Commande annulée : vous ne pouviez pas la fournir.";
  static const String buyerSellerCannotProvideCancelled =
      "Commande annulée et remboursée : le vendeur ne peut pas fournir le plat.";
  // Buyer post-delivery dispute / refund request.
  static const String disputeCta = "Signaler un problème";
  static const String disputeTitle = "Signaler un problème";
  static const String disputeIntro =
      "Choisissez le motif. Selon le cas, vous serez remboursé(e) automatiquement "
      "ou votre demande sera examinée par notre équipe.";
  static const String disputeReasonLabel = "Motif";
  static const String disputeReasonNeverReceived = "Commande jamais reçue";
  static const String disputeReasonWrongOrder = "Commande totalement erronée";
  static const String disputeReasonSpoiled = "Plat avarié";
  static const String disputeReasonPoisoning = "Intoxication alimentaire";
  static const String disputeReasonSubjective =
      "Insatisfaction (goût, portion…)";
  static const String disputeDescriptionHint =
      "Décrivez le problème (optionnel)";
  static const String disputeAddPhoto = "Ajouter une photo";
  static const String disputeAddProof =
      "Ajouter une preuve (certificat médical…)";
  static const String disputeProofRequiredPoisoning =
      "Une preuve est requise pour un signalement d'intoxication.";
  static const String disputeSubmit = "Envoyer le signalement";
  static const String disputeSubjectiveNotice =
      "Ce motif ne donne pas lieu à un remboursement. Vous pouvez laisser un avis.";
  static const String disputeSubmitFailed = "Envoi impossible pour le moment.";
  static const String disputePhotoFailed = "Échec de l'envoi de la photo.";
  static const String disputeReasonAllergen =
      "Allergène non déclaré / info incorrecte";
  static const String disputeAllergenWarning =
      "Ce signalement sera examiné par l'équipe. En cas de risque médical, "
      "contactez immédiatement un professionnel de santé.";
  static const String disputeDescriptionRequired =
      "Une description est requise pour ce signalement.";
  // Allergen acknowledgment shown before checkout / on the dish detail.
  static const String allergenCheckNotice =
      "Vérifiez les allergènes avant de commander. En cas de doute, contactez le vendeur.";
  // Client-absent proof (buyer/seller order detail).
  static const String absentProofCardTitle = "Commande déposée";
  static const String absentProofCardText =
      "Commande déposée à votre adresse avec preuve photo.";
  static const String absentProofDeliveredAtLabel = "Livrée le";
  // Chat CTAs shared by the delivery + seller order surfaces.
  static const String chatContactClientCta = "Contacter le client";
  static const String chatContactSellerCta = "Contacter le vendeur";
  static const String chatContactDriverCta = "Contacter le livreur";

  /// Shown when a driver chat is opened before any driver has claimed the
  /// order. The CTA is gated on `driverAssigned`, so this is the race fallback
  /// (the driver can unclaim, or the list can be a moment stale).
  static const String chatNoDriverAssignedYet =
      "Aucun livreur n'a encore pris en charge cette commande.";

  //* signup flow — shell + chrome
  static const String signupExitDialogTitle = "Quitter l'inscription ?";
  static const String signupExitDialogBody =
      "Tes informations seront perdues. Tu pourras recommencer plus tard.";
  static const String signupExitCancel = "Annuler";
  static const String signupExitConfirm = "Quitter";
  static const String signupContinueCta = "Continuer";
  static const String signupFinishCta = "Terminer";
  static const String signupSkipCta = "Passer";

  //* signup flow — basic info page
  static const String signupBasicInfoTitle = "Créons ton compte";
  static const String signupBasicInfoSubtitle =
      "On a besoin de quelques infos pour commencer.";
  static const String signupFirstNameLabel = "Prénom";
  static const String signupFirstNameHint = "Ex. Camille";
  static const String signupLastNameLabel = "Nom";
  static const String signupLastNameHint = "Ex. Dupont";
  static const String signupEmailLabel = "Email";
  static const String signupEmailHint = "tu@exemple.com";
  static const String signupEmailError = "Email invalide";
  //* signup flow — confirm-your-name step (NoProfile / OAuth path)
  static const String signupCompleteNameTitle = "Comment t'appelles-tu ?";
  static const String signupCompleteNameSubtitle =
      "On a besoin de ton nom pour personnaliser ton compte.";

  static const String signupPhoneLabel = "Numéro de téléphone";
  static const String signupPhoneLabelOptional =
      "Numéro de téléphone (optionnel)";
  static const String signupPhoneHint = "6 12 34 56 78";
  static const String signupPhoneHelper = "+33 — 9 chiffres après le préfixe";
  static const String signupPhoneError = "Format invalide";
  static const String signupPasswordLabel = "Mot de passe";
  static const String signupPasswordHint =
      "8+ caractères, 1 majuscule, 1 chiffre";
  static const String signupPasswordError = "Mot de passe trop faible";
  static const String signupConfirmPasswordLabel = "Confirme le mot de passe";
  static const String signupConfirmPasswordError =
      "Les mots de passe ne correspondent pas";
  static const String signupPasswordStrengthWeak = "Faible";
  static const String signupPasswordStrengthMedium = "Moyen";
  static const String signupPasswordStrengthGood = "Bon";
  static const String signupPasswordStrengthExcellent = "Excellent";

  //* signup flow — phone verification page
  static const String signupOtpTitle = "Vérifie ton numéro";
  static const String signupOtpDefaultPhone = "ton numéro";
  static const String signupOtpVerifying = "Vérification…";
  static const String signupOtpResendNow = "Renvoyer le code";
  static const String signupOtpEditNumber = "Modifier le numéro";
  // Shown when the phone is already linked to another account: the OTP is
  // blocked, so we invite the user to change the number instead of resending.
  static const String signupOtpChangeNumber = "Changer de numéro";
  static const String signupOtpPhoneAlreadyUsed =
      "Ce numéro de téléphone est déjà utilisé.";
  static const String signupOtpResentTitle = "Code renvoyé";
  static const String signupOtpResentBody =
      "On t'a renvoyé un nouveau code par SMS.";
  static const String signupOtpDemoHint = "Mode démo : utilise le code 123456.";
  static const String signupOtpInvalid = "Code invalide. Réessaie.";
  static String signupOtpSubtitle(String phone) =>
      "On t'envoie un code à 6 chiffres au $phone.";
  static String signupOtpResendIn(int seconds) => "Renvoyer dans ${seconds}s";

  //* Phone-entry phase — shown when the wizard reaches this step without a
  //  number yet (e.g. the Google sign-in path, which skips basic info).
  static const String signupOtpEnterPhoneTitle = "Ton numéro de téléphone";
  static const String signupOtpEnterPhoneSubtitle =
      "On t'envoie un code à 6 chiffres par SMS pour vérifier ton numéro.";
  static const String signupOtpSendCode = "Envoyer le code";

  //* signup flow — email-OTP bypass variant (see FeatureFlags.useEmailOtpBypass).
  //  Same step, different channel; copy can be removed when SMS is back.
  static const String signupOtpEmailTitle = "Vérifie ton compte";
  static const String signupOtpEmailDefaultDestination = "ton adresse";
  static const String signupOtpEmailResentBody =
      "On t'a renvoyé un nouveau code par email.";
  static const String signupOtpEmailEditAddress = "Modifier l'adresse";
  static String signupOtpEmailSubtitle(String email) =>
      "On t'envoie un code à 6 chiffres à $email.";

  //* signup flow — biometric setup page
  static const String signupBiometricTitle = "Active la connexion rapide";
  static const String signupBiometricSubtitle =
      "Connecte-toi avec FaceID ou ton empreinte digitale.";
  static const String signupBiometricCta = "Activer la connexion biométrique";
  static const String signupBiometricFooter =
      "Tu pourras toujours te connecter avec ton mot de passe.";
  static const String signupBiometricEnabledToast =
      "Connexion biométrique activée";

  //* biometric login (OS-level via local_auth — NOT camera face matching)
  static const String biometricLoginCta = "Connexion biométrique";
  static const String biometricLoginTitle = "Connexion biométrique";
  static const String biometricLoginReason =
      "Authentifiez-vous pour accéder à votre compte IncaCook.";
  static const String biometricSetupReason =
      "Confirmez votre identité pour activer la connexion biométrique.";
  static const String biometricFailed =
      "Authentification biométrique annulée ou échouée.";
  static const String biometricSessionExpired =
      "Votre session a expiré. Veuillez vous reconnecter.";
  static const String biometricUnavailable =
      "La biométrie n'est pas disponible sur cet appareil.";
  static const String biometricLaterCta = "Plus tard";
  static const String biometricContinueCta = "Continuer";

  //* signup flow — legal acceptance page
  static const String signupLegalTitle = "Conditions d'utilisation";
  static const String signupLegalSubtitle =
      "Lis et accepte avant de continuer.";
  static const String signupLegalAcceptCgu = "J'ai lu et j'accepte les CGU";
  static const String signupLegalAcceptCgv = "J'ai lu et j'accepte les CGV";
  static const String signupLegalFooter =
      "Tu pourras consulter ces documents à tout moment dans tes paramètres.";

  //* signup flow — role selection page
  static const String signupRoleTitle = "Comment veux-tu utiliser IncaCook ?";
  static const String signupRoleSubtitle =
      "Tu pourras changer ce choix plus tard.";
  static const String signupRoleBuyerTitle = "Acheter des plats";
  static const String signupRoleBuyerSubtitle =
      "Découvre les plats près de chez toi";
  static const String signupRoleSellerTitle = "Vendre mes plats";
  static const String signupRoleSellerSubtitle =
      "Partage ta cuisine et fais des économies";
  static const String signupRoleDriverTitle = "Livrer des commandes";
  static const String signupRoleDriverSubtitle = "Gagne de l'argent en livrant";

  //* signup flow — seller subtype page
  static const String signupSubtypeTitle = "Quel type de cuisinier es-tu ?";
  static const String signupSubtypeSubtitle =
      "Cela détermine les règles qui s'appliquent à toi.";
  static const String signupSubtypeFaitMaisonTitle = "Le Bon Fait Maison";
  static const String signupSubtypeFaitMaisonSubtitle =
      "Particulier qui cuisine à la maison";
  static const String signupSubtypeFaitMaisonNote = "Prix max 4,50 €";
  static const String signupSubtypeTraiteurTitle = "L'Atelier Traiteur";
  static const String signupSubtypeTraiteurSubtitle =
      "Traiteur professionnel";
  static const String signupSubtypeRestaurantTitle = "Sauve Ton Plat";
  static const String signupSubtypeRestaurantSubtitle =
      "Restaurant qui vend ses surplus";

  //* signup flow — buyer pages
  static const String signupBuyerAddressTitle = "Où veux-tu être livré ?";
  static const String signupBuyerAddressSubtitle =
      "Tu pourras ajouter d'autres adresses plus tard.";
  static const String signupBuyerAddressDetailsToggle =
      "Détails supplémentaires";
  static const String signupBuyerApartmentLabel = "Appartement";
  static const String signupBuyerApartmentHint = "Ex. 4B";
  static const String signupBuyerFloorLabel = "Étage";
  static const String signupBuyerFloorHint = "Ex. 3";
  static const String signupBuyerDigicodeLabel = "Digicode";
  static const String signupBuyerDigicodeHint = "Ex. 1234A";
  static const String signupBuyerInstructionsLabel =
      "Instructions de livraison";
  static const String signupBuyerInstructionsHint =
      "Sonnez deux fois, laisser au gardien…";
  static const String signupBuyerDietaryTitle = "Tes préférences alimentaires";
  static const String signupBuyerDietarySubtitle =
      "On adaptera ton fil pour toi.";
  static const String signupBuyerDietaryDietSection = "Régime alimentaire";
  static const String signupBuyerDietaryAllergiesSection = "Allergies";
  static const String signupBuyerDietaryAllergiesHint =
      "Si tu es allergique, on te préviendra des plats à éviter.";
  static const String signupBuyerDoneSubtitle = "Ton compte est prêt.";
  static const String signupBuyerDoneImpact =
      "Tu vas pouvoir découvrir des plats faits maison près de chez toi et contribuer à réduire le gaspillage alimentaire 🌱";
  static const String signupBuyerDoneCta = "Découvrir les plats";
  static String signupBuyerDoneTitle(String firstName) {
    final suffix = firstName.isEmpty ? '' : ', $firstName';
    return "Bienvenue dans IncaCook$suffix";
  }

  //* signup flow — seller pages
  static const String signupSellerProfileTitle = "Crée ton profil";
  static const String signupSellerProfileSubtitle =
      "C'est ce que verront tes clients.";
  static const String signupSellerDisplayNameLabel = "Nom affiché";
  static const String signupSellerDisplayNameLabelPro =
      "Nom commercial affiché";
  static const String signupSellerDisplayNameHint = "Ex. La cuisine de Léa";
  static const String signupSellerDisplayNameHintPro = "Ex. Le Comptoir de Léa";
  static const String signupSellerBioLabel = "Bio";
  static const String signupSellerBioHint = "Présente-toi en quelques mots…";
  static String signupSellerBioCounter(int used) => "$used / 200 caractères";

  static const String signupSellerDobAddressTitle =
      "Quelques infos personnelles";
  static const String signupSellerDobAddressSubtitle =
      "Ces infos restent privées.";
  static const String signupSellerDobLabel = "Date de naissance";
  static const String signupSellerDobPlaceholder =
      "Sélectionne ta date de naissance";
  static const String signupSellerDobAdultRequired = "18+ requis";
  static const String signupSellerDobHelp = "Ta date de naissance";
  static const String signupSellerPickupLabel = "Adresse de retrait";
  static const String signupSellerPickupHint = "Cherche ton adresse de retrait";
  static const String signupSellerPickupHelper =
      "C'est l'adresse où les clients viennent chercher ou où le livreur récupère.";

  static const String signupSellerBusinessTitle = "Infos professionnelles";
  static const String signupSellerBusinessSubtitle =
      "Pour vérifier que tu es bien enregistré.";
  static const String signupSellerBusinessNameLabel = "Nom de l'entreprise";
  static const String signupSellerBusinessNameHint = "Ex. Atelier des Saveurs";
  static const String signupSellerSiretLabel = "SIRET";
  static const String signupSellerSiretHint = "000 000 000 00000";
  static const String signupSellerSiretError =
      "SIRET invalide (14 chiffres + Luhn)";
  // Shown ONLY at submit, and ONLY for Sauve Ton Panier (restaurant), when the
  // SIRET is empty. Traiteur / fait-maison never see a "SIRET requis" message.
  static const String signupSellerSiretRequiredSubmit =
      "Veuillez renseigner votre SIRET pour continuer.";
  static const String signupSellerFacadeLabel = "Photo de la façade";
  static const String signupSellerHoursLabel = "Horaires d'ouverture";
  static const String signupSellerHoursClosed = "Fermé";

  static const String signupSellerCuisineTitle = "Quelle cuisine fais-tu ?";
  static const String signupSellerCuisineSubtitle =
      "Sélectionne tout ce qui s'applique.";
  static const String signupSellerCuisineSection = "Type de cuisine";
  static const String signupSellerCourseSection = "Type de plat";

  static const String signupKycIdTitle = "Vérifions ton identité";
  static const String signupKycIdSubtitle =
      "Carte d'identité, passeport ou titre de séjour.";
  static const String signupKycIdDocTypeLabel = "Type de document";
  static const String signupKycIdRecto = "Recto";
  static const String signupKycIdVerso = "Verso";
  static const String signupKycIdTip =
      "Photo claire, pas de flash, document à plat.";

  static const String signupKycSelfieTitle = "Selfie de vérification";
  static const String signupKycSelfieSubtitle =
      "On compare avec ta pièce d'identité.";
  static const String signupKycSelfieCta = "Prendre un selfie maintenant";
  static const String signupKycSelfieRetakeCta = "Refaire le selfie";
  static const String signupKycSelfieFooter =
      "Capture en direct uniquement — pas de galerie.";

  static const String signupSellerCharterTitle = "Charte d'hygiène";
  static const String signupSellerCharterSubtitle =
      "Engage-toi à respecter les règles d'hygiène.";
  static const String signupSellerCommitmentFaitMaison =
      "Je m'engage à cuisiner des plats faits maison uniquement.";
  static const String signupSellerCommitmentHygiene =
      "Je m'engage à respecter les règles d'hygiène.";
  static const String signupCharterScrollHint =
      "Lis jusqu'au bas pour continuer";

  //* signup flow — driver pages
  static const String signupDriverVehicleTitle = "Quel véhicule utilises-tu ?";
  static const String signupDriverVehicleSubtitle =
      "Tu pourras en ajouter d'autres plus tard.";
  static const String signupDriverVehicleBicycleTitle = "Vélo";
  static const String signupDriverVehicleBicycleSubtitle =
      "Pas de permis requis — démarrage rapide";
  static const String signupDriverVehicleScooterTitle = "Scooter ou moto";
  static const String signupDriverVehicleScooterSubtitle =
      "Permis et assurance requis";
  static const String signupDriverVehicleCarTitle = "Voiture";
  static const String signupDriverVehicleCarSubtitle =
      "Permis et assurance requis";

  static const String signupDriverDocsTitle = "Documents véhicule";
  static const String signupDriverDocsSubtitle =
      "Permis, carte grise et assurance.";
  static const String signupDriverLicenseLabel = "Permis de conduire";
  static const String signupDriverLicenseHelper = "Recto-verso, lisible.";
  static const String signupDriverCarteGriseLabel = "Carte grise";
  static const String signupDriverCarteGriseHelper =
      "Au nom du conducteur ou avec autorisation.";
  static const String signupDriverDocsSecurityNote =
      "Tes documents sont chiffrés et confidentiels.";

  static const String signupDriverZoneTitle = "Dans quelles zones livres-tu ?";
  static const String signupDriverZoneSubtitle =
      "Tu peux choisir plusieurs villes ou quartiers.";
  static const String signupDriverZoneSearchHint =
      "Cherche une ville ou un quartier";
  static const String signupDriverZoneEmpty = "Sélectionne au moins une zone";
  static String signupDriverZoneCount(int count) =>
      "$count zone(s) sélectionnée(s)";
  static const String signupDriverZoneLoadError =
      "Impossible de charger les zones. Vérifie ta connexion.";
  static const String signupDriverZoneRetry = "Réessayer";
  static const String signupDriverZoneNoResults = "Aucune zone trouvée";

  // Payout setup banner — shown on seller / driver home until Stripe Connect
  // onboarding is complete. Replaces the deleted IBAN signup step.
  static const String payoutSetupBannerTitle = "Configure les paiements";
  static const String payoutSetupBannerSubtitle =
      "2 minutes pour recevoir tes gains sur ton compte bancaire.";
  static const String payoutSetupBannerCta = "Commencer";
  // Pending variant (DEC-4): details submitted, Stripe still verifying (or
  // payouts revoked) — no point re-showing the initial setup CTA.
  static const String payoutSetupBannerPendingTitle = "Vérification en cours";
  static const String payoutSetupBannerPendingSubtitle =
      "Stripe examine tes informations. Tes virements seront activés dès "
      "qu'elles seront validées.";
  static const String payoutSetupBannerPendingCta = "Vérifier";
  // Error variant (D6): the last status check itself failed (offline,
  // transport stall) — distinct from "not done yet" so the user isn't left
  // guessing why the prompt hasn't gone away.
  static const String payoutSetupBannerErrorTitle = "Vérification impossible";
  static const String payoutSetupBannerErrorSubtitle =
      "Nous n'avons pas pu vérifier ton statut de paiement. Vérifie ta "
      "connexion et réessaie.";
  static const String payoutSetupBannerErrorCta = "Réessayer";
  static const String payoutOnboardingScreenTitle = "Configurer les paiements";
  static const String payoutStatusActive = "Paiements actifs";
  static const String payoutStatusPending = "Configuration en cours";
  static const String payoutStatusFailed =
      "Configuration interrompue — réessaie";
  static const String payoutSettingsMenuItem = "Paiements";
  // Delivery settings row title while Stripe verifies submitted details —
  // replaces the "Configurer mes paiements" entry (DEC-4).
  static const String payoutPendingMenuItem = "Vérification des paiements";
  static const String payoutGatingSnackbarSeller =
      "Tes annonces sont en ligne mais les paiements sont en attente.";
  static const String payoutGatingSnackbarDriver =
      "Tu peux accepter des courses, mais les paiements sont en attente.";

  //* seller subscription paywall (RevenueCat) — post-login, not a signup step
  static const String signupSubscriptionTitle = "Choisissez votre abonnement";
  static const String signupSubscriptionSubtitle =
      "Activez votre abonnement mensuel pour publier vos plats, recevoir des "
      "commandes et accéder aux outils vendeur IncaCook.";
  static const String signupSubscriptionTrialNote =
      "2 mois gratuits sont offerts pour toute nouvelle inscription.";
  static const String signupSubscriptionSecureNote =
      "Paiement sécurisé via l'App Store ou Google Play. IncaCook ne stocke "
      "jamais vos informations de paiement.";
  static const String signupSubscriptionSubscribeCta = "S'abonner maintenant";
  static const String signupSubscriptionRestoreCta = "Restaurer mon abonnement";
  static const String signupSubscriptionPlanStandard = "Standard";
  static const String signupSubscriptionPlanPremium = "Premium";
  static const String signupSubscriptionStandardCommission = "Commission 30%";
  static const String signupSubscriptionPremiumCommission =
      "Commission réduite à 25%";
  static const String signupSubscriptionPremiumPerkFeatured =
      "3 mises à la une offertes / mois";
  static const String signupSubscriptionPremiumPerkCommission =
      "1 commission offerte / mois";
  static const String signupSubscriptionSelectPlanError =
      "Veuillez choisir une formule.";
  static const String signupSubscriptionSuccess = "Abonnement activé !";
  static const String signupSubscriptionRestoreNone =
      "Aucun abonnement actif trouvé pour ce compte.";
  static const String signupSubscriptionError =
      "Abonnement impossible. Veuillez réessayer.";
  static const String signupSubscriptionUnavailable =
      "Abonnement indisponible. Vérifiez la configuration RevenueCat.";
  // Precise paywall errors (TestFlight debugging) — one per failure cause.
  static const String subscriptionErrorKeyMissing =
      "Configuration RevenueCat manquante.";
  static const String subscriptionErrorOfferingMissing =
      "Offre d'abonnement introuvable.";
  static const String subscriptionErrorPackagesEmpty =
      "Produits d'abonnement indisponibles.";
  static const String subscriptionErrorStore =
      "Produits non encore disponibles dans l'environnement Apple Sandbox.";
  static const String signupSubscriptionPerMonth = "/ mois";

  //* seller paywall (shown post-login when subscription is inactive)
  static const String paywallTitle = "Abonnement requis";
  static const String paywallSubtitle =
      "Pour vendre sur IncaCook, un abonnement mensuel actif est requis.";

  static const String signupDriverCharterTitle = "Charte du livreur";
  static const String signupDriverCharterSubtitle =
      "Engage-toi à suivre les règles de qualité.";
  static const String signupDriverCommitmentPunctuality =
      "Je m'engage à respecter les délais de livraison.";
  static const String signupDriverCommitmentCare =
      "Je manipule les produits avec soin.";

  //* signup flow — image picker sheet
  static const String signupImagePickerCamera = "Prendre une photo";
  static const String signupImagePickerGallery = "Choisir depuis la galerie";
  static const String signupImagePickerRemove = "Supprimer";
  // Shown when a picked image is still too large after compression/resize.
  static const String imagePickerTooLarge =
      "Image trop volumineuse. Veuillez choisir une image plus légère.";
  static const String imagePickerUnsupported =
      "Format d'image non pris en charge. Veuillez choisir une photo JPEG, PNG ou WebP.";

  //* signup flow — address picker
  static const String signupAddressSearchHint = "Cherche une adresse…";
  static const String signupAddressConfirmed = "Adresse confirmée";
  static const String signupAddressUseCurrentLocation =
      "Utiliser ma position actuelle";
  static const String signupAddressLocating = "Localisation…";
  static const String signupAddressLocationDenied =
      "Active la localisation pour utiliser ta position.";
  static const String signupAddressLocationError =
      "Impossible de récupérer ta position. Réessaie.";
  static const String signupAddressSearchError = "Recherche indisponible.";

  //* signup flow — long charter / legal text
  static const String signupCguText = '''
Conditions Générales d'Utilisation — IncaCook

1. Objet
Les présentes conditions régissent l'utilisation de la plateforme IncaCook, un service de mise en relation entre cuisiniers, livreurs et acheteurs de plats faits maison.

2. Inscription
L'utilisateur s'engage à fournir des informations exactes lors de son inscription. IncaCook se réserve le droit de suspendre tout compte ne respectant pas les présentes conditions.

3. Utilisation
La plateforme est destinée à un usage personnel. Toute utilisation commerciale non autorisée est strictement interdite.

4. Responsabilité
IncaCook agit en tant qu'intermédiaire technique. Les vendeurs sont responsables de la qualité et de la conformité de leurs produits.

5. Données personnelles
Les données collectées sont traitées conformément à notre politique de confidentialité et au RGPD.

6. Modification
IncaCook se réserve le droit de modifier les présentes conditions à tout moment.

En cochant ci-dessous, tu confirmes avoir lu et accepté l'intégralité de ces conditions.
''';

  static const String signupCgvText = '''
Conditions Générales de Vente — IncaCook

1. Prix
Les prix sont indiqués en euros et toutes taxes comprises. Pour Le Bon Fait Maison, le prix maximum par plat est plafonné à 4,50 €.

2. Commande
Toute commande passée sur la plateforme est ferme et définitive. Le paiement est effectué au moment de la commande.

3. Livraison
Les délais de livraison sont indicatifs. IncaCook s'engage à mettre en œuvre les moyens raisonnables pour respecter les délais annoncés.

4. Annulation
Une commande peut être annulée jusqu'à acceptation par le vendeur. Au-delà, aucun remboursement n'est garanti.

5. Litiges
En cas de litige, IncaCook propose un service de médiation. À défaut d'accord, les tribunaux français sont compétents.

6. Hygiène
Les vendeurs s'engagent à respecter les règles d'hygiène en vigueur. Tout manquement constaté entraîne la suspension du compte.

En cochant ci-dessous, tu confirmes avoir lu et accepté l'intégralité de ces conditions.
''';

  static const String signupSellerCharterText = '''
Charte d'hygiène — Vendeurs IncaCook

1. Tu cuisines des plats faits maison à partir d'ingrédients frais et de qualité.

2. Tu respectes la chaîne du froid : les plats sont conservés à la bonne température jusqu'au retrait par l'acheteur ou le livreur.

3. Tu te laves les mains régulièrement et travailles dans un environnement propre.

4. Tu ne réutilises pas les conserves ni les plats déjà préparés depuis plus de 24h.

5. Tu signales clairement les ingrédients allergènes dans la description de chaque plat.

6. Tu acceptes les contrôles ponctuels de IncaCook.

Le non-respect de cette charte peut entraîner la suspension immédiate de ton compte.
''';

  static const String signupDriverCharterText = '''
Charte du livreur — IncaCook

1. Tu respectes les délais de livraison annoncés et préviens le client en cas de retard.

2. Tu manipules les plats avec soin et conserves la chaîne du froid pendant le trajet.

3. Tu te présentes proprement et adoptes une attitude polie envers les vendeurs et les clients.

4. Tu ne consommes ni ne modifies le contenu des commandes.

5. Tu vérifies le bon état du véhicule avant chaque tournée.

6. Tu signales tout incident à IncaCook dans les meilleurs délais.

Le non-respect de cette charte peut entraîner la suspension immédiate de ton compte livreur.
''';

  //* order — customize sheet
  static const String orderSheetQuantityLabel = "Quantité";
  static const String orderSheetPortionsAvailableSuffix =
      "portions disponibles";
  static const String orderSheetPortionAvailableSuffix = "portion disponible";
  static const String orderSheetOptionsLabel = "Options";
  static const String orderSheetNoteLabel = "Note pour le vendeur (facultatif)";
  static const String orderSheetNoteHint = "Ex: pas trop épicé...";
  static const String orderSheetTotalLabel = "Total";
  static const String orderSheetAddToCartCta = "Ajouter au panier";
}
