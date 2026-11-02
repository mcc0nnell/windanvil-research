-- Static-public aggregate views; no raw evidence, researcher identities or database credentials.
BEGIN;
CREATE OR REPLACE VIEW windanvil_study."public_category_summary" AS  SELECT c.category,
    count(*)::integer AS candidates,
    count(*) FILTER (WHERE r.workflow_stage = 'unassessed'::text)::integer AS unassessed,
    count(*) FILTER (WHERE r.workflow_stage = 'screening'::text)::integer AS screening,
    count(*) FILTER (WHERE r.workflow_stage = 'prioritized'::text)::integer AS prioritized,
    count(*) FILTER (WHERE r.workflow_stage = 'assessing'::text)::integer AS assessing,
    count(*) FILTER (WHERE r.workflow_stage = 'completed'::text)::integer AS completed,
    count(*) FILTER (WHERE cm.cohort_id = 'pilot-screening-24-v1'::text)::integer AS proposed_cohort,
    count(*) FILTER (WHERE am.candidate_id IS NOT NULL)::integer AS atlas_matches
   FROM windanvil_study.candidates c
     JOIN windanvil_study.reviews r USING (candidate_id)
     LEFT JOIN windanvil_study.research_cohort_members cm ON cm.candidate_id = c.candidate_id AND cm.cohort_id = 'pilot-screening-24-v1'::text
     LEFT JOIN ( SELECT DISTINCT atlas_exact_repo_matches.candidate_id
           FROM windanvil_study.atlas_exact_repo_matches) am ON am.candidate_id = c.candidate_id
  GROUP BY c.category;
CREATE OR REPLACE VIEW windanvil_study."public_stage_summary" AS  SELECT workflow_stage AS stage,
    count(*)::integer AS candidates
   FROM windanvil_study.reviews r
  GROUP BY workflow_stage;
CREATE OR REPLACE VIEW windanvil_study."public_feed_v1" AS  SELECT jsonb_build_object('schema', 'windanvil.public-research-summary.v1', 'disclosure', 'Research discovery inventory; nominations are provisional; no listed candidate is asserted vulnerable or authorized for testing.', 'snapshot_date', ( SELECT max(imports.snapshot_date)::text AS max
           FROM windanvil_study.imports), 'totals', jsonb_build_object('candidates', ( SELECT count(*)::integer AS count
           FROM windanvil_study.candidates), 'categories', ( SELECT count(*)::integer AS count
           FROM windanvil_study.public_category_summary), 'screening_nominees', ( SELECT count(*)::integer AS count
           FROM windanvil_study.research_cohort_members
          WHERE research_cohort_members.cohort_id = 'pilot-screening-24-v1'::text), 'atlas_exact_matches', ( SELECT count(*)::integer AS count
           FROM windanvil_study.atlas_exact_repo_matches), 'reviewed_observations', ( SELECT count(*)::integer AS count
           FROM windanvil_study.reviewed_pipeline_observations)), 'category_breakdown', COALESCE(( SELECT jsonb_agg(to_jsonb(c.*) ORDER BY c.category) AS jsonb_agg
           FROM windanvil_study.public_category_summary c), '[]'::jsonb), 'stage_breakdown', COALESCE(( SELECT jsonb_agg(to_jsonb(s.*) ORDER BY s.stage) AS jsonb_agg
           FROM windanvil_study.public_stage_summary s), '[]'::jsonb)) AS payload;
COMMIT;
