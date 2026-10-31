"""Read-only, offline candidate structure validator. Does not verify findings."""
import json
import sys
from datetime import datetime
from urllib.parse import urlsplit

REQUIRED = {"id","repository","accessibility_function","source","observed_at","status"}
OPTIONAL = {"version_evidence","consumer_evidence","reachability_evidence","consequence_evidence"}

def check(record):
    if not isinstance(record,dict):
        return ["Expected object"]
    errors = ["Missing "+x for x in sorted(REQUIRED-set(record))]
    errors += ["Unsupported field "+x for x in sorted(set(record)-REQUIRED-OPTIONAL)]
    for key in ("id","accessibility_function"):
        v=record.get(key)
        if not isinstance(v,str) or len(v.strip())<3:
            errors.append(key+" too short")
    for key in ("repository","source"):
        v=record.get(key)
        url=urlsplit(v) if isinstance(v,str) else None
        if not url or url.scheme!="https" or not url.hostname or url.username:
            errors.append(key+" must be an HTTPS URL")
    if record.get("status")!="candidate":
        errors.append("Only unverified candidate records are accepted")
    try:
        val=record.get("observed_at")
        if not isinstance(val,str):
            raise ValueError()
        d=datetime.fromisoformat(val.replace("Z","+00:00"))
        if not d.tzinfo:
            raise ValueError()
    except ValueError:
        errors.append("observed_at requires an ISO 8601 time with timezone")
    for key in OPTIONAL:
        if key in record and record[key] is not None and not isinstance(record[key],str):
            errors.append(key+" must be text or null")
    return errors

def main(path):
    with open(path,encoding="utf-8") as f:
        records=json.load(f)
    if not isinstance(records,list):
        raise ValueError("Expected a JSON array")
    errors=[]
    seen=set()
    for i,r in enumerate(records):
        errors.extend(f"Record {i+1}: {s}" for s in check(r))
        if isinstance(r,dict) and isinstance(r.get("id"),str):
            if r["id"] in seen:
                errors.append(f"Record {i+1}: duplicate ID")
            seen.add(r["id"])
    if errors:
        print("\n".join(errors),file=sys.stderr)
        return 1
    print(f"{len(records)} structurally valid candidates; no security findings asserted")
    return 0

if __name__=="__main__":
    if len(sys.argv)!=2:
        raise SystemExit("Usage: python3 tools/validate_candidates.py <file.json>")
    raise SystemExit(main(sys.argv[1]))
