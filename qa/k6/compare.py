#!/usr/bin/env python3
import json
import sys
from pathlib import Path

baseline, candidate = (json.loads(Path(p).read_text()) for p in sys.argv[1:3])
b = baseline['metrics']['nexus_target_latency']['values']['p(95)']
c = candidate['metrics']['nexus_target_latency']['values']['p(95)']
assert b > 0 and c > 0, 'Invalid timing samples'
assert c <= b * 1.2, f'BLOCKED: p95 regression {(c/b-1):.1%} exceeds20%'
print(f'p95 baseline={b}ms candidate={c}ms; regression={(c/b-1):.1%}')
print('Environment equivalence and actual achieved RPS still require evidence.')
