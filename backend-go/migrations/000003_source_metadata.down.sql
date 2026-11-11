DROP INDEX IF EXISTS items_fixture_key_idx;
ALTER TABLE items DROP COLUMN metadata;
ALTER TABLE users DROP COLUMN metadata;
