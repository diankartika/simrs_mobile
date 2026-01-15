const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const mappings = [];

// ================= ICD-10 → SNOMED =================
const icd10Mappings = [
  ["A09", "Infectious gastroenteritis", "235595009"],
  ["I10", "Essential hypertension", "59621000"],
  ["E11", "Type 2 diabetes mellitus", "44054006"],
  ["J18.9", "Pneumonia", "233604007"],
  ["K29", "Gastritis", "4556007"],
  ["K35", "Acute appendicitis", "74400008"],
  ["N39.0", "Urinary tract infection", "68566005"],
  ["C34.9", "Malignant neoplasm of lung", "254637007"],
  ["B20", "HIV disease", "86406008"],
  ["O80", "Normal delivery", "48782003"],
];

// auto expand jadi ±200 data
for (let i = 0; i < 20; i++) {
  icd10Mappings.forEach(([code, display, snomed]) => {
    mappings.push({
      sourceSystem: "ICD-10",
      sourceCode: code,
      sourceDisplay: display,
      targetSystem: "SNOMED-CT",
      targetCode: snomed,
      targetDisplay: display,
      mapType: "equivalent",
    });
  });
}

// ================= ICD-9-CM → SNOMED =================
const icd9Mappings = [
  ["88.39", "Ultrasound", "396538006"],
  ["99.04", "Platelet transfusion", "5971006"],
  ["96.04", "Endotracheal intubation", "6145007"],
  ["99.15", "Parenteral nutrition", "71388002"],
];

for (let i = 0; i < 10; i++) {
  icd9Mappings.forEach(([code, display, snomed]) => {
    mappings.push({
      sourceSystem: "ICD-9-CM",
      sourceCode: code,
      sourceDisplay: display,
      targetSystem: "SNOMED-CT",
      targetCode: snomed,
      targetDisplay: display,
      mapType: "equivalent",
    });
  });
}

// ================= PUSH TO FIRESTORE =================
async function seed() {
  const batch = db.batch();

  mappings.forEach((item) => {
    const ref = db.collection("terminology_maps").doc();
    batch.set(ref, {
      ...item,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  console.log(`✅ Seeded ${mappings.length} terminology mappings`);
}

seed().catch(console.error);
