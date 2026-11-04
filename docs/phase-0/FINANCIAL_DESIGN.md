# Financial, payment and settlement architecture

**Status: design only. No merchant approval, live provider or payment credentials exist. Paid gates remain false.**

## 1. Chosen commercial model

- Captain pays the full solo/team registration amount once.
- Platform deducts a configurable, versioned commission from eligible collected entry fees.
- Organizer receives the approved residual settlement after agreed provider charges, refunds and applicable tax adjustments.
- Organizer is responsible for paying winners from legally sourced organizer/sponsor funds.
- Entry collections are not automatically pooled as prize money.
- No player wallet, transferable balance, bet, wager, stake or deposit system.

Separate four events:
1. **Collection:** PSP captured payer's gross amount.
2. **Allocation:** commission and organizer payable computed under versioned policy.
3. **Settlement:** PSP actually transferred money to platform/organizer.
4. **Prize disbursement:** organizer separately paid winner.

A payable is not proof of money received; capture is not settlement; evidence upload is not prize payment confirmation.

## 2. Checkout and automatic amount

After captain chooses a tournament:
1. Client submits registration ID and method LINK or DYNAMIC_QR. It does not submit price.
2. Backend verifies captain authority, accepted roster, game/mode, eligibility, capacity and no prior successful payment.
3. Backend loads current immutable published pricing and commission-policy version.
4. Backend atomically reserves one slot with bounded expiry.
5. Backend snapshots organizer, provider beneficiary, registration and roster.
6. Backend creates an internal payment order and idempotency key.
7. PSP creates a hosted payment link or dynamic QR for the exact server-derived INR amount and order reference.
8. API stores PSP attempt/expiry and returns the hosted URL or QR payload/reference.
9. Client displays amount and method; browser return is not trusted as payment proof.
10. PSP webhook is verified against raw body, stored durably and processed asynchronously.
11. Backend fetches/validates provider transaction: merchant, order reference, amount, currency and captured state.
12. One database transaction records transaction, ledger journal, one registration confirmation and transactional outbox notification.
13. Additional captures are recorded as excess payment and sent to refund/reconciliation; never create another registration.

### Link and QR requirements
- Unique payment instrument per order/attempt.
- Exact amount and INR from backend.
- No partial payment initially.
- Expiry aligned with slot reservation.
- Dynamic, order-specific QR only; reject static merchant QR as authoritative order reconciliation.
- Show only provider-created instrument returned by backend; don't construct arbitrary UPI URI or accept typed UPI string as payment proof.
- PSP must confirm dynamic QR and split-settlement compatibility in the same approved merchant setup.
- On the same Android device, QR may require a supported UPI intent/app handoff or a second device to scan; document provider/device limitations.
- Do not expose QR/order to another player's account without captain sharing intent; order still belongs to the registration, not payer display name.

## 3. Payment states

