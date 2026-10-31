# WindAnvil Research

**Critical Accessibility Infrastructure Security**

**Risk accepted. Problem unresolved.**

This is the MIT-licensed public research foundation for the **new, independent** WindAnvil initiative, not the retired WindAnvil assurance platform.

Our purpose is to investigate the possible security blast radius of shared open-source accessibility dependencies: actual consumers, release versions, functional reachability, deployment evidence, human accessibility consequences, and feasible interventions.

This repository contains an initial methodology, candidate schema, and offline validation tool. **It contains no confirmed vulnerability findings, completed audits, approved funding, or commitments from external organizations.** The project is exploratory.

## Proposed study

The proposed 13-week study would aim for approximately 200 qualifying source-backed candidate records, 24 evidence-based security investment briefs, and up to three optional, appropriately authorized technical case studies. These are **proposed deliverables**, not work already completed. The research would build on existing public discovery such as https://ecosyste.ms/ and document provenance, unknowns, and source dates.

A dependency relationship does not prove exploitability. An accessibility failure is not necessarily a security vulnerability. Security testing requires appropriate authorization and disclosure. Substantive maintainer engagement follows funding and an agreed, supported scope.

## Starting assets

- docs/methodology.md: study method, safeguards, and evidence gates.
- schemas/candidate.v0.schema.json: a candidate-only schema, not a findings database.
- tools/validate_candidates.py: offline structural validation with no scanning.
- tests/test_validate_candidates.py: minimal structural and provenance checks.

Run tests with: python3 -m unittest discover -s tests -v

## License and ownership

**MIT**, copyright (c) 2026 Robert McConnell. See LICENSE. MIT is OSI approved and is also used by several project repositories in the [alpha-omega-security](https://github.com/alpha-omega-security) organization.

This research repository is independently owned. **Alpha-Omega has not approved, funded, hosted, or endorsed it.** Publication of future artifacts under alpha-omega-security would require explicit agreement. Third-party datasets and code retain their respective licenses and attribution requirements.

Public study overview: https://windanvil.com/study
