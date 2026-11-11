#!/usr/bin/env python3
"""Statement coverage; path coverage needs separate signed journey evidence."""
import sys
from pathlib import Path

rows = []
merged = {}
for line in Path(sys.argv[1]).read_text().splitlines()[1:]:
    loc, statements, count = line.split()
    # -coverpkg profiles repeat each block once per test package; keep the max count.
    merged[loc] = (int(statements), max(int(count), merged.get(loc, (0, 0))[1]))
rows = [(loc, n, c) for loc, (n, c) in merged.items()]
assert rows, 'BLOCKED: no instrumented statements'
total = sum(n for _, n, _ in rows)
covered = sum(n for _, n, c in rows if c > 0)
assert total and covered / total >= .70, 'BLOCKED: backend coverage below 70%'
auth = [(l, n, c) for l, n, c in rows if any(s in l.lower() for s in ('auth', 'recovery', 'otp'))]
assert auth and sum(n for _, n, _ in auth), 'BLOCKED: auth/recovery coverage scope missing'
assert all(c > 0 for _, n, c in auth if n), 'BLOCKED: auth/recovery statements below 100%'
print(f'Backend statement coverage {covered / total:.2%}; auth statement coverage 100%')
print('NOT proof of 100% auth paths or no coverage regression; separate release evidence required.')
