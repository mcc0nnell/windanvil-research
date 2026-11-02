# WindAnvil research study / Neon

**Scope:** critical accessibility infrastructure security research.  This is **not** the retired WindAnvil assurance system.

## Current research environment

- Neon project: `accessibility-atlas` (private deployment identifiers omitted from this public research repository)
- Isolated branch: `windanvil-study-200-20261101` (review environment)
- Schema: `windanvil_study`
- Main branch: unchanged by the study setup
- Inventory snapshot: 2026-10-31, 200 unique GitHub repos, 10 categories of 20
- Screening cohort: 24 **proposed**, **not approved**, projects
- Verified vulnerabilities and admitted scanner observations: **zero** at setup

## Files

- `001_schema.sql`: current research schema, referenced Atlas views, provenance and evidence handoff
- `002_screening_cohort.sql`: an illustrative first-pass cohort with concrete evidence gates
- `candidates.csv`: source inventory, reproduced from the existing ChatGPT Library file
- `import_candidates.py`: validates and imports source CSV; explicitly requires `--write`
- `verify.sql`: read-only checks

## Architecture

Rizzer executes → IHB Blade verifies → FCR compares when useful → human reviews.

Postgres stores metadata and pointers to immutable artifacts. It does **not** execute Rizzer or IHB Blade; it does not itself validate report hashes or prove exploitability. A `pipeline_runs` row marked `admitted` requires recorded scope authorization, a run digest, a Blade pass and receipt digest, and a named human review. The view `reviewed_pipeline_observations` excludes other runs. A recorded pass is not cryptographic verification by the database, and admission is not automatically a vulnerability finding.

`atlas_exact_repo_matches` links an inventory repository only when its URL exactly matches a canonical Atlas entity URL (ignoring capitalization and terminal `/`). `atlas_documented_context` exposes existing documentation links, **not** exploit evidence.

## Recreate on an isolated branch

1. Use a direct / unpooled Neon Postgres connection and verify branch identity.
2. Run `001_schema.sql` in a transaction.
3. Run `python import_candidates.py candidates.csv --check-only` to validate the inventory.
4. Only on the intended branch, set `DATABASE_URL_UNPOOLED` securely and run `python import_candidates.py candidates.csv --write --acknowledge-branch windanvil-study-200-20261101`. Requires Python's `psycopg` package, and intentionally does not echo credentials.
5. Apply `002_screening_cohort.sql`.
6. Execute `verify.sql` and inspect the 200 / 24 / 15 counts.

Do not promote this schema or connect public frontends directly to database credentials. Route user-facing charts through an authenticated backend that publishes only reviewed, permission-appropriate aggregates.

## Research boundaries

Repository existence is not a vulnerability. Verify downstream consumers, deployed revisions, reachable input paths, actual accessibility consequences and test authorization before concluding risk. No speculative maintainer outreach before funding; no active testing without documented scope. The 24 nominees can change after research.

## Phase 3 — read-only public aggregate feed (implemented on study branch)

- `003_public_feed.sql` adds `public_category_summary`, `public_stage_summary`, and `public_feed_v1` views, and can be reapplied idempotently on the isolated branch.
- `SELECT payload FROM windanvil_study.public_feed_v1` returns a `windanvil.public-research-summary.v1` JSON object. It contains ONLY summary metrics, categories, and research workflow states, without raw code artifacts, reviewer names, individual repo URLs, secret connection strings, or unpublished findings.
- `export_public_feed.py --out public-research-feed-v1.json` reads that view from **a trusted backend environment** using `DATABASE_URL_UNPOOLED` and refuses unexpected fields or inconsistent totals. Install `psycopg[binary]` to execute the live export; it is not bundled here.
- `export_public_feed.py --input public-research-feed-v1.json --out validated-public-feed.json` validates an existing offline JSON snapshot without database access.
- `build_verified_snapshot.py` creates the frozen initial snapshot, using the imported CSV, the specified cohort, and the 15 exact Atlas matches validated from Neon. For future research updates, use the live export instead of assuming the initial values remain current.
- `render_dashboard.py` renders `research-dashboard.html`, a standalone, accessible research telemetry preview. The page uses a pinned ECharts 6.1.0 CDN enhancement when available and includes a visible static fallback and accessible table for offline/blocked use. No live database access from the browser. **This is a design preview, not deployed to windanvil.com.**
- `test_public_feed.py` exercises seven negative/positive export validation cases.
- `dashboard-preview.png` is a screenshot of the offline fallback captured with headless Chromium.

### Verified operational state, November 1, 2026

- Neon study branch: category aggregate totals `200` inventory, `24` proposed nominations, `15` exact Atlas matches, `0` admitted observations; category breakdown has 10 records.
- Existing main branch remains out of scope. No promotion or public backend role was created.
- Local tests: 7/7 validator tests pass; Chromium fallback path and mocked ECharts enhancement path both pass; neither path reports a JavaScript error. The real CDN-served ECharts script was not downloaded or executed in that headless test environment.

### Publication boundary

A static JSON export is safer than shipping any database credential to a browser. Before actual site deployment, a trusted backend/release job should (1) execute the read-only SQL query, (2) validate the aggregate schema, (3) review it for disclosure, (4) publish the sanitized JSON and static page, and (5) keep the internal study branch and private evidence inaccessible to the website.

## GitHub publication

The files in this directory are a **proposed review change** to the independent WindAnvil Research repository. They do not alter the retired assurance platform. Source code and a reproducible snapshot are public; internal Neon credentials, execution receipts, and any unpublished findings are not included. 
