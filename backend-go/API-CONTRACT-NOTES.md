# Shared Flutter/backend coordination

`openapi.yaml` is authoritative. These notes clarify integration, not a second spec.

* User IDs and `author_id` are **opaque strings**. Never parse them as integers.
  Item IDs (posts/groups/shops/products/threads/messages) are JSON integers.
  Discovery people return pagination ordinal `id` and actual user ID `author_id`.
* Auth exact DTOs unchanged. OTP is the complete 66-character selector.secret
  emailed capability, never six digits. No SMS. Initial pending signup grants no
  trusted device/session until mailbox capability confirmation.
* PATCH `/users/me` accepts optional nullable string `name` and `bio`: omitted or
  null means unchanged, `""` explicitly clears. Never send missing fields as blanks.
* People following uses PUT/DELETE `/users/{opaque-user-id}/follow`, no body.
  `/items/{numeric-id}/follow` remains an item relation; do not use it for people.
* GET `/users/me/following`, `/notifications`, `/cart` return activity pages
  `{items:[Activity],next_cursor:"..."}` with limit/cursor pagination.
* Activity: numeric `id`, `kind` (follow/share/cart), `read`, `created_at`, optional
  string `actor_id`, string `target_id`, numeric `item_id`, `body`, integer quantity.
  Following `target_id` is the followed user. Cart `item_id` is product ID, `body`
  is product name, quantity is absolute. Notification is generated transactionally
  by first successful follow/share, not on idempotent retries.
* PATCH `/notifications/{numeric-notification-id}/read`, no body ->204, own only.
* POST `/items/{numeric-id}/shares`, no body ->200 Activity, idempotent per user/item;
  public top-level post/shop/group only. Does not fabricate delivery or send messages.
  Client can use OS share sheet separately. Private/group-nested content is denied.
* PUT `/cart/{numeric-product-id}` `{quantity:1..99}` ->204, sets quantity (not delta).
  DELETE same route ->204. Cart is persistent private intent, not checkout/payment.
* Migration 000002 adds notifications/follows/shares/cart. Run migrate up before API.
  migrate down now reverses ALL applied versions (destructive), not just one step.
* Refresh callers MUST serialize. Concurrent valid-token refresh has one winner,
  but competing replay of the consumed token intentionally revokes that session,
  including the winner's access/refresh tokens. Re-authentication is then required.
* `/readyz` checks DB, `/healthz` is liveness. API8080 is default, no server left
  running by backend agent. Native PostgreSQL integration, not testcontainers.

## Source fixture and metadata extension

* Run migration 3 before seeding. Root seed script should default
  `NEXUS_SEED_SQL=backend-go/fixtures/seed.sql` (relative to root). Existing script
  is read-only to this agent; parent must set that default or export this variable.
* Seed requires `owner_id` of an existing verified local demonstration account.
  It changes that account's display name/bio/metadata, never credentials. It deletes
  only that owner's rows explicitly marked with this source fixture before reseed.
* `User.metadata` and `Item.metadata` now return server-owned JSON objects.
  Seed `metadata.card_type`: video, feel, loc, promo, group. Feed remains kind=post.
  `metadata.source_id` p1..p6 is a source label, NOT the resource ID. Use numeric
  `metadata.shop_id` / `metadata.group_id` for links, and numeric Item.id for actions.
* Fixture `display_author`, `direction_display`, counts, distances, relative times,
  ratings, presence and seen labels are SOURCE DISPLAY DATA, not real metrics or
  authentication identities. Item.author_id remains the real demo owner string.
* Profile metadata includes three `discover_people` display records. These have
  no real account IDs and must NOT be used for follow/chat. Live /discover?type=people
  still returns only verified actual users. This is an explicit parity limitation,
  not forged demo accounts with invented phones/emails.
* Products carry exact source prices MMK 2500/3000/4200. Shop metadata includes exact
  contact/hours/reviews. Group metadata includes source member counts/rules.
  HTML has conflicting market Open/Closed labels; fixture retains both explicitly.
* No media binary assets, CSS layout or generated live statistics are seeded. Profile
  grid image data and animation/presence behavior are not backend parity claims.
