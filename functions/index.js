const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {initializeApp} = require('firebase-admin/app');
const {getFirestore, FieldValue, Timestamp} = require('firebase-admin/firestore');

initializeApp();
const db = getFirestore();

function addCalendarMonths(date, months) {
  const result = new Date(date);
  const day = result.getDate();
  result.setDate(1);
  result.setMonth(result.getMonth() + months);
  const lastDay = new Date(result.getFullYear(), result.getMonth() + 1, 0).getDate();
  result.setDate(Math.min(day, lastDay));
  return result;
}

exports.redeemPromoCode = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required.');
  const raw = request.data && request.data.code;
  if (typeof raw !== 'string' || !raw.trim() || raw.trim().length > 64) {
    throw new HttpsError('invalid-argument', 'Invalid code.');
  }
  const code = raw.trim().toUpperCase();
  const uid = request.auth.uid;
  const codeRef = db.collection('promoCodes').doc(code);
  const redemptionRef = db.collection('promoRedemptions').doc(uid);
  const now = new Date();

  const expiresAt = await db.runTransaction(async (tx) => {
    const [codeSnap, redemptionSnap] = await Promise.all([
      tx.get(codeRef), tx.get(redemptionRef),
    ]);
    if (redemptionSnap.exists) {
      throw new HttpsError('already-exists', 'A promo code was already redeemed.');
    }
    if (!codeSnap.exists) throw new HttpsError('not-found', 'Invalid code.');
    const promo = codeSnap.data();
    if (promo.active !== true) throw new HttpsError('failed-precondition', 'Code unavailable.');
    if (promo.expiresAt && promo.expiresAt.toDate() <= now) {
      throw new HttpsError('failed-precondition', 'Code expired.');
    }
    const max = Number(promo.maxRedemptions || 0);
    const count = Number(promo.redemptionCount || 0);
    if (max > 0 && count >= max) {
      throw new HttpsError('failed-precondition', 'Code exhausted.');
    }
    const expiry = addCalendarMonths(now, 3);
    tx.update(codeRef, {redemptionCount: FieldValue.increment(1)});
    tx.create(redemptionRef, {
      code, uid, redeemedAt: Timestamp.fromDate(now), expiresAt: Timestamp.fromDate(expiry),
    });
    return expiry.toISOString();
  });
  return {expiresAt};
});
