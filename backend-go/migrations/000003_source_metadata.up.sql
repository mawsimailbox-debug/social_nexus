ALTER TABLE users ADD COLUMN metadata jsonb NOT NULL DEFAULT '{}'::jsonb CHECK(jsonb_typeof(metadata)='object');
ALTER TABLE items ADD COLUMN metadata jsonb NOT NULL DEFAULT '{}'::jsonb CHECK(jsonb_typeof(metadata)='object');
CREATE UNIQUE INDEX items_fixture_key_idx ON items(author_id,(metadata->>'fixture_key')) WHERE metadata ? 'fixture_key';
