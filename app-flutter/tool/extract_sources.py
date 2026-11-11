"""Read-only source extraction. Never rewrites the baseline or guide."""
import base64
import hashlib
import json
import re
from pathlib import Path
from bs4 import BeautifulSoup
from docx import Document

root = Path(__file__).resolve().parents[1]
source = root.parents[1] / 'social-suite-v3.html'
guide = root.parents[1] / 'nexus-guide.docx'
raw = source.read_bytes()
soup = BeautifulSoup(raw, 'html.parser')
def text(node, selector=None):
    element = node.select_one(selector) if selector else node
    return element.get_text(' ', strip=True) if element else ''
def many(selector):
    return [text(n) for n in soup.select(selector)]
def count(node, selector):
    value = text(node, selector).replace(',', '').upper()
    return int(float(value[:-1]) * 1000) if value.endswith('K') else int(value or 0)

photo = base64.b64decode(re.search(r'data:image/jpeg;base64,([^"\)]+)', raw.decode()).group(1))
(root / 'assets').mkdir(exist_ok=True)
(root / 'docs').mkdir(exist_ok=True)
(root / 'assets/baseline.jpg').write_bytes(photo)
posts = []
for n in soup.select('article.post'):
    posts.append(dict(id=n['data-id'], kind=n['class'][-1], score=int(n['data-score']),
        nearby=n['data-nearby']=='1', friend=n['data-friend']=='1',
        reason=n['data-reason'].replace('<b>', '').replace('</b>', ''),
        title=text(n,'.title') or text(n,'.promo-tag') or text(n,'.grpc .t') or text(n,'.mood'),
        body=text(n,'.quote') or text(n,'.cap') or text(n,'.grpc .s'),
        author=text(n,'.who') or text(n,'.name') or ('Shwe Kyaung Coffee' if n['data-id']=='p5' else 'Kyaw Zin'),
        subtitle=text(n,'.feel-author .sub'), location=text(n,'.top-tag .loc-pill').replace('place','').replace('near_me','').strip(),
        likes=count(n,'.rc') if n.select_one('.rc') else (12400 if n['data-id']=='p1' else 0),
        comments=count(n,'.cc') if n.select_one('.cc') else (1208 if n['data-id']=='p1' else 0),
        shares=count(n,'.sc'), tags=text(n,'.tags'), music=text(n,'.music').replace('music_note','').strip()))
entries = []
for index,n in enumerate(soup.select('.ds-card')):
    entries.append(dict(id=f'd{index}', category=n['data-tab'], subtype=n.get('data-btype',''),
        title=text(n,'.t').replace('check','').strip(), subtitle=text(n,'.s'),
        icon=text(n,'.thumb'), selected='on' in n.select_one('button').get('class',[]),
        target=n.get('data-go',''), action=text(n,'button')))
products = [dict(id=f'product{i}', title=text(n,'.nm'), subtitle=text(n,'.sub'), price=text(n,'.amt'))
    for i,n in enumerate(soup.select('.price-row'))]
notifications=[dict(id=f'n{i}', title=text(n,'.tx'), subtitle=text(n,'.mt'), category=n['data-np'], unread='unread' in n['class'])
    for i,n in enumerate(soup.select('.np'))]
messages=[dict(id=f'm{i}', body=text(n), outgoing='out' in n['class']) for i,n in enumerate(soup.select('.bubble'))]
fixtures=dict(feed=posts,discover=entries,products=products,notifications=notifications,messages=messages,
    profile=dict(id='me',title=many('.p-name')[0], handle=many('.p-handle')[0],bio=many('.bio')[0],stats=many('.stats span')),
    shop=dict(id='shwe-kyaung',title='Shwe Kyaung Coffee',subtitle=text(soup,'.biz-head'),contact=[dict(title=text(n,'.l1'),subtitle=text(n,'.l2')) for n in soup.select('.info-row')],
        reviews=[dict(title=text(n,'.who'),body=text(n,'.txt'),subtitle=text(n,'.stars')) for n in soup.select('.rev')]),
    group=dict(id='inya-runners', title=text(soup,'.grp-name'),subtitle=text(soup,'.grp-meta'),body=text(soup,'.about'),rules=many('.rules li'),recent=[dict(title=text(n,'.t'),subtitle=text(n,'.s')) for n in soup.select('.feed-row')]),
    comments=[dict(id='c0',title='Ko Min',body='This is exactly what I needed to read today.',subtitle='4 min'),dict(id='c1',title='Thiri Aung',body='Come sit by the lake with me next time.',subtitle='2 min')],
    tokens=dict(re.findall(r'--([\w-]+):([^;\n]+);',raw.decode().split('--photo:')[0])),
    screen_text={n['id']:text(n) for n in soup.select('section.screen')})
(root/'assets/fixtures.json').write_text(json.dumps(fixtures,indent=2,ensure_ascii=False))
d=Document(guide)
extraction='\n'.join(p.text for p in d.paragraphs)+'\n'+'\n'.join(' | '.join(c.text for c in r.cells) for t in d.tables for r in t.rows)
(root/'docs/guide-extracted.txt').write_text(extraction)
manifest=dict(html_sha256=hashlib.sha256(raw).hexdigest(),guide_sha256=hashlib.sha256(guide.read_bytes()).hexdigest(),photo_sha256=hashlib.sha256(photo).hexdigest(),posts=len(posts),discover_entries=len(entries),guide_characters=len(extraction),sdk='3.47.9',sdk_release='2026-10-29',sdk_archive_sha256='25ed8c3c29d51a7353f2a944310b478af8214920639524b19c50a19e6c044c5a')
(root/'docs/source-manifest.json').write_text(json.dumps(manifest,indent=2))
print(json.dumps(manifest,indent=2))
