#!/usr/bin/env python3
"""Full ordered paragraph/table extraction with python-docx; source remains intact."""
from docx import Document
from docx.table import Table
from docx.text.paragraph import Paragraph
from pathlib import Path

root = Path(__file__).resolve().parents[1]
source = root.parent / 'nexus-guide.docx'
doc = Document(source)
out = ['# Supplied guide extraction', '', 'Source: nexus-guide.docx; extracted via python-docx.',
       'This is source text, not release acceptance or proof of implementation.', '']
paragraphs = tables = 0
for element in doc.element.body.iterchildren():
    if element.tag.endswith('}p'):
        p = Paragraph(element, doc)
        out.extend([p.text, ''])
        paragraphs += 1
    elif element.tag.endswith('}tbl'):
        table = Table(element, doc)
        for i, row in enumerate(table.rows):
            out.append('| ' + ' | '.join(c.text.replace('\n', '<br>').replace('|', '\\|') for c in row.cells) + ' |')
            if i == 0:
                out.append('| ' + ' | '.join('---' for _ in row.cells) + ' |')
        out.append('')
        tables += 1
(root / 'docs/SOURCE_GUIDE.md').write_text('\n'.join(out) + '\n')
print(f'Extracted all {paragraphs} paragraphs and {tables} tables in source order')
