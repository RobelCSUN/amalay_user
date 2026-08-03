/**
 * Amalay Cloud Functions.
 *
 * All trust-sensitive writes happen here, never in the client:
 * - likes and matches (sendLike / sendPass), with the free-tier daily quota
 * - account lifecycle (deactivate / request deletion / admin status changes)
 * - automatic moderation (report threshold -> deactivation)
 */
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

const FREE_DAILY_LIKE_LIMIT = 10;
const DEFAULT_REPORT_THRESHOLD = 3;
const DELETION_GRACE_DAYS = 14;

const VALID_STATUSES = ["active", "deactivated", "deletedPending", "deleted"];

function requireAuth(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }
  return request.auth.uid;
}

function requireRecentAuth(request, maxAgeSeconds = 300) {
  const uid = requireAuth(request);
  const authTime = request.auth.token.auth_time;
  const now = Math.floor(Date.now() / 1000);
  if (!authTime || now - authTime > maxAgeSeconds) {
    throw new HttpsError(
      "failed-precondition",
      "Please re-authenticate to perform this action."
    );
  }
  return uid;
}

function requireAdmin(request) {
  const uid = requireAuth(request);
  const token = request.auth.token;
  if (token.admin !== true && token.support_admin !== true) {
    throw new HttpsError("permission-denied", "Admin access required.");
  }
  return uid;
}

function isSameUtcDay(a, b) {
  return (
    a.getUTCFullYear() === b.getUTCFullYear() &&
    a.getUTCMonth() === b.getUTCMonth() &&
    a.getUTCDate() === b.getUTCDate()
  );
}

function likeDocId(fromUid, toUid) {
  return `${fromUid}_${toUid}`;
}

function matchDocId(uidA, uidB) {
  return [uidA, uidB].sort().join("_");
}

async function writeAdminLog(action, actorUid, targetUid, extra = {}) {
  await db.collection("adminLogs").add({
    action,
    actorUid,
    targetUid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    ...extra,
  });
}

function assertActiveUser(snapshot, message) {
  const status = snapshot.get("accountStatus") || "active";
  if (status !== "active") {
    throw new HttpsError("failed-precondition", message);
  }
}

/**
 * Records a like. Enforces the free-tier daily quota and creates the match
 * atomically when the like is mutual. Everything runs in one transaction so
 * quota, like, and match can never drift apart.
 */
