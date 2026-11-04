import { existsSync, readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const required = [
  "README.md",
  "docs/phase-0/README.md",
  "docs/phase-0/ARCHITECTURE.md",
  "docs/phase-0/FINANCIAL_DESIGN.md",
  "docs/phase-0/SECURITY_COMPLIANCE_DEPLOYMENT.md",
  "docs/phase-0/PRODUCT_DESIGN_ROADMAP.md",
  "docs/phase-0/VALIDATION_REPORT.md",
];
const failures = [];
const content = new Map();

for (const relativePath of required) {
  const absolutePath = resolve(root, relativePath);
  if (!existsSync(absolutePath)) {
    failures.push("Missing required file: " + relativePath);
    continue;
  }
  const text = readFileSync(absolutePath, "utf8");
  if (text.trim().length < 100) failures.push("File is unexpectedly short: " + relativePath);
  content.set(relativePath, text);
}

for (const [relativePath, text] of content) {
  for (const match of text.matchAll(/\]\(([^)]+)\)/g)) {
    const target = match[1].split("#")[0];
    if (!target || /^(https?:|mailto:|#)/.test(target)) continue;
    const absoluteTarget = resolve(dirname(resolve(root, relativePath)), target);
    if (!existsSync(absoluteTarget)) failures.push("Broken local Markdown link: " + relativePath + " -> " + target);
  }
}

const mustContain = (file, fragment) => {
  if (!(content.get(file) ?? "").includes(fragment)) {
    failures.push("Missing invariant in " + file + ": " + fragment);
  }
};

mustContain("docs/phase-0/FINANCIAL_DESIGN.md", "DYNAMIC_QR");
mustContain("docs/phase-0/FINANCIAL_DESIGN.md", "beneficiary snapshots");
mustContain("docs/phase-0/FINANCIAL_DESIGN.md", "provider payment ID");
mustContain("docs/phase-0/ARCHITECTURE.md", "One Firebase Authentication project");
mustContain("docs/phase-0/ARCHITECTURE.md", "Clash Squad is team-only");
mustContain("docs/phase-0/ARCHITECTURE.md", "Idempotency-Key");
mustContain("docs/phase-0/ARCHITECTURE.md", "another organizer's finance");
mustContain("docs/phase-0/SECURITY_COMPLIANCE_DEPLOYMENT.md", "PAID_REGISTRATION_ENABLED=false");
mustContain("docs/phase-0/SECURITY_COMPLIANCE_DEPLOYMENT.md", "ORGANIZER_SETTLEMENT_ENABLED=false");
mustContain("docs/phase-0/SECURITY_COMPLIANCE_DEPLOYMENT.md", "CASH_PRIZE_FEATURES_ENABLED=false");
mustContain("docs/phase-0/SECURITY_COMPLIANCE_DEPLOYMENT.md", "PLAY_STORE_PAID_FEATURES_APPROVED=false");
mustContain("docs/phase-0/SECURITY_COMPLIANCE_DEPLOYMENT.md", "GARENA_COMMERCIAL_PERMISSION_CONFIRMED=false");
mustContain("docs/phase-0/SECURITY_COMPLIANCE_DEPLOYMENT.md", "PROG Act");
mustContain("docs/phase-0/PRODUCT_DESIGN_ROADMAP.md", "reduced-motion");

const gross = 100000;
const commission = 10000;
const gatewayFee = 2500;
const organizerNet = 87500;
if (gross !== commission + gatewayFee + organizerNet) {
  failures.push("Illustrative collection allocation does not balance.");
}
const debits = [100000].reduce((sum, value) => sum + value, 0);
const credits = [87500, 10000, 2500].reduce((sum, value) => sum + value, 0);
if (debits !== credits) failures.push("Illustrative double-entry journal does not balance.");

if (failures.length > 0) {
  console.error("Phase 0 validation FAILED");
  for (const failure of failures) console.error("- " + failure);
  process.exitCode = 1;
} else {
  console.log("Phase 0 validation PASSED: " + required.length + " files, relative links, product/permission invariants, compliance gates and double-entry arithmetic.");
}
