-- WindAnvil research schema, reconstructed from the isolated live Neon study branch.
-- Intentionally separate from retired WindAnvil assurance technology.
-- Requires the existing accessibility_atlas schema and its tables. Run on a dedicated branch.
-- This file does not grant public database privileges or perform scanning.
BEGIN;
CREATE SCHEMA IF NOT EXISTS windanvil_study;
CREATE TABLE IF NOT EXISTS windanvil_study."imports" (
  "import_id" text NOT NULL,
  "filename" text NOT NULL,
  "snapshot_date" date NOT NULL,
  "expected_rows" integer NOT NULL,
  "import_notes" text NOT NULL,
  "imported_at" timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE IF NOT EXISTS windanvil_study."candidates" (
  "candidate_id" integer NOT NULL,
  "project_name" text NOT NULL,
  "category" text NOT NULL,
  "fit" text NOT NULL,
  "repository_url" text NOT NULL,
  "repository_status" text NOT NULL,
  "research_status" text NOT NULL,
  "potential_exposure" text NOT NULL,
  "evidence_needed" text NOT NULL,
  "import_id" text NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE IF NOT EXISTS windanvil_study."reviews" (
  "candidate_id" integer NOT NULL,
  "workflow_stage" text DEFAULT 'unassessed'::text NOT NULL,
  "priority" integer,
  "actual_deployment_confirmed" boolean,
  "affected_version_confirmed" boolean,
  "untrusted_input_path_confirmed" boolean,
  "reachable_interface_confirmed" boolean,
  "downstream_accessibility_impact_confirmed" boolean,
  "testing_authorized" boolean,
  "reviewer" text,
  "reviewed_at" timestamp with time zone,
  "rationale" text
);
CREATE TABLE IF NOT EXISTS windanvil_study."evidence" (
  "evidence_id" bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  "candidate_id" integer NOT NULL,
  "claim_type" text NOT NULL,
  "claim" text NOT NULL,
  "evidence_status" text DEFAULT 'hypothesis'::text NOT NULL,
  "source_url" text,
  "source_revision" text,
  "evidence_collected_at" timestamp with time zone,
  "reviewer" text,
  "notes" text,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE IF NOT EXISTS windanvil_study."research_cohorts" (
  "cohort_id" text NOT NULL,
  "title" text NOT NULL,
  "purpose" text NOT NULL,
  "decision_status" text DEFAULT 'proposed'::text NOT NULL,
  "maintainer_outreach_policy" text NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE IF NOT EXISTS windanvil_study."research_cohort_members" (
  "cohort_id" text NOT NULL,
  "candidate_id" integer NOT NULL,
  "nomination_reason" text NOT NULL,
  "first_evidence_gate" text NOT NULL,
  "nomination_status" text DEFAULT 'proposed'::text NOT NULL,
  "selected_by" text,
  "verified_at" timestamp with time zone
);
CREATE TABLE IF NOT EXISTS windanvil_study."pipeline_runs" (
  "run_id" text NOT NULL,
  "candidate_id" integer NOT NULL,
  "producer" text DEFAULT 'rizzer'::text NOT NULL,
  "target_revision" text NOT NULL,
  "run_uri" text NOT NULL,
  "run_sha256" text,
  "authorization_reference" text,
  "blade_verdict" text,
  "blade_receipt_uri" text,
  "blade_receipt_sha256" text,
  "fcr_comparison_uri" text,
  "human_reviewer" text,
  "human_reviewed_at" timestamp with time zone,
  "state" text DEFAULT 'received'::text NOT NULL,
  "scope_notes" text NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE IF NOT EXISTS windanvil_study."pipeline_observations" (
  "observation_id" bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  "run_id" text NOT NULL,
  "finding_fingerprint" text NOT NULL,
  "observation_kind" text NOT NULL,
  "summary" text NOT NULL,
  "artifact_uri" text,
  "artifact_sha256" text,
  "raw_metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
  "imported_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE windanvil_study."candidates" ADD CONSTRAINT "candidates_candidate_id_check" CHECK (candidate_id > 0);
ALTER TABLE windanvil_study."candidates" ADD CONSTRAINT "candidates_project_name_check" CHECK (length(TRIM(BOTH FROM project_name)) > 0);
ALTER TABLE windanvil_study."candidates" ADD CONSTRAINT "candidates_import_id_fkey" FOREIGN KEY (import_id) REFERENCES windanvil_study.imports(import_id);
ALTER TABLE windanvil_study."candidates" ADD CONSTRAINT "candidates_pkey" PRIMARY KEY (candidate_id);
ALTER TABLE windanvil_study."candidates" ADD CONSTRAINT "candidates_repository_url_key" UNIQUE (repository_url);
ALTER TABLE windanvil_study."evidence" ADD CONSTRAINT "evidence_check" CHECK (evidence_status <> 'verified'::text OR source_url IS NOT NULL AND reviewer IS NOT NULL);
ALTER TABLE windanvil_study."evidence" ADD CONSTRAINT "evidence_evidence_status_check" CHECK (evidence_status = ANY (ARRAY['hypothesis'::text, 'observed'::text, 'verified'::text, 'refuted'::text, 'inconclusive'::text]));
ALTER TABLE windanvil_study."evidence" ADD CONSTRAINT "evidence_candidate_id_fkey" FOREIGN KEY (candidate_id) REFERENCES windanvil_study.candidates(candidate_id);
ALTER TABLE windanvil_study."evidence" ADD CONSTRAINT "evidence_pkey" PRIMARY KEY (evidence_id);
ALTER TABLE windanvil_study."imports" ADD CONSTRAINT "imports_expected_rows_check" CHECK (expected_rows > 0);
ALTER TABLE windanvil_study."imports" ADD CONSTRAINT "imports_pkey" PRIMARY KEY (import_id);
ALTER TABLE windanvil_study."pipeline_observations" ADD CONSTRAINT "pipeline_observations_artifact_sha256_check" CHECK (artifact_sha256 ~ '^[0-9a-f]{64}$'::text);
ALTER TABLE windanvil_study."pipeline_observations" ADD CONSTRAINT "pipeline_observations_observation_kind_check" CHECK (observation_kind = ANY (ARRAY['security_hypothesis'::text, 'functional_behavior'::text, 'accessibility_behavior'::text, 'other'::text]));
ALTER TABLE windanvil_study."pipeline_observations" ADD CONSTRAINT "pipeline_observations_run_id_fkey" FOREIGN KEY (run_id) REFERENCES windanvil_study.pipeline_runs(run_id);
ALTER TABLE windanvil_study."pipeline_observations" ADD CONSTRAINT "pipeline_observations_pkey" PRIMARY KEY (observation_id);
ALTER TABLE windanvil_study."pipeline_observations" ADD CONSTRAINT "pipeline_observations_run_id_finding_fingerprint_key" UNIQUE (run_id, finding_fingerprint);
ALTER TABLE windanvil_study."pipeline_runs" ADD CONSTRAINT "pipeline_runs_blade_receipt_sha256_check" CHECK (blade_receipt_sha256 ~ '^[0-9a-f]{64}$'::text);
ALTER TABLE windanvil_study."pipeline_runs" ADD CONSTRAINT "pipeline_runs_blade_verdict_check" CHECK (blade_verdict = ANY (ARRAY['pass'::text, 'fail'::text, 'inconclusive'::text]));
ALTER TABLE windanvil_study."pipeline_runs" ADD CONSTRAINT "pipeline_runs_check" CHECK (state <> 'admitted'::text OR run_sha256 IS NOT NULL AND authorization_reference IS NOT NULL AND blade_verdict = 'pass'::text AND blade_receipt_uri IS NOT NULL AND blade_receipt_sha256 IS NOT NULL AND human_reviewer IS NOT NULL AND human_reviewed_at IS NOT NULL);
ALTER TABLE windanvil_study."pipeline_runs" ADD CONSTRAINT "pipeline_runs_producer_check" CHECK (producer = 'rizzer'::text);
ALTER TABLE windanvil_study."pipeline_runs" ADD CONSTRAINT "pipeline_runs_run_sha256_check" CHECK (run_sha256 ~ '^[0-9a-f]{64}$'::text);
ALTER TABLE windanvil_study."pipeline_runs" ADD CONSTRAINT "pipeline_runs_state_check" CHECK (state = ANY (ARRAY['received'::text, 'needs_blade_verification'::text, 'needs_human_review'::text, 'admitted'::text, 'rejected'::text]));
ALTER TABLE windanvil_study."pipeline_runs" ADD CONSTRAINT "pipeline_runs_candidate_id_fkey" FOREIGN KEY (candidate_id) REFERENCES windanvil_study.candidates(candidate_id);
ALTER TABLE windanvil_study."pipeline_runs" ADD CONSTRAINT "pipeline_runs_pkey" PRIMARY KEY (run_id);
ALTER TABLE windanvil_study."research_cohort_members" ADD CONSTRAINT "research_cohort_members_check" CHECK (nomination_status <> 'approved'::text OR selected_by IS NOT NULL AND verified_at IS NOT NULL);
ALTER TABLE windanvil_study."research_cohort_members" ADD CONSTRAINT "research_cohort_members_nomination_status_check" CHECK (nomination_status = ANY (ARRAY['proposed'::text, 'screening'::text, 'approved'::text, 'deferred'::text, 'excluded'::text]));
ALTER TABLE windanvil_study."research_cohort_members" ADD CONSTRAINT "research_cohort_members_candidate_id_fkey" FOREIGN KEY (candidate_id) REFERENCES windanvil_study.candidates(candidate_id);
ALTER TABLE windanvil_study."research_cohort_members" ADD CONSTRAINT "research_cohort_members_cohort_id_fkey" FOREIGN KEY (cohort_id) REFERENCES windanvil_study.research_cohorts(cohort_id);
ALTER TABLE windanvil_study."research_cohort_members" ADD CONSTRAINT "research_cohort_members_pkey" PRIMARY KEY (cohort_id, candidate_id);
ALTER TABLE windanvil_study."research_cohorts" ADD CONSTRAINT "research_cohorts_decision_status_check" CHECK (decision_status = ANY (ARRAY['proposed'::text, 'approved'::text, 'completed'::text, 'withdrawn'::text]));
ALTER TABLE windanvil_study."research_cohorts" ADD CONSTRAINT "research_cohorts_pkey" PRIMARY KEY (cohort_id);
ALTER TABLE windanvil_study."reviews" ADD CONSTRAINT "reviews_check" CHECK (workflow_stage <> 'completed'::text OR reviewed_at IS NOT NULL AND reviewer IS NOT NULL);
ALTER TABLE windanvil_study."reviews" ADD CONSTRAINT "reviews_priority_check" CHECK (priority >= 1 AND priority <= 5);
ALTER TABLE windanvil_study."reviews" ADD CONSTRAINT "reviews_workflow_stage_check" CHECK (workflow_stage = ANY (ARRAY['unassessed'::text, 'screening'::text, 'prioritized'::text, 'assessing'::text, 'completed'::text, 'deferred'::text, 'excluded'::text]));
ALTER TABLE windanvil_study."reviews" ADD CONSTRAINT "reviews_candidate_id_fkey" FOREIGN KEY (candidate_id) REFERENCES windanvil_study.candidates(candidate_id);
ALTER TABLE windanvil_study."reviews" ADD CONSTRAINT "reviews_pkey" PRIMARY KEY (candidate_id);
CREATE INDEX IF NOT EXISTS candidates_category_idx ON windanvil_study.candidates USING btree (category);
CREATE INDEX IF NOT EXISTS evidence_candidate_status_idx ON windanvil_study.evidence USING btree (candidate_id, evidence_status);
CREATE INDEX IF NOT EXISTS study_observations_run_idx ON windanvil_study.pipeline_observations USING btree (run_id);
CREATE INDEX IF NOT EXISTS study_runs_candidate_state_idx ON windanvil_study.pipeline_runs USING btree (candidate_id, state);
CREATE INDEX IF NOT EXISTS study_cohort_members_candidate_idx ON windanvil_study.research_cohort_members USING btree (candidate_id);
CREATE INDEX IF NOT EXISTS reviews_stage_priority_idx ON windanvil_study.reviews USING btree (workflow_stage, priority);
CREATE OR REPLACE VIEW windanvil_study."atlas_exact_repo_matches" AS  SELECT c.candidate_id,
    c.project_name,
    c.repository_url,
    a.id AS atlas_entity_id,
    a.name AS atlas_entity_name,
    a.payload ->> 'claimClass'::text AS atlas_claim_class,
    a.payload ->> 'limitations'::text AS atlas_limitations
   FROM windanvil_study.candidates c
     JOIN accessibility_atlas.entities a ON lower(TRIM(TRAILING '/'::text FROM (a.payload -> 'identity'::text) ->> 'canonicalUrl'::text)) = lower(TRIM(TRAILING '/'::text FROM c.repository_url));
CREATE OR REPLACE VIEW windanvil_study."atlas_documented_context" AS  SELECT m.candidate_id,
    m.project_name,
    m.atlas_entity_id,
    r.id AS relationship_id,
    r.source_id,
    r.target_id,
    r.relation_type,
    r.claim_class,
    r.payload ->> 'proof'::text AS documented_claim,
    r.payload ->> 'url'::text AS documented_source_url,
    r.payload ->> 'limitations'::text AS limitations
   FROM windanvil_study.atlas_exact_repo_matches m
     JOIN accessibility_atlas.relationships r ON m.atlas_entity_id = r.source_id OR m.atlas_entity_id = r.target_id
  WHERE r.claim_class = 'documented'::text;
CREATE OR REPLACE VIEW windanvil_study."reviewed_pipeline_observations" AS  SELECT r.candidate_id,
    r.run_id,
    r.target_revision,
    r.run_uri,
    r.run_sha256,
    r.blade_receipt_uri,
    r.blade_receipt_sha256,
    r.human_reviewer,
    r.human_reviewed_at,
    o.observation_id,
    o.finding_fingerprint,
    o.observation_kind,
    o.summary,
    o.artifact_uri,
    o.artifact_sha256
   FROM windanvil_study.pipeline_runs r
     JOIN windanvil_study.pipeline_observations o USING (run_id)
  WHERE r.state = 'admitted'::text AND r.blade_verdict = 'pass'::text AND r.human_reviewer IS NOT NULL;
CREATE OR REPLACE VIEW windanvil_study."category_progress" AS  SELECT c.category,
    count(*)::integer AS candidates,
    count(*) FILTER (WHERE r.workflow_stage = 'unassessed'::text)::integer AS unassessed,
    count(*) FILTER (WHERE r.workflow_stage = 'prioritized'::text)::integer AS prioritized,
    count(*) FILTER (WHERE r.workflow_stage = 'completed'::text)::integer AS completed
   FROM windanvil_study.candidates c
     JOIN windanvil_study.reviews r USING (candidate_id)
  GROUP BY c.category;
CREATE OR REPLACE VIEW windanvil_study."research_queue" AS  SELECT c.candidate_id,
    c.project_name,
    c.category,
    c.repository_url,
    c.fit,
    r.workflow_stage,
    r.priority,
    r.testing_authorized,
    ( SELECT count(*)::integer AS count
           FROM windanvil_study.evidence e
          WHERE e.candidate_id = c.candidate_id AND e.evidence_status = 'verified'::text) AS verified_evidence_count
   FROM windanvil_study.candidates c
     JOIN windanvil_study.reviews r USING (candidate_id)
  WHERE r.workflow_stage <> ALL (ARRAY['excluded'::text, 'completed'::text]);
CREATE OR REPLACE VIEW windanvil_study."cohort_queue" AS  SELECT cm.cohort_id,
    c.candidate_id,
    c.project_name,
    c.category,
    c.fit,
    c.repository_url,
    cm.nomination_status,
    cm.nomination_reason,
    cm.first_evidence_gate,
    (EXISTS ( SELECT 1
           FROM windanvil_study.atlas_exact_repo_matches m
          WHERE m.candidate_id = c.candidate_id)) AS has_atlas_documentation,
    ( SELECT count(*)::integer AS count
           FROM windanvil_study.reviewed_pipeline_observations o
          WHERE o.candidate_id = c.candidate_id) AS reviewed_observation_count
   FROM windanvil_study.research_cohort_members cm
     JOIN windanvil_study.candidates c USING (candidate_id);
CREATE OR REPLACE VIEW windanvil_study."study_summary" AS  SELECT ( SELECT count(*)::integer AS count
           FROM windanvil_study.candidates) AS candidates,
    ( SELECT count(*)::integer AS count
           FROM windanvil_study.research_cohort_members
          WHERE research_cohort_members.cohort_id = 'pilot-screening-24-v1'::text) AS proposed_screening_cohort,
    ( SELECT count(*)::integer AS count
           FROM windanvil_study.atlas_exact_repo_matches) AS atlas_exact_matches,
    ( SELECT count(*)::integer AS count
           FROM windanvil_study.atlas_documented_context) AS atlas_documented_relationships,
    ( SELECT count(*)::integer AS count
           FROM windanvil_study.pipeline_runs) AS pipeline_runs,
    ( SELECT count(*)::integer AS count
           FROM windanvil_study.reviewed_pipeline_observations) AS admitted_observations,
    ( SELECT count(*)::integer AS count
           FROM windanvil_study.evidence
          WHERE evidence.evidence_status = 'verified'::text) AS verified_manually_reviewed_evidence;
COMMIT;
