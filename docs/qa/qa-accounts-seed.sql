-- ============================================================================
-- IncaCook — QA test accounts seed (hosted DB: eoxrrofpdtrwjbhywcvz)
-- ============================================================================
-- 2 sellers, 2 drivers, 2 buyers. Idempotent (ON CONFLICT guards every row).
-- Zones already exist by name-as-id ("Paris 11e", "Lyon Centre", ...).
--
-- PREREQUISITE: the 6 users must first exist in Supabase Auth with the UIDs
-- used below (User.id = supabaseId = Auth UID). Passwords are set there:
--   Sellers: Seller123!  ·  Drivers: Driver123!  ·  Buyers: Buyer123!
--
-- HOW TO RUN: paste into Supabase Dashboard → SQL Editor → Run.
-- See comprehensive-qa-guide.md §6 for the full UID table.
-- ============================================================================


-- ========================= SELLER 1: Paris 11e =========================
INSERT INTO public."User" (id,"supabaseId",email,phone,role,"firstName","lastName","emailVerified","phoneVerified","acceptedCgu","acceptedCgv","acceptedAt","createdAt","updatedAt")
VALUES ('de71fccf-c5fe-4bb1-9041-dbc945d1905a','de71fccf-c5fe-4bb1-9041-dbc945d1905a','qa+seller-paris@incacook.fr','+33611111101','SELLER','Pierre','Dubois',true,true,true,true,NOW(),NOW(),NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO public."SellerProfile" ("userId",category,"displayName",bio,"kycStatus","deliveryFeeCents","deliveryRadiusKm","subscriptionStatus","subscriptionCurrentPeriodEnd","isPremium","hygieneCommitment","faitMaisonCommitment","location","updatedAt")
VALUES ('de71fccf-c5fe-4bb1-9041-dbc945d1905a','FAIT_MAISON','Chez Pierre - Paris 11e','Cuisine française maison',
        'APPROVED',250,5.0,'ACTIVE',NOW()+INTERVAL '30 days',true,true,true,
        ST_SetSRID(ST_MakePoint(2.3799,48.8530),4326)::geography, NOW())
ON CONFLICT ("userId") DO UPDATE SET "kycStatus"='APPROVED',"subscriptionStatus"='ACTIVE',"subscriptionCurrentPeriodEnd"=NOW()+INTERVAL '30 days',location=ST_SetSRID(ST_MakePoint(2.3799,48.8530),4326)::geography,"updatedAt"=NOW();

INSERT INTO public."Address" (id,"userId",kind,type,"fullAddress",city,"postalCode",point,"updatedAt")
VALUES ('addr_seller_paris','de71fccf-c5fe-4bb1-9041-dbc945d1905a','SELLER_PICKUP','OTHER','20 Rue de la Roquette, Paris 11e','Paris','75011',ST_SetSRID(ST_MakePoint(2.3799,48.8530),4326)::geography,NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO public."SellerCuisine" ("userId","cuisineType") VALUES ('de71fccf-c5fe-4bb1-9041-dbc945d1905a','FRANCAISE') ON CONFLICT DO NOTHING;

INSERT INTO public."Listing" (id,"sellerId",name,description,"priceCents","dietaryTags",category,fulfillment,"prepMinutes","portionsLeft","isAvailable","updatedAt")
VALUES
 ('list_paris_1','de71fccf-c5fe-4bb1-9041-dbc945d1905a','Boeuf Bourguignon','Bœuf mijoté au vin rouge',1200,ARRAY[]::"DietaryTag"[],'FAIT_MAISON','BOTH',45,4,true,NOW()),
 ('list_paris_2','de71fccf-c5fe-4bb1-9041-dbc945d1905a','Tarte aux Fruits','Tarte aux fruits de saison',600,ARRAY[]::"DietaryTag"[],'FAIT_MAISON','BOTH',10,6,true,NOW()),
 ('list_paris_3','de71fccf-c5fe-4bb1-9041-dbc945d1905a','Blanquette de Veau','Veau en sauce blanche',1350,ARRAY[]::"DietaryTag"[],'FAIT_MAISON','BOTH',40,4,true,NOW()),
 ('list_paris_4','de71fccf-c5fe-4bb1-9041-dbc945d1905a','Végé Bowl','Bowl végétarien complet',950,ARRAY['VEGAN']::"DietaryTag"[],'FAIT_MAISON','BOTH',15,3,true,NOW())
ON CONFLICT (id) DO NOTHING;

-- ========================= SELLER 2: Lyon =========================
INSERT INTO public."User" (id,"supabaseId",email,phone,role,"firstName","lastName","emailVerified","phoneVerified","acceptedCgu","acceptedCgv","acceptedAt","createdAt","updatedAt")
VALUES ('614f04a8-8cae-4837-a2f6-b74cee577014','614f04a8-8cae-4837-a2f6-b74cee577014','qa+seller-lyon@incacook.fr','+33611111102','SELLER','François','Martin',true,true,true,true,NOW(),NOW(),NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO public."SellerProfile" ("userId",category,"displayName",bio,"kycStatus","deliveryFeeCents","deliveryRadiusKm","subscriptionStatus","subscriptionCurrentPeriodEnd","isPremium","hygieneCommitment","faitMaisonCommitment","location","updatedAt")
VALUES ('614f04a8-8cae-4837-a2f6-b74cee577014','FAIT_MAISON','Bouchon Lyonnais','Spécialités lyonnaises',
        'APPROVED',250,5.0,'ACTIVE',NOW()+INTERVAL '30 days',false,true,true,
        ST_SetSRID(ST_MakePoint(4.8357,45.7640),4326)::geography, NOW())
ON CONFLICT ("userId") DO UPDATE SET "kycStatus"='APPROVED',"subscriptionStatus"='ACTIVE',"subscriptionCurrentPeriodEnd"=NOW()+INTERVAL '30 days',location=ST_SetSRID(ST_MakePoint(4.8357,45.7640),4326)::geography,"updatedAt"=NOW();

INSERT INTO public."Address" (id,"userId",kind,type,"fullAddress",city,"postalCode",point,"updatedAt")
VALUES ('addr_seller_lyon','614f04a8-8cae-4837-a2f6-b74cee577014','SELLER_PICKUP','OTHER','15 Rue de la République, Lyon','Lyon','69002',ST_SetSRID(ST_MakePoint(4.8357,45.7640),4326)::geography,NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO public."SellerCuisine" ("userId","cuisineType") VALUES ('614f04a8-8cae-4837-a2f6-b74cee577014','FRANCAISE') ON CONFLICT DO NOTHING;

INSERT INTO public."Listing" (id,"sellerId",name,description,"priceCents","dietaryTags",category,fulfillment,"prepMinutes","portionsLeft","isAvailable","updatedAt")
VALUES
 ('list_lyon_1','614f04a8-8cae-4837-a2f6-b74cee577014','Quenelle de Brochet','Quenelle traditionnelle lyonnaise',1150,ARRAY[]::"DietaryTag"[],'FAIT_MAISON','BOTH',30,4,true,NOW()),
 ('list_lyon_2','614f04a8-8cae-4837-a2f6-b74cee577014','Saucisson Brioché','Saucisson sur brioche chaude',800,ARRAY[]::"DietaryTag"[],'FAIT_MAISON','BOTH',15,4,true,NOW()),
 ('list_lyon_3','614f04a8-8cae-4837-a2f6-b74cee577014','Poulet de Bresse','Poulet rôti aux herbes',1400,ARRAY[]::"DietaryTag"[],'FAIT_MAISON','BOTH',35,4,true,NOW())
ON CONFLICT (id) DO NOTHING;

-- ========================= DRIVER 1: Paris only =========================
INSERT INTO public."User" (id,"supabaseId",email,phone,role,"firstName","lastName","emailVerified","phoneVerified","acceptedCgu","acceptedCgv","acceptedAt","createdAt","updatedAt")
VALUES ('68fd4ac3-cd0b-47f7-9508-c3aa127c39a6','68fd4ac3-cd0b-47f7-9508-c3aa127c39a6','qa+driver-paris@incacook.fr','+33622222201','DRIVER','Lucas','Moreau',true,true,true,true,NOW(),NOW(),NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO public."DriverProfile" ("userId","vehicleType","kycStatus","isOnline","totalDeliveries","charterAccepted","punctualityCommitment","careCommitment","stripeOnboardingCompleted","createdAt","updatedAt")
VALUES ('68fd4ac3-cd0b-47f7-9508-c3aa127c39a6','BICYCLE','APPROVED',false,0,true,true,true,false,NOW(),NOW())
ON CONFLICT ("userId") DO UPDATE SET "kycStatus"='APPROVED',"updatedAt"=NOW();

INSERT INTO public."DriverZone" ("userId","zoneId") VALUES ('68fd4ac3-cd0b-47f7-9508-c3aa127c39a6','Paris 11e') ON CONFLICT DO NOTHING;

-- ========================= DRIVER 2: National =========================
INSERT INTO public."User" (id,"supabaseId",email,phone,role,"firstName","lastName","emailVerified","phoneVerified","acceptedCgu","acceptedCgv","acceptedAt","createdAt","updatedAt")
VALUES ('6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','qa+driver-national@incacook.fr','+33622222202','DRIVER','Maxime','Girard',true,true,true,true,NOW(),NOW(),NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO public."DriverProfile" ("userId","vehicleType","kycStatus","isOnline","totalDeliveries","charterAccepted","punctualityCommitment","careCommitment","stripeOnboardingCompleted","createdAt","updatedAt")
VALUES ('6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','CAR','APPROVED',false,0,true,true,true,false,NOW(),NOW())
ON CONFLICT ("userId") DO UPDATE SET "kycStatus"='APPROVED',"updatedAt"=NOW();

INSERT INTO public."DriverZone" ("userId","zoneId") VALUES
 ('6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','Paris 11e'),
 ('6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','Paris 1er'),
 ('6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','Paris 4e — Le Marais'),
 ('6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','Lyon Centre'),
 ('6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','Marseille Vieux-Port')
ON CONFLICT DO NOTHING;

-- ========================= BUYER 1: Paris 11e =========================
INSERT INTO public."User" (id,"supabaseId",email,phone,role,"firstName","lastName","emailVerified","phoneVerified","acceptedCgu","acceptedCgv","acceptedAt","createdAt","updatedAt")
VALUES ('91b8bc5f-8f41-4d50-9141-fb2ae89b0ac8','91b8bc5f-8f41-4d50-9141-fb2ae89b0ac8','qa+buyer-paris@incacook.fr','+33633333301','BUYER','Sophie','Laurent',true,true,true,true,NOW(),NOW(),NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO public."BuyerProfile" ("userId","updatedAt") VALUES ('91b8bc5f-8f41-4d50-9141-fb2ae89b0ac8',NOW()) ON CONFLICT ("userId") DO NOTHING;

INSERT INTO public."Address" (id,"userId",kind,type,"fullAddress",city,"postalCode",point,"updatedAt")
VALUES ('addr_buyer_paris','91b8bc5f-8f41-4d50-9141-fb2ae89b0ac8','BUYER_DELIVERY','HOME','25 Boulevard Beaumarchais, Paris 11e','Paris','75011',ST_SetSRID(ST_MakePoint(2.3799,48.8530),4326)::geography,NOW())
ON CONFLICT (id) DO NOTHING;

-- ========================= BUYER 2: Lyon =========================
INSERT INTO public."User" (id,"supabaseId",email,phone,role,"firstName","lastName","emailVerified","phoneVerified","acceptedCgu","acceptedCgv","acceptedAt","createdAt","updatedAt")
VALUES ('5b757ac3-8d08-4119-8581-036bff07c940','5b757ac3-8d08-4119-8581-036bff07c940','qa+buyer-lyon@incacook.fr','+33633333302','BUYER','Camille','Roux',true,true,true,true,NOW(),NOW(),NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO public."BuyerProfile" ("userId","updatedAt") VALUES ('5b757ac3-8d08-4119-8581-036bff07c940',NOW()) ON CONFLICT ("userId") DO NOTHING;

INSERT INTO public."Address" (id,"userId",kind,type,"fullAddress",city,"postalCode",point,"updatedAt")
VALUES ('addr_buyer_lyon','5b757ac3-8d08-4119-8581-036bff07c940','BUYER_DELIVERY','HOME','8 Place Bellecour, Lyon','Lyon','69002',ST_SetSRID(ST_MakePoint(4.8357,45.7640),4326)::geography,NOW())
ON CONFLICT (id) DO NOTHING;
