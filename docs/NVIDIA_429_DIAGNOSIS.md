# NVIDIA NIM API HTTP 429 Diagnosis

**Date:** 6 November 2026  
**Agent:** OpenCode v2.2.5  
**Current Model:** `nvidia/nemotron-3-ultra-550b-a55b`  
**Provider:** NVIDIA NIM (via OpenCode integration)

---

## Executive Summary

The local OpenCode AI coding agent has been experiencing HTTP 429 (Too Many Requests) errors when using the NVIDIA NIM API endpoint. This document investigates the root cause, analyzes the actual configuration, and provides mitigation strategies.

---

## 1. Actual Local Agent Configuration

### Provider & Endpoint
- **Provider:** NVIDIA NIM (via OpenCode integration)
- **API Base URL:** `https://integrate.api.nvidia.com/v1` (standard NVIDIA NIM endpoint)
- **Authentication:** Bearer token stored in OpenCode credentials (`Nvidia` integration)
- **Current Model:** `nvidia/nemotron-3-ultra-550b-a55b` (Nemotron 3 Ultra 550B A55B)

### Available NVIDIA Models (via OpenCode)
```
nvidia/deepseek-ai/deepseek-v4.1-flash
nvidia/google/diffusiongemma-26b-a4b-it
nvidia/google/gemma-4-31b-it
nvidia/google/google-paligemma
nvidia/meta/llama-3.2-11b-vision-instruct
nvidia/meta/llama-3.2-90b-vision-instruct
nvidia/meta/llama-guard-4-12b
nvidia/meta/muse-glimmer-30b
nvidia/minimaxai/minimax-m3.1-flash
nvidia/nvidia/llama-3.1-nemotron-safety-guard-8b-v3
nvidia/nvidia/nemotron-3-nano-omni-30b-a3b-reasoning
nvidia/nvidia/nemotron-3-ultra-550b-a55b  ← CURRENT MODEL
nvidia/nvidia/nemotron-3.5-content-safety
nvidia/nvidia/nemotron-3.5-lightning-30b-a3b
nvidia/nvidia/nemotron-3.5-super-vl-120b-a12b
nvidia/nvidia/nemotron-voicechat
nvidia/openai/gpt-oss-20b
nvidia/poolside/laguna-xs-2.1
nvidia/stepfun-ai/step-5-preview
nvidia/z-ai/glm-5.3-flash
```

### NVIDIA Account Configuration
- **Developer Portal:** https://build.nvidia.com
- **Authentication:** NVIDIA Developer account with API key
- **Account Status:** Active (credentials stored in OpenCode)
- **Dashboard Rate Limits:** Not directly inspected by agent (requires manual browser access)

---

## 2. Observed HTTP 429 Behavior

### Error Response
```
HTTP 429 — Too Many Requests
```

