CREATE TABLE user_follows (
 id bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 follower_id text NOT NULL REFERENCES users ON DELETE CASCADE,
 followed_id text NOT NULL REFERENCES users ON DELETE CASCADE,
 created_at timestamptz NOT NULL DEFAULT now(),
 PRIMARY KEY(follower_id,followed_id),
 CHECK(follower_id<>followed_id)
);
CREATE TABLE notifications (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 user_id text NOT NULL REFERENCES users ON DELETE CASCADE,
 actor_id text NOT NULL REFERENCES users ON DELETE CASCADE,
 kind text NOT NULL CHECK(kind IN ('follow','share')),
 item_id bigint REFERENCES items ON DELETE CASCADE,
 read boolean NOT NULL DEFAULT false,
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX notifications_user_idx ON notifications(user_id,id DESC);
CREATE TABLE shares (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 user_id text NOT NULL REFERENCES users ON DELETE CASCADE,
 item_id bigint NOT NULL REFERENCES items ON DELETE CASCADE,
 created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(user_id,item_id)
);
CREATE TABLE cart_entries (
 id bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 user_id text NOT NULL REFERENCES users ON DELETE CASCADE,
 product_id bigint NOT NULL REFERENCES items ON DELETE CASCADE,
 quantity integer NOT NULL CHECK(quantity BETWEEN 1 AND 99),
 created_at timestamptz NOT NULL DEFAULT now(),
 PRIMARY KEY(user_id,product_id)
);