exports.sendLike = onCall(async (request) => {
  const fromUid = requireAuth(request);
  const toUid = String(request.data?.toUid || "");

  if (!toUid || toUid === fromUid) {
    throw new HttpsError("invalid-argument", "Invalid target user.");
  }

  const fromRef = db.collection("users").doc(fromUid);
  const toRef = db.collection("users").doc(toUid);
  const likeRef = db.collection("likes").doc(likeDocId(fromUid, toUid));
  const reciprocalRef = db.collection("likes").doc(likeDocId(toUid, fromUid));
  const matchRef = db.collection("matches").doc(matchDocId(fromUid, toUid));

  return db.runTransaction(async (tx) => {
    const [fromSnap, toSnap, likeSnap, reciprocalSnap] = await Promise.all([
      tx.get(fromRef),
      tx.get(toRef),
      tx.get(likeRef),
      tx.get(reciprocalRef),
    ]);

    if (!fromSnap.exists || !toSnap.exists) {
      throw new HttpsError("not-found", "User not found.");
    }
    assertActiveUser(fromSnap, "Your account is not active.");
    assertActiveUser(toSnap, "This profile is no longer available.");

    const fromBlocked = fromSnap.get("blocked") || [];
    const toBlocked = toSnap.get("blocked") || [];
    if (fromBlocked.includes(toUid) || toBlocked.includes(fromUid)) {
      throw new HttpsError("failed-precondition", "This action is not allowed.");
    }

    if (likeSnap.exists) {
      // Idempotent: re-liking spends no quota and reports current state.
      const matchSnap = await tx.get(matchRef);
      return {
        isMatch: matchSnap.exists,
        remainingLikes: remainingLikesOf(fromSnap),
      };
    }

    // Free-tier quota (UTC day). Premium users bypass entirely.
    const isPremium = fromSnap.get("isPremium") === true;
    let likesToday = 0;
    if (!isPremium) {
      const now = new Date();
      const resetAt = fromSnap.get("likesResetAt");
      const resetDate = resetAt ? resetAt.toDate() : null;
      likesToday =
        resetDate && isSameUtcDay(resetDate, now)
          ? fromSnap.get("likesToday") || 0
          : 0;
      if (likesToday >= FREE_DAILY_LIKE_LIMIT) {
        throw new HttpsError(
          "resource-exhausted",
          "Daily like limit reached. Upgrade to Premium for unlimited likes."
        );
      }
    }

    tx.set(likeRef, {
      from: fromUid,
      to: toUid,
      action: "like",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    if (!isPremium) {
      tx.set(
        fromRef,
        {
          likesToday: likesToday + 1,
          likesResetAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    const isMutual =
      reciprocalSnap.exists && reciprocalSnap.get("action") === "like";
    if (isMutual) {
      tx.set(matchRef, {
        members: [fromUid, toUid].sort(),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    const remaining = isPremium
      ? -1
      : FREE_DAILY_LIKE_LIMIT - (likesToday + 1);
    return { isMatch: isMutual, remainingLikes: remaining };
  });
});

function remainingLikesOf(userSnap) {
  if (userSnap.get("isPremium") === true) return -1;
  const resetAt = userSnap.get("likesResetAt");
  const resetDate = resetAt ? resetAt.toDate() : null;
  const likesToday =
    resetDate && isSameUtcDay(resetDate, new Date())
      ? userSnap.get("likesToday") || 0
      : 0;
  return Math.max(0, FREE_DAILY_LIKE_LIMIT - likesToday);
}

/** Records a pass. Free and unlimited, but still server-authored. */
exports.sendPass = onCall(async (request) => {
  const fromUid = requireAuth(request);
  const toUid = String(request.data?.toUid || "");
  if (!toUid || toUid === fromUid) {
    throw new HttpsError("invalid-argument", "Invalid target user.");
  }

  await db.collection("likes").doc(likeDocId(fromUid, toUid)).set({
    from: fromUid,
    to: toUid,
    action: "pass",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { ok: true };
});

/** Removes a match (unmatch). Either member may do it. */
exports.unmatch = onCall(async (request) => {
  const uid = requireAuth(request);
  const otherUid = String(request.data?.otherUid || "");
  if (!otherUid || otherUid === uid) {
    throw new HttpsError("invalid-argument", "Invalid target user.");
  }

  const matchRef = db.collection("matches").doc(matchDocId(uid, otherUid));
  const matchSnap = await matchRef.get();
  if (!matchSnap.exists) return { ok: true };
  const members = matchSnap.get("members") || [];
  if (!members.includes(uid)) {
    throw new HttpsError("permission-denied", "Not your match.");
  }
  await matchRef.delete();
  return { ok: true };
});

/** Self-service deactivation (requires recent sign-in). */
exports.deactivateMyAccount = onCall(async (request) => {
  const uid = requireRecentAuth(request);
  await db.collection("users").doc(uid).set(
    {
      accountStatus: "deactivated",
      accountStatusUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
  await writeAdminLog("self_deactivate", uid, uid, { source: "user" });
  return { ok: true };
});

/** Self-service deletion request with a grace period. */
exports.requestAccountDeletion = onCall(async (request) => {
  const uid = requireRecentAuth(request);
  const effectiveAt = new Date(
    Date.now() + DELETION_GRACE_DAYS * 24 * 60 * 60 * 1000
  );
  await db.collection("users").doc(uid).set(
    {
      accountStatus: "deletedPending",
      accountStatusUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      deletionRequestedAt: admin.firestore.FieldValue.serverTimestamp(),
      deletionEffectiveAt: admin.firestore.Timestamp.fromDate(effectiveAt),
    },
    { merge: true }
  );
  await writeAdminLog("request_deletion", uid, uid, { source: "user" });
  return { ok: true, effectiveAt: effectiveAt.toISOString() };
});

/** Admin: set any account's status. Requires admin custom claims. */
exports.adminSetAccountStatus = onCall(async (request) => {
  const actorUid = requireAdmin(request);
  const targetUid = String(request.data?.targetUid || "");
  const status = String(request.data?.status || "");

  if (!targetUid || !VALID_STATUSES.includes(status)) {
    throw new HttpsError("invalid-argument", "Invalid target or status.");
  }

  await db.collection("users").doc(targetUid).set(
    {
      accountStatus: status,
      accountStatusUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
  await writeAdminLog("admin_set_status", actorUid, targetUid, {
    source: "admin",
    status,
  });
  return { ok: true };
});

/**
 * Automatic moderation: when enough distinct users report someone, the
 * account is deactivated pending admin review. The threshold is tunable via
 * the config/moderation document without a redeploy.
 */
exports.onReportCreated = onDocumentCreated(
  "reports/{reportId}",
  async (event) => {
    const report = event.data?.data();
    if (!report?.reportedUid) return;
    const reportedUid = report.reportedUid;

    const configSnap = await db.collection("config").doc("moderation").get();
    const threshold =
      configSnap.get("autoDeactivateThreshold") || DEFAULT_REPORT_THRESHOLD;

    const reportsSnap = await db
      .collection("reports")
      .where("reportedUid", "==", reportedUid)
      .where("status", "in", ["pending", "reviewed"])
      .get();

    const distinctReporters = new Set(
      reportsSnap.docs
        .map((doc) => doc.get("reporterUid"))
        .filter((uid) => typeof uid === "string" && uid.length > 0)
    );

    if (distinctReporters.size < threshold) return;

    const userRef = db.collection("users").doc(reportedUid);
    const userSnap = await userRef.get();
    if (!userSnap.exists) return;
    if ((userSnap.get("accountStatus") || "active") !== "active") return;

    await userRef.set(
      {
        accountStatus: "deactivated",
        accountStatusUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    await writeAdminLog("auto_deactivate_reports", "system", reportedUid, {
      source: "auto_moderation",
      distinctReporters: distinctReporters.size,
      threshold,
    });
  }
);
