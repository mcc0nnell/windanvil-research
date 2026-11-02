# WindAnvil study — Rizzer / IHB Blade evidence handoff

The study does **not** replace the existing assurance engine. It records the results of an authorized external workflow:

Rizzer executes → IHB Blade verifies → FCR compares when useful → human-reviewed findings.

## Actual contract inspected

At `robert526/rizzer` on GitLab, the `main` branch provides:

- `assurance/contracts/blade-evidence-bundle-v2.schema.json`
- `$id`: `https://lab.ihatebanks.xyz/contracts/blade-evidence-bundle-v2.schema.json`
- `schema` discriminator: `ihb.blade-evidence-bundle.v2`
- Required: `campaign_id`, `job_id`, `replay_identity`, `decision_digest`, `source`, `toolchain`, `steps`, `findings`, `artifacts`, `corpus`, `exit_semantics`, `timestamps`, `seal`.
- `source.commit_sha` must be a 40-character lowercase SHA-1 hex string; `source.repo` identifies the original repository.
- `replay_identity` and `decision_digest` are `sha256:` followed by 64 lowercase hexadecimal characters.
- `seal.algorithm` must be `sha256`; `seal.digest` is `sha256:` followed by 64 lowercase hexadecimal characters.
- `exit_semantics.judgment` is one of `pass`, `fail`, `inconclusive`. **These are run judgments, not claims that a vulnerability was verified.**

The current Neon `pipeline_runs` schema is an initial record store, not a validated production importer. It records pointer/digest strings and an authorization reference; its SQL CHECK constraints do **not** rehash artifacts, validate the complete Blade schema, authenticate an approver, or verify the seal. The `reviewed_pipeline_observations` view admits only records marked admitted with a pass and human reviewer, but callers with database write access can populate those fields. Do not treat that view as cryptographic attestation.

## Required before automated ingestion

1. Obtain an authorized Rizzer run and its exact target Git URL and pinned revision.
2. Parse and validate the full versioned Blade JSON Schema from the **pinned** Rizzer revision, not a hand-invented replacement.
3. Independently verify artifact digests, bundle seal calculation using the actual IHB implementation, and linkage to the intended run and authorized scope.
4. Preserve the original Blade judgment (including `fail` or `inconclusive`); never translate it to a vulnerability severity.
5. Store immutable artifact references, signed receipts if the upstream contract actually supplies them, and verifier identity/version.
6. Require explicit human review before publishing a security finding. FCR comparison is optional and is not authorization.

This package deliberately does not fabricate a successful run, a seal verifier, any scanner observation, or a maintainer commitment.