\`\`\`text
CREATED -> PROVIDER_PENDING -> CAPTURED
                         -> FAILED
                         -> EXPIRED
                         -> CANCELLED
CAPTURED -> EXCESS_REVIEW (registration already paid)
CAPTURED -> REFUND_PENDING -> REFUNDED
CAPTURED -> DISPUTED / CHARGEBACK
\`\`\`

Payment transaction and registration are distinct state machines. Registration confirmation occurs only after provider verification and atomic commit.

## 4. Duplicate-payment protection

Primary dedupe key: provider payment ID scoped to provider merchant account. Webhook event ID is separately unique. UPI RRN/bank reference is a secondary reconciliation signal; availability and format are provider-specific. Do not use amount + payer name as a unique identity.

| Scenario | Required result |
|---|---|
| Same webhook delivered repeatedly | Store/ack duplicate; no repeated side effect |
| Same provider payment ID mapped to different orders | Quarantine, fraud/reconciliation case; never credit twice |
| Two different captured payment IDs for same registration | One successful registration; second is excess capture and refund/review |
| Captain shares link and another person pays | Payment remains tied to designated order; payer display name is not treated as account identity |
| Wrong amount/currency/merchant/order reference | No registration confirmation; exception/refund review |
| Payment arrives after reservation expiry or last slot is taken | No oversell; explicit exception/refund path |
| Provider is unavailable or status ambiguous | Fail closed; query provider before retry |
| Captain retries after pending attempt | New attempt under same order policy, not a second registration |

Atomic confirmation algorithm: lock order and registration; validate PSP/merchant/ref/amount/currency/captured status; ensure provider transaction ID unused; ensure registration has no success; check slot still valid; insert transaction and balanced journal; confirm registration once; mark order fulfilled; write outbox; commit. If any invariant fails, do not partially confirm.

## 5. Gateway shortlist and selection

Provider choice is not final. Public documentation is not underwriting approval.

| Candidate | Publicly documented capability | Unknown / required proof | Status |
|---|---|---|---|
| Cashfree PG + Easy Split | Public Easy Split material describes commission deduction, vendor/bank splits, refunds/adjustments, webhook reconciliation; FAQ describes Payment Links with Easy Split. Cashfree separately advertises dynamic UPI QR. | Public pages do not prove dynamic QR + Easy Split combined for this gaming model, underwriting approval, organizer payout method or exact merchant-of-record arrangement. | First technical discovery candidate; NOT APPROVED |
| Razorpay PG + Route | Public docs describe linked accounts and route transfers/payment-link capabilities. | Verify current eligibility, organizer onboarding, QR + split compatibility, fees/limits, refunds, VPA/bank payout and tournament category acceptance. | Alternative; NOT APPROVED |
| Generic static UPI QR | Simple scan | No robust order-specific settlement allocation or automatic reconciliation | Reject as source of truth |

Useful provider references:
- [Cashfree Easy Split](https://www.cashfree.com/easy-split/split-payment-gateway/)
- [Cashfree UPI for Business / dynamic QR](https://www.cashfree.com/upi-for-business/)
- [Cashfree Payment Links](https://www.cashfree.com/payment-links/)
- [Razorpay Route](https://razorpay.com/route/)
- [Razorpay Payment Links](https://razorpay.com/payment-links/)
- [Razorpay partnership/collection facilitation terms](https://razorpay.com/partnership-services-and-collection-facilitation-agreement/)

Before selection, send providers the accurate business model: independent India-based Free Fire tournament marketplace; captain pays a registration fee; platform retains disclosed commission; net eligible amount goes to a verified organizer; organizer separately funds/pays prizes; no wallet, stake, wager or pooled entry-fee prize. Ask in writing about approved category, merchant of record, organizer KYC, link+dynamic QR with split, payout method, refunds/chargebacks, reserves, tax and limits. Never misstate business category.

Select only after written approval and sandbox acceptance for link, QR, exact amount, split, duplicate capture, webhook retries, refunds, failed settlement and reconciliation. If none approve, paid mode remains disabled.

## 6. Commission model

Commission percentage is not finalized. Do not hardcode it.

Versioned commission policy must record:
- Percentage or fixed amount.
- Calculation basis (gross fee or other accountant-approved base).
- Rate in basis points or fixed paise.
- Minimum/maximum.
- Rounding mode.
- Whether PSP fee is borne by platform or organizer.
- Tax basis and invoice treatment.
- Effective date.
- Approver and audit record.

Illustration only:
- Gross received: ₹1,000 = 100,000 paise.
- Platform commission: ₹100 = 10,000 paise.
- PSP fee: ₹25 = 2,500 paise.
- Organizer net entitlement: ₹875 = 87,500 paise.

\`100000 = 10000 + 2500 + 87500\`.

This is arithmetic only, not an actual fee quote or tax treatment. GST, TDS, invoice, revenue recognition and fee bearer must be set by Indian accountant/tax counsel.

## 7. Double-entry ledger

Use append-only double-entry accounting. Dashboard balances derive from journals and provider settlement events; no user/admin can edit balance. Money is integer paise. A journal is posted atomically only after total debits equal total credits. Correction is reversal/adjustment, never update/delete of posted journal.

Example capture/allocation:

| Account | Debit (paise) | Credit (paise) |
|---|---:|---:|
| PSP clearing asset | 100,000 | 0 |
| Organizer payable | 0 | 87,500 |
| Platform commission revenue | 0 | 10,000 |
| PSP fee payable | 0 | 2,500 |
| **Total** | **100,000** | **100,000** |

Fee deduction: Dr PSP fee payable 2,500 / Cr PSP clearing 2,500.  
Split settlement: Dr platform bank 10,000; Dr organizer payable 87,500 / Cr PSP clearing 97,500.  
Each journal balances. Actual posting depends on contract/provider settlement statement and accountant-approved GST/TDS policy.

Core accounts: PSP clearing asset, platform bank asset, organizer payable liability, commission revenue, PSP fee payable/expense, tax payable/receivable, refund clearing/liability, chargeback liability, settlement in transit. No player wallet and no platform prize-pool account.

Refund is a new linked event/journal; cumulative refunds cannot exceed captured gross. Post-settlement reversal only through contractual recovery/receivable process; never rewrite original journal or debit another organizer.

Daily reconciliation compares internal captures, provider transactions, webhooks, refunds, commission split, fees, settlement report and bank credits. Discrepancies create immutable cases and finance review.

## 8. Organizer onboarding and settlement

Organizer is a verified legal/merchant beneficiary, not a free-form UPI text field. Provider may require legal entity type, PAN/GST, bank details, beneficial ownership, proof and contracts. A typed VPA is not evidence of identity or settlement authority.

Lifecycle: NOT_STARTED → DETAILS_SUBMITTED → PROVIDER_KYC_PENDING → VERIFICATION_PENDING → ACTIVE; alternatives SUSPENDED/REJECTED/REVERIFICATION_REQUIRED.

Prefer provider-linked settlement account. If VPA settlement is explicitly supported for the exact provider product/business, verify through PSP and store opaque beneficiary ref + masked VPA/name. Otherwise use bank settlement. Dynamic QR collection does not imply UPI payout support. Never store UPI PIN, OTP or online banking password.

Settlement lifecycle: ALLOCATED → ELIGIBLE → PROVIDER_REQUESTED → PROCESSING → SETTLED, or FAILED/REVERSED/ON_HOLD. Mark settled only from PSP event/report or independently verified bank record. Payable is not bank credit. Respect provider limits, reserve, cooldown and settlement cycle. If transfer status is unknown, query before retry. Destination changes trigger re-onboarding; existing payment orders retain beneficiary snapshots. Maker-checker for manual exception.

Organizer dashboard distinguishes gross captured, platform commission, gateway fees/tax, refunds/chargebacks, net payable, settlement initiated and actual settled.

## 9. Prize disbursement (organizer pays winners)

Organizer pays winners from legally sourced organizer/sponsor funds. Participant entry collections are not automatically pooled into prizes. Platform does not custody a prize wallet or promise automated prize payout in Phase 0.

Before advertising guaranteed cash prizes, save a versioned prize schedule, total, funding source, evidence review, responsible legal organizer and published terms. Lock at first paid registration. Material changes require notice/consent as appropriate and cancellation/refund path.

After verified final ranking, backend creates per-winner award from immutable prize version. Organizer initiates payment and submits reference/evidence. Status becomes \`EVIDENCE_SUBMITTED\`, not \`PAID_CONFIRMED\`. Confirm only via PSP/bank lookup/report or independent finance verification. A screenshot, typed UTR or payer name is not conclusive. If no verification integration exists, display \`ORGANIZER_CLAIMS_PAID\`/evidence-submitted, not paid-confirmed.

Statuses: COMMITTED, FUNDING_EVIDENCE_PENDING, FUNDING_REVIEWED, AWARDED, PAYMENT_INITIATED, EVIDENCE_SUBMITTED, PENDING_VERIFICATION, PAID_CONFIRMED, FAILED, OVERDUE, DISPUTED, CANCELLED_WITH_APPROVED_REASON.

Organizer agreement sets source, deadline, tax obligations, identity, unclaimed prize, cancellation and grievance.

## 10. Required finance entities

\`payment_orders\`, \`payment_attempts\`, \`payment_transactions\`, \`webhook_events\`, \`refunds\`, \`commission_policy_versions\`, \`ledger_accounts\`, \`ledger_journals\`, \`ledger_entries\`, \`organizer_payables\`, \`settlement_transfers\`, \`reconciliation_items\`, \`prize_commitments\`, \`prize_awards\`, \`prize_disbursements\`.

All are described in the database design/ERD. No manual balance editing or transferable player wallet.
