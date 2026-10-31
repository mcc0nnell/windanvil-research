import sys
import unittest
from pathlib import Path

sys.path.insert(0,str(Path(__file__).resolve().parents[1]/"tools"))
from validate_candidates import check

class CandidateTests(unittest.TestCase):
    def setUp(self):
        self.c={"id":"abc","repository":"https://example.org/repo","accessibility_function":"Illustrative captions","source":"https://example.org/source","observed_at":"2026-10-31T00:00:00Z","status":"candidate"}
    def test_candidate(self):
        self.c["reachability_evidence"]=None
        self.assertEqual(check(self.c),[])
    def test_must_not_promote_finding(self):
        self.c["status"]="vulnerable"
        self.assertTrue(check(self.c))
    def test_no_unattributed_record(self):
        self.c.pop("source")
        self.assertTrue(check(self.c))
    def test_https(self):
        self.c["repository"]="http://example.org"
        self.assertTrue(check(self.c))
