const { test } = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");

let env;

async function getEnv() {
  if (!env) {
    env = await initializeTestEnvironment({
      projectId: "amalay-a8a15",
      firestore: {
        rules: fs.readFileSync(
          path.resolve(__dirname, "../../firestore.rules"),
          "utf8"
        ),
      },
    });
  }
  return env;
}

async function seed(data) {
  const testEnv = await getEnv();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    for (const [docPath, value] of Object.entries(data)) {
      await db.doc(docPath).set(value);
    }
  });
}

const activeUser = (uid) => ({
  uid,
  profileComplete: true,
  accountStatus: "active",
  isPremium: false,
  profile: { firstName: "Test", gender: "Woman" },
});

test("user can read own doc", async () => {
  const testEnv = await getEnv();
  await seed({ "users/alice": activeUser("alice") });
  const db = testEnv.authenticatedContext("alice").firestore();
  await assertSucceeds(db.doc("users/alice").get());
});

test("member can read another active complete profile", async () => {
  const testEnv = await getEnv();
  await seed({
    "users/alice": activeUser("alice"),
    "users/bob": activeUser("bob"),
  });
  const db = testEnv.authenticatedContext("alice").firestore();
  await assertSucceeds(db.doc("users/bob").get());
});

test("deactivated profiles are hidden from members", async () => {
  const testEnv = await getEnv();
  await seed({
    "users/alice": activeUser("alice"),
    "users/eve": { ...activeUser("eve"), accountStatus: "deactivated" },
  });
  const db = testEnv.authenticatedContext("alice").firestore();
  await assertFails(db.doc("users/eve").get());
});

test("client cannot grant itself premium", async () => {
  const testEnv = await getEnv();
  await seed({ "users/alice": activeUser("alice") });
  const db = testEnv.authenticatedContext("alice").firestore();
  await assertFails(
    db.doc("users/alice").set({ isPremium: true }, { merge: true })
  );
});

test("client cannot change its account status", async () => {
  const testEnv = await getEnv();
  await seed({
    "users/eve": { ...activeUser("eve"), accountStatus: "deactivated" },
  });
  const db = testEnv.authenticatedContext("eve").firestore();
  await assertFails(
    db.doc("users/eve").set({ accountStatus: "active" }, { merge: true })
  );
});

test("client cannot write likes directly", async () => {
  const testEnv = await getEnv();
  const db = testEnv.authenticatedContext("alice").firestore();
  await assertFails(
    db.doc("likes/alice_bob").set({ from: "alice", to: "bob", action: "like" })
  );
});

test("client cannot forge matches", async () => {
  const testEnv = await getEnv();
  const db = testEnv.authenticatedContext("alice").firestore();
  await assertFails(
    db.doc("matches/alice_bob").set({ members: ["alice", "bob"] })
  );
});

test("active user can file a report about someone else", async () => {
  const testEnv = await getEnv();
  await seed({ "users/alice": activeUser("alice") });
  const db = testEnv.authenticatedContext("alice").firestore();
  await assertSucceeds(
    db.collection("reports").add({
      reporterUid: "alice",
      reportedUid: "bob",
      reason: "Fake profile or scam",
      status: "pending",
    })
  );
});

test("report must use the caller's own uid", async () => {
  const testEnv = await getEnv();
  await seed({ "users/alice": activeUser("alice") });
  const db = testEnv.authenticatedContext("alice").firestore();
  await assertFails(
    db.collection("reports").add({
      reporterUid: "mallory",
      reportedUid: "bob",
      reason: "Fake profile or scam",
      status: "pending",
    })
  );
});

test("non-admin cannot read reports", async () => {
  const testEnv = await getEnv();
  await seed({
    "reports/r1": {
      reporterUid: "alice",
      reportedUid: "bob",
      reason: "x y z",
      status: "pending",
    },
  });
  const db = testEnv.authenticatedContext("alice").firestore();
  await assertFails(db.doc("reports/r1").get());
});

test("admin can read and update reports", async () => {
  const testEnv = await getEnv();
  await seed({
    "reports/r2": {
      reporterUid: "alice",
      reportedUid: "bob",
      reason: "x y z",
      status: "pending",
    },
  });
  const db = testEnv
    .authenticatedContext("root", { admin: true })
    .firestore();
  await assertSucceeds(db.doc("reports/r2").get());
  await assertSucceeds(
    db.doc("reports/r2").update({ status: "reviewed" })
  );
});

test("cleanup", async () => {
  const testEnv = await getEnv();
  await testEnv.cleanup();
  assert.ok(true);
});
