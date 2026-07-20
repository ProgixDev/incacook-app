// Seeds the QA seller's wallet to just over the 50 EUR withdrawal threshold so
// the payout flow is testable end to end. Authorized explicitly by the owner.
//
// Scope: INSERTs two ORDER_EARNING rows for qa+seller-paris ONLY. Touches no
// other user, no profile, no order, no Stripe. Every row is tagged
// metadata.seededBy = 'qa-withdrawal-test' so it is identifiable and reversible.
//
// Deliberately does NOT set stripeOnboardingCompleted — the seller must complete
// real Connect onboarding through the app, which is the QA step being tested.
import { readFileSync } from 'node:fs';
import { PrismaClient } from '@prisma/client';
import { ulid } from 'ulid';

function loadEnv(p) {
  const o = {};
  for (const l of readFileSync(p, 'utf8').split('\n')) {
    const m = l.match(/^([A-Z0-9_]+)=(.*)$/);
    if (m) o[m[1]] = m[2].replace(/^["']|["']$/g, '');
  }
  return o;
}

const QA_EMAIL = 'qa+seller-paris@incacook.fr';
const MARKER = 'qa-withdrawal-test';
const THRESHOLD = 5000; // WITHDRAWAL_MIN_CENTS

const env = loadEnv('/Users/macbookpro/Documents/Progix/IncaCook-Server/.env.railway.api.local');
const prisma = new PrismaClient({ datasources: { db: { url: env.DIRECT_URL } } });

try {
  const who = await prisma.$queryRawUnsafe(
    `SELECT u.id, u.role::text AS role FROM auth.users a
     JOIN "User" u ON u.id = a.id::text WHERE a.email = $1`,
    QA_EMAIL,
  );
  if (!who.length) throw new Error(`QA seller ${QA_EMAIL} not found — aborting.`);
  const userId = who[0].id;
  if (who[0].role !== 'SELLER') {
    throw new Error(`Refusing: ${userId} is ${who[0].role}, not SELLER.`);
  }
  console.log(`QA seller: ${userId} (${QA_EMAIL})`);

  const sum = async () =>
    (
      await prisma.walletEntry.aggregate({
        where: { userId, status: 'AVAILABLE' },
        _sum: { amountCents: true },
      })
    )._sum.amountCents ?? 0;

  const beforeCents = await sum();
  console.log(`AVAILABLE before: ${(beforeCents / 100).toFixed(2)} EUR`);

  // Refuse to stack seeds on re-run.
  const existing = await prisma.walletEntry.count({
    where: { userId, status: 'AVAILABLE', metadata: { path: ['seededBy'], equals: MARKER } },
  });
  if (existing > 0) {
    console.log(`\nAlready ${existing} seeded AVAILABLE row(s) present — not re-seeding.`);
    process.exit(0);
  }

  // Two rows: the claim must sweep a multi-row set, which is what the
  // double-tap test exercises. orderId stays null — these are synthetic and
  // must not collide with @@unique([orderId, userId, type]) on a real order.
  const rows = [
    { id: ulid(), amountCents: 3000 },
    { id: ulid(), amountCents: 2000 },
  ];
  await prisma.walletEntry.createMany({
    data: rows.map((r) => ({
      id: r.id,
      userId,
      orderId: null,
      type: 'ORDER_EARNING',
      amountCents: r.amountCents,
      status: 'AVAILABLE',
      currency: 'eur',
      metadata: { seededBy: MARKER, reason: 'QA: reach the 50 EUR withdrawal threshold' },
    })),
  });

  const afterCents = await sum();
  console.log(`\nSeeded: ${rows.map((r) => `${r.id} (+${r.amountCents}c)`).join('\n         ')}`);
  console.log(`AVAILABLE after: ${(afterCents / 100).toFixed(2)} EUR`);
  console.log(
    `Threshold ${(THRESHOLD / 100).toFixed(2)} EUR: ${afterCents >= THRESHOLD ? 'MET — withdrawal reachable' : 'NOT met'}`,
  );

  // Prove the blast radius: nobody else gained a balance.
  const others = await prisma.walletEntry.count({
    where: { metadata: { path: ['seededBy'], equals: MARKER }, userId: { not: userId } },
  });
  console.log(`Seeded rows on any OTHER user: ${others} (must be 0)`);

  console.log(`\nTo undo (only ever matches the seeded rows):`);
  console.log(
    `  DELETE FROM "WalletEntry" WHERE "userId" = '${userId}' AND metadata->>'seededBy' = '${MARKER}';`,
  );
} finally {
  await prisma.$disconnect();
}
