CREATE TABLE users (
 id text PRIMARY KEY,
 ordinal bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 phone_hash text NOT NULL UNIQUE,
 email_hash text NOT NULL UNIQUE,
 phone_cipher bytea NOT NULL,
 email_cipher bytea NOT NULL,
 device_hash text NOT NULL,
 email_verified boolean NOT NULL DEFAULT false,
 name text NOT NULL DEFAULT '',
 bio text NOT NULL DEFAULT '',
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE challenges (
 selector text PRIMARY KEY,
 code_hash text NOT NULL,
 user_id text NOT NULL REFERENCES users ON DELETE CASCADE,
 expires_at timestamptz NOT NULL,
 attempts integer NOT NULL DEFAULT 0 CHECK(attempts >= 0),
 used boolean NOT NULL DEFAULT false
);
CREATE INDEX challenges_user_idx ON challenges(user_id);
CREATE TABLE sessions (
 id text PRIMARY KEY,
 user_id text NOT NULL REFERENCES users ON DELETE CASCADE,
 refresh_hash text NOT NULL,
 previous_hash text NOT NULL DEFAULT '',
 expires_at timestamptz NOT NULL,
 revoked boolean NOT NULL DEFAULT false
);
CREATE INDEX sessions_user_idx ON sessions(user_id);
CREATE TABLE rate_limits (
 key text PRIMARY KEY,
 count integer NOT NULL,
 reset_at timestamptz NOT NULL
);
CREATE INDEX rate_limits_reset_idx ON rate_limits(reset_at);
CREATE TABLE items (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 kind text NOT NULL CHECK(kind IN ('post','comment','shop','product','group','thread','message')),
 author_id text NOT NULL REFERENCES users ON DELETE CASCADE,
 parent_id bigint REFERENCES items ON DELETE CASCADE,
 name text NOT NULL DEFAULT '',
 body text NOT NULL DEFAULT '',
 visibility text NOT NULL DEFAULT 'public' CHECK(visibility IN ('public','private')),
 price_minor bigint NOT NULL DEFAULT 0 CHECK(price_minor >= 0),
 currency text NOT NULL DEFAULT '',
 created_at timestamptz NOT NULL DEFAULT now(),
 CHECK(length(name) <= 120), CHECK(length(body) <= 5000)
);
CREATE INDEX items_kind_id_idx ON items(kind,id DESC);
CREATE INDEX items_parent_idx ON items(parent_id,id DESC);
CREATE TABLE memberships (
 item_id bigint NOT NULL REFERENCES items ON DELETE CASCADE,
 user_id text NOT NULL REFERENCES users ON DELETE CASCADE,
 PRIMARY KEY(item_id,user_id)
);
CREATE INDEX memberships_user_idx ON memberships(user_id,item_id);
CREATE TABLE relations (
 item_id bigint NOT NULL REFERENCES items ON DELETE CASCADE,
 user_id text NOT NULL REFERENCES users ON DELETE CASCADE,
 kind text NOT NULL CHECK(kind IN ('like','save','follow')),
 PRIMARY KEY(item_id,user_id,kind)
);
