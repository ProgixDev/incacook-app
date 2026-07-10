-- Completes onboarding for QA accounts so the app treats them as fully
-- onboarded (GET /v1/users/me/onboarding → next=null). Idempotent.

-- ===== SELLERS: need profilePhotoUrl + dateOfBirth + charters =====
UPDATE public."SellerProfile"
SET "profilePhotoUrl" = 'avatars/qa-placeholder.jpg',
    "dateOfBirth" = DATE '1990-01-01',
    "updatedAt" = NOW()
WHERE "userId" IN (
  'de71fccf-c5fe-4bb1-9041-dbc945d1905a',
  '614f04a8-8cae-4837-a2f6-b74cee577014'
);

-- Seller charters: HYGIENE + FAIT_MAISON (fait-maison sellers)
INSERT INTO public."UserCharter" ("userId",charter,version,"acceptedAt") VALUES
 ('de71fccf-c5fe-4bb1-9041-dbc945d1905a','HYGIENE','v1.0',NOW()),
 ('de71fccf-c5fe-4bb1-9041-dbc945d1905a','FAIT_MAISON','v1.0',NOW()),
 ('614f04a8-8cae-4837-a2f6-b74cee577014','HYGIENE','v1.0',NOW()),
 ('614f04a8-8cae-4837-a2f6-b74cee577014','FAIT_MAISON','v1.0',NOW())
ON CONFLICT DO NOTHING;

-- ===== DRIVERS: BICYCLE (skips motorized docs) + DOB + home addr + KYC + charters =====
UPDATE public."DriverProfile"
SET "vehicleType" = 'BICYCLE',
    "dateOfBirth" = DATE '1995-01-01',
    "updatedAt" = NOW()
WHERE "userId" IN (
  '68fd4ac3-cd0b-47f7-9508-c3aa127c39a6',
  '6be14ff6-a467-4c9c-bff9-c0b0072c6bdb'
);

-- Driver home addresses (guard on the (userId,kind) partial unique index)
INSERT INTO public."Address" (id,"userId",kind,type,"fullAddress",city,"postalCode",point,"updatedAt")
SELECT 'addr_driver_paris','68fd4ac3-cd0b-47f7-9508-c3aa127c39a6','DRIVER_HOME','HOME','10 Rue Oberkampf, Paris 11e','Paris','75011',ST_SetSRID(ST_MakePoint(2.3799,48.8530),4326)::geography,NOW()
WHERE NOT EXISTS (SELECT 1 FROM public."Address" WHERE "userId"='68fd4ac3-cd0b-47f7-9508-c3aa127c39a6' AND kind='DRIVER_HOME');

INSERT INTO public."Address" (id,"userId",kind,type,"fullAddress",city,"postalCode",point,"updatedAt")
SELECT 'addr_driver_nat','6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','DRIVER_HOME','HOME','1 Place Bellecour, Lyon','Lyon','69002',ST_SetSRID(ST_MakePoint(4.8357,45.7640),4326)::geography,NOW()
WHERE NOT EXISTS (SELECT 1 FROM public."Address" WHERE "userId"='6be14ff6-a467-4c9c-bff9-c0b0072c6bdb' AND kind='DRIVER_HOME');

-- Driver KYC docs: ID_FRONT + SELFIE, pre-APPROVED. Guard on (userId,type).
INSERT INTO public."KycDocument" (id,"userId",type,"fileUrl","reviewState","submittedAt")
SELECT * FROM (VALUES
 ('kyc_dpar_id','68fd4ac3-cd0b-47f7-9508-c3aa127c39a6','ID_FRONT'::"KycDocType",'kyc/qa-placeholder.jpg','APPROVED'::"KycStatus",NOW()),
 ('kyc_dpar_selfie','68fd4ac3-cd0b-47f7-9508-c3aa127c39a6','SELFIE'::"KycDocType",'kyc/qa-placeholder.jpg','APPROVED'::"KycStatus",NOW()),
 ('kyc_dnat_id','6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','ID_FRONT'::"KycDocType",'kyc/qa-placeholder.jpg','APPROVED'::"KycStatus",NOW()),
 ('kyc_dnat_selfie','6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','SELFIE'::"KycDocType",'kyc/qa-placeholder.jpg','APPROVED'::"KycStatus",NOW())
) AS v(id,uid,typ,url,st,ts)
WHERE NOT EXISTS (SELECT 1 FROM public."KycDocument" k WHERE k."userId"=v.uid AND k.type=v.typ);

-- Driver charters: PUNCTUALITY + CARE
INSERT INTO public."UserCharter" ("userId",charter,version,"acceptedAt") VALUES
 ('68fd4ac3-cd0b-47f7-9508-c3aa127c39a6','PUNCTUALITY','v1.0',NOW()),
 ('68fd4ac3-cd0b-47f7-9508-c3aa127c39a6','CARE','v1.0',NOW()),
 ('6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','PUNCTUALITY','v1.0',NOW()),
 ('6be14ff6-a467-4c9c-bff9-c0b0072c6bdb','CARE','v1.0',NOW())
ON CONFLICT DO NOTHING;

-- ===== BUYERS: mark preferences touched so cursor is null =====
UPDATE public."BuyerProfile"
SET "dietaryPreferences" = ARRAY['HALAL']::"DietaryTag"[],
    "updatedAt" = NOW()
WHERE "userId" IN (
  '91b8bc5f-8f41-4d50-9141-fb2ae89b0ac8',
  '5b757ac3-8d08-4119-8581-036bff07c940'
);
