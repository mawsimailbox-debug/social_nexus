#!/usr/bin/env python3
"""One-way, deterministic extraction; never modifies the design source."""
import hashlib
import json
import re
import sys
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NAME = 'Social Suite v3 — Business & Community.html'
MD5 = 'a8fafd493261eda3876d79039c564e10'


class Extract(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.records, self.stack, self.skip = [], [], 0

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag in ('script', 'style'):
            self.skip += 1
        if not self.skip:
            if a.get('id') or any(k.startswith('data-') for k in a):
                self.records.append({'tag': tag, 'attributes': a})

    def handle_endtag(self, tag):
        if tag in ('script', 'style'):
            self.skip -= 1


def main():
    source = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / 'design' / NAME
    raw = source.read_bytes()
    if hashlib.md5(raw).hexdigest() != MD5:
        raise SystemExit('BLOCKED: source HTML MD5 mismatch')
    design = ROOT / 'design'
    design.mkdir(exist_ok=True)
    (design / NAME).write_bytes(raw)
    # Exact bytes from colon through closing brace, including embedded --photo.
    tokens = re.search(rb':root\s*\{.*?\}', raw, re.S).group(0)
    (design / 'tokens.css').write_bytes(tokens)
    for name in ('MD5.txt', 'HTML-MD5.txt'):
        (design / name).write_text(MD5 + '\n')
    parser = Extract()
    text = raw.decode('utf-8')
    parser.feed(text)
    # Full section fragments preserve all text, prices, labels, classes and metadata.
    screens = {m[0]: m[1] for m in re.findall(
        r'<section[^>]+id="([^"]+)"[^>]*>(.*?)</section>', text, re.S)}
    fixtures = {'source_md5': MD5, 'source_sha256': hashlib.sha256(raw).hexdigest(),
                'kind': 'prototype-only; not production identities or factual business data',
                'screens': screens, 'interaction_elements': parser.records,
                'script_source': re.search(r'<script>(.*?)</script>', text, re.S).group(1)}
    dest = ROOT / 'qa' / 'fixtures'
    dest.mkdir(parents=True, exist_ok=True)
    (dest / 'source-v3.json').write_text(json.dumps(fixtures, ensure_ascii=False, indent=2) + '\n')
    print(f'Extracted {len(screens)} screens and {len(parser.records)} interaction/ID elements; MD5={MD5}')


if __name__ == '__main__':
    main()
