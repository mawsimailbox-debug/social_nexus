# Source fixtures

source-v3.json is deterministic extraction, not invented demo content. It contains
all6 section fragments,183 ID/data interaction elements and the complete JS,
including script seed comments/profile grids/chat replies. Embedded photo is in
the unchanged HTML and exact root token file. These are prototype-only values:
do not call, send email to, sell to or represent these identities as real users.

Backend owner must transform this fixture into reviewed schema-compatible seed.sql
using their actual schema. scripts/seed.sh requires that adapter and explicit
local-test opt-in; it does not pretend arbitrary SQL can be inferred safely.
Cross-client mock/live adapters must share backend OpenAPI DTO interfaces.
