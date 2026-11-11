"""Independent source, asset, widget size and contract checks."""
from pathlib import Path
import hashlib
import json
import yaml

root=Path(__file__).resolve().parents[1]
manifest=json.loads((root/'docs/source-manifest.json').read_text())
for name,key in [('social-suite-v3.html','html_sha256'),('nexus-guide.docx','guide_sha256')]:
    assert hashlib.sha256((root.parents[1]/name).read_bytes()).hexdigest()==manifest[key],name+' changed'
assert hashlib.sha256((root/'assets/baseline.jpg').read_bytes()).hexdigest()==manifest['photo_sha256']
sizes={}
for folder in ['screens','widgets']:
    for path in (root/'lib/presentation'/folder).glob('*.dart'):
        lines=len(path.read_text().splitlines())
        sizes[str(path.relative_to(root))]=lines
        assert lines<=200,f'{path.name}: {lines} > 200'
spec=yaml.safe_load((root/'docs/openapi.yaml').read_text())
def visit(value):
    if isinstance(value,dict):
        if '$ref' in value:
            cursor=spec
            for item in value['$ref'][2:].split('/'):cursor=cursor[item]
        for v in value.values():visit(v)
    elif isinstance(value,list):
        for v in value:visit(v)
visit(spec)
coverage=(root/'coverage/lcov.info').read_text()
hits=total=0
for line in coverage.splitlines():
    if line.startswith('DA:'):
        total+=1
        hits+=int(int(line.split(',')[1])>0)
result={'source_hashes_unchanged':True,'photo_hash_unchanged':True,
    'all_widget_files_at_most_200_lines':True,'widget_files':sizes,
    'openapi_internal_refs_valid':True,'openapi_paths':len(spec['paths']),
    'coverage_all_reported_files':{'hit':hits,'total':total,'percent':round(100*hits/total,2)}}
(root/'docs/integrity-results.json').write_text(json.dumps(result,indent=2))
print(json.dumps(result,indent=2))