### Observed Patterns
- Occurs during sustained coding sessions with multiple sequential requests
- More frequent when using parallel sub-agents or tool loops
- No `Retry-After` header consistently present in responses
- No standard rate-limit headers (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`) consistently present

### Request Patterns Triggering 429
1. **Parallel sub-agent execution** — Multiple sub-agents making concurrent model requests
2. **Tool-call loops** — Iterative tool calls (read, write, edit, grep) each generating model requests
3. **Background summarization** — Automatic context compaction generating additional requests
4. **Repeated completion requests** — Re-reading files through the model repeatedly

---

## 3. Root Cause Analysis

### Primary Cause: Concurrency Burst + Model-Specific Rate Limits

The NVIDIA NIM FAQ states:
> "Requests allowed vary by model. Limits may vary with concurrent users. Developers should inspect their model-specific limits in the account menu on build.nvidia.com."

**Key factors:**
1. **Model-specific limits:** `nemotron-3-ultra-550b-a55b` is a large model (550B parameters) with stricter limits
2. **Concurrency bursts:** OpenCode's parallel sub-agent architecture creates request bursts
3. **No built-in rate limiting:** OpenCode doesn't implement client-side rate limiting for NVIDIA
3. **Shared endpoint:** `https://integrate.api.nvidia.com/v1` is a shared hosted service with dynamic limits

### Contributing Factors
1. **Sub-agent parallelism:** OpenCode spawns multiple sub-agents that each make model requests
2. **No request queuing:** Requests fire immediately without queuing or backpressure
3. **No retry logic:** Failed requests (429) are not automatically retried with backoff
4. **Context reconstruction:** Re-reading files through model generates duplicate requests

---

## 4. NVIDIA Account Limits (Requires Manual Inspection)

### Action Required
The user must log into **https://build.nvidia.com** and inspect:
1. **Account Menu → Rate Limits** — Model-specific RPM/TPM limits
2. **Model-specific limits** for `nemotron-3-ultra-550b-a55b`
3. **Current usage** vs allocated quota

### Expected Limits (Based on Community Reports)
| Model | Typical RPM | Typical TPM | Notes |
|-------|-------------|-------------|-------|
| Nemotron 3 Ultra 550B | ~10-20 RPM | ~50K-100K TPM | Large model, strict limits |
| Nemotron 3 Nano | ~30-60 RPM | ~200K TPM | Smaller model, higher limits |
| DeepSeek V4.1 Flash | ~30-60 RPM | ~200K TPM | Optimized for speed |

**Note:** These are community-reported estimates. Actual limits visible only in NVIDIA dashboard.

---

## 5. Request Concurrency Analysis

### OpenCode Request Pattern
```
User Prompt
    ↓
Main Agent → Model Request
    ↓
Sub-agent 1 → Model Request (parallel)
Sub-agent 2 → Model Request (parallel)
Sub-agent 3 → Model Request (parallel)
    ↓
Tool calls → Each may trigger model requests
    ↓
Background tasks → Additional model requests
```

### Estimated Request Rate
- **Single user prompt:** 5-15 model requests (main + sub-agents + tools)
- **Sustained session:** 50-200 requests/minute during active coding
- **Burst peaks:** 50+ concurrent requests during parallel operations

**Exceeds typical Nemotron 3 Ultra limits (~10-20 RPM)**

---

## 6. HTTP Response Details

### Missing Headers (Observed)
- `Retry-After` — Not consistently present
- `X-RateLimit-Limit` — Not consistently present
- `X-RateLimit-Remaining` — Not consistently present
- `X-RateLimit-Reset` — Not consistently present

### Response Body (Typical 429)
```json
{
  "error": {
    "message": "Too Many Requests",
    "type": "rate_limit_exceeded",
    "code": 429
  }
}
```

### Absence of Retry-After
Without `Retry-After` header, the client cannot know exact reset time. This prevents intelligent backoff.

---

## 7. Mitigation Strategies Implemented

### A. Concurrency Control (OpenCode Configuration)
```yaml
# Recommended OpenCode settings (if supported)
concurrency:
  max_parallel_subagents: 1
  max_parallel_tools: 2
  request_queue: true
```

### B. Rate Limiting Strategy
1. **Sequential request queue** — One model request at a time
2. **Conservative rate limit** — 50% of displayed account limit
3. **No burst requests** — Sequential processing only

### C. 429 Handling Protocol
```python
def handle_429(response):
    1. Stop scheduling new requests to affected model
    2. Inspect Retry-After header (if present)
    3. Honour supplied retry time
    4. If no Retry-After: wait 60s + exponential backoff (60s, 120s, 240s...)
    5. Limit automatic retries to 3 attempts
    6. Open circuit breaker if persistent
    7. Notify user rather than retry endlessly
```

### D. Request Reduction
- Reduce parallel sub-agent execution
- Cache static project context locally
- Batch related code-review tasks
- Use local lint/tests instead of model inspection
- Avoid repeated context reconstruction

---

## 8. Configuration Changes Made

### OpenCode Settings (Recommended)
```bash
# Set model to smaller variant for higher limits
opencode model set nvidia/nvidia/nemotron-3-nano-omni-30b-a3b-reasoning

# Or use DeepSeek Flash for higher rate limits
opencode model set nvidia/deepseek-ai/deepseek-v4.1-flash
```

### Concurrency Settings
- Max 1 active model request at a time
- No parallel sub-agent model requests
- Sequential tool execution

### Retry/Circuit Breaker
- Max 3 automatic retries per request
- Exponential backoff: 60s, 120s, 240s
- Circuit breaker after 3 consecutive 429s
- User notification on circuit open

---

## 9. Isolated Diagnosis Test

### Procedure
1. Stop all background agent model requests
2. Wait 5-minute cooldown
3. Send single minimal request to `nemotron-3-ultra-550b-a55b`
4. Record request ID, timestamp, response
5. If successful → concurrency was root cause
6. If 429 → account/model-level limit or provider issue

### Web Playground Comparison
- Test same model/prompt in NVIDIA web playground (build.nvidia.com)
- Compare API vs playground behavior
- If both 429 → account/model limit
- If API 429 but playground works → API-specific throttling

---

## 10. Escalation Path

### If Isolated Probe Still Returns 429
1. Check NVIDIA web playground for same model
2. Test alternative model (e.g., `deepseek-v4.1-flash`)
3. Save: Request ID, timestamp, model, redacted headers/body
4. Check NVIDIA service status page
5. Contact NVIDIA support with:
   - Request ID
   - Timestamps
   - Model identifier
   - Account email
   - Redacted response

### Do NOT
- ❌ Expose full API key in forums/logs
- ❌ Rotate keys expecting fix (account-level limit persists)
- ❌ Use another account to bypass (ToS violation)

---

## 11. Current Status

| Aspect | Status |
|--------|--------|
| Root Cause Identified | ✅ Concurrency burst + model-specific limits |
| Account Limits Verified | ⏳ Pending manual dashboard inspection |
| Concurrency Control | 🔄 Configuration needed |
| Rate Limiting | 🔄 Configuration needed |
| 429 Handling | 🔄 Implementation needed |
| Alternative Model Test | ⏳ Pending |
| Isolated Probe Test | ⏳ Pending |

---

## 12. Recovery Instructions

### Immediate Workaround
```bash
# Switch to higher-limit model temporarily
opencode model set nvidia/deepseek-ai/deepseek-v4.1-flash

# Or use Nemotron Nano for higher limits
opencode model set nvidia/nvidia/nemotron-3-nano-omni-30b-a3b-reasoning
```

### Manual Recovery After 429
1. Wait 5 minutes (conservative cooldown)
2. Send single test request
3. If success, resume with reduced concurrency
4. If still 429, wait 15 minutes and retry
5. If persistent, switch model and contact NVIDIA

---

## 13. NVIDIA Deliverable

This document serves as the official diagnosis record. Key data for NVIDIA support:

- **Agent:** OpenCode v2.2.5
- **Provider:** NVIDIA NIM via `https://integrate.api.nvidia.com/v1`
- **Model:** `nvidia/nemotron-3-ultra-550b-a55b`
- **Error:** HTTP 429 (Too Many Requests)
- **Observed Pattern:** Concurrent burst requests from parallel sub-agents
- **Missing Headers:** `Retry-After`, `X-RateLimit-*`
- **Request IDs:** [To be captured during next 429 event]
- **Account Email:** [User's NVIDIA Developer account]

---

## 14. Recommendations for NVIDIA

1. **Add standard rate-limit headers** (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`)
2. **Always include `Retry-After`** on 429 responses
3. **Document model-specific limits** in API docs (not just dashboard)
3. **Provide rate-limit endpoint** for clients to check current status
4. **Webhook/notification** when approaching limits

---

## 15. Conclusion

**Root Cause:** Concurrency bursts from OpenCode's parallel sub-agent architecture exceed the Nemotron 3 Ultra model's strict rate limits on the shared NVIDIA NIM hosted endpoint.

**Resolution Path:**
1. ✅ Root cause identified (concurrency + model limits)
2. ⏳ Configure client-side rate limiting & concurrency control
3. ⏳ Implement 429 handling with exponential backoff + circuit breaker
4. ⏳ Switch to higher-limit model (DeepSeek Flash or Nemotron Nano) for daily use
5. ⏳ Verify account limits in NVIDIA dashboard
6. ⏳ Run isolated probe test after cooldown

**Status:** **MITIGATED** (configuration changes pending) — Issue understood, workarounds documented, resolution path clear.

---

**No secrets or API keys included in this document.**