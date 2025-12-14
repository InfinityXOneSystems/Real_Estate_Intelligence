# Draft PR: Infinity Prime bootstrap & safety guards (blocked for Tier4 approval)

Title: [IP][T4][INFRA] Bootstrap Infinity Prime Supervisor + Safety Checks (blocked)

Summary:
- Add Infinity Prime supervisor workflow, determinism rules, protected paths enforcement, risk gate, automerge workflow (guarded), PR & issue templates, credentials registry, and golden fixtures.

Files of interest:
- .github/workflows/infinity-prime.yml
- .github/workflows/infinity-automerge.yml (blocked — requires approval/token)
- .github/pull_request_template.md
- .github/ISSUE_TEMPLATE/infinity-prime-regression.md
- scripts/prime/risk_gate.ts
- scripts/ci/check_protected_paths.js
- docs/system/PROTECTED_PATHS.yaml
- docs/system/DETERMINISM_RULES.md
- docs/system/DECISIONS.md

Note: This PR touches Tier4 files; per Infinity Prime rules it must be labeled `blocked-approval-required` and requires manual approval. See `docs/system/BLOCKED_TIER4_CHANGES.md` for rollback and evidence.

Suggested rollback steps:
1. Revert this PR entirely if approval denied.
2. Reapply only Tier1/Tier2 changes once approved incrementally.
