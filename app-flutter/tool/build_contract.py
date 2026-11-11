"""Snapshot the authoritative Go contract without modifying backend files."""
import hashlib
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
source=root.parent/'backend-go/openapi.yaml'
raw=source.read_bytes()
(root/'docs/openapi.yaml').write_bytes(raw)
(root/'docs/contract-provenance.json').write_text(json.dumps({
    'source':'backend-go/openapi.yaml','sha256':hashlib.sha256(raw).hexdigest(),
    'status':'Read-only snapshot; refresh after Go changes. Runtime integration not verified.'},indent=2))
print('Copied authoritative Go contract; SHA-256',hashlib.sha256(raw).hexdigest())
