-- SOURCE: social-suite-v3.html. Opt-in local demonstration, NOT live facts.
-- psql -X -v ON_ERROR_STOP=1 -v owner_id='<existing verified demo user ID>' -f fixtures/seed.sql
-- Run all three migrations first. Re-running replaces only this owner's fixture rows.
BEGIN;
CREATE TEMP TABLE fixture_owner(id text PRIMARY KEY) ON COMMIT DROP;
INSERT INTO fixture_owner SELECT id FROM users WHERE id=:'owner_id' AND email_verified;
DO $$ BEGIN IF NOT EXISTS(SELECT 1 FROM fixture_owner) THEN RAISE EXCEPTION 'existing verified demonstration owner required'; END IF; END $$;
DELETE FROM items WHERE author_id=(SELECT id FROM fixture_owner) AND metadata->>'fixture_source'='social-suite-v3.html';
UPDATE users SET name='Sophie Jap',bio=E'Editorial & travel films. Iceland, mostly.\nShooting with natural light since 2019.',metadata='{"fixture_source":"social-suite-v3.html","handle":"@sophie.jap","following_display":"128","followers_display":"8.4K","likes_display":"96.2K","tabs":["Videos","Liked","Saved"]}'::jsonb WHERE id=(SELECT id FROM fixture_owner);
-- All design people are display metadata, not forged authentication principals.
INSERT INTO items(kind,author_id,name,body,metadata) SELECT 'shop',id,'Shwe Kyaung Coffee','Cafe & tea shop',
'{"fixture_source":"social-suite-v3.html","fixture_key":"shop-coffee","verified_display":true,"category":"cafe","open_display":"Open","closes_display":"21:00","rating_display":"4.8","reviews_display":"216","distance_display":"800 m","followers_display":"1.2k","phone_display":"+95 9 771 234 567","address":"24 Inya Road, Bahan, Yangon","hours":"Mon – Sun · 07:00 – 21:00","kitchen_hours":"kitchen closes 20:30","reply_display":"replies within 10 min","reviews":[{"who":"Thiri Aung","stars":5,"text":"Quiet corner, good light and the mohinga is worth waking up for."},{"who":"Kyaw Zin","stars":4,"text":"Fast service before 9am. Ask for the corner table by the window."}],"posts_this_week_display":"3 posts this week"}'::jsonb FROM fixture_owner;
INSERT INTO items(kind,author_id,parent_id,name,body,price_minor,currency,metadata)
SELECT 'product',o.id,s.id,v.name,v.body,v.price,'MMK',jsonb_build_object('fixture_source','social-suite-v3.html','fixture_key',v.key)
FROM fixture_owner o JOIN items s ON s.author_id=o.id AND s.metadata->>'fixture_key'='shop-coffee'
CROSS JOIN (VALUES('product-mohinga','Mohinga','Breakfast · until 11:00',2500),('product-laphet','Laphet thoke','Tea leaf salad · mild',3000),('product-latte','Iced latte','House blend · 20% off before 10:00',4200))v(key,name,body,price);
INSERT INTO items(kind,author_id,name,body,visibility,metadata) SELECT 'group',o.id,v.name,v.body,v.visibility,
jsonb_build_object('fixture_source','social-suite-v3.html','fixture_key',v.key,'members_display',v.members,'distance_display',v.distance,'rules',v.rules::jsonb)
FROM fixture_owner o CROSS JOIN (VALUES
('group-runners','Inya Lake Runners','We run 5 km around the lake every Saturday at 6am. All paces welcome — walkers, first-timers and people who just want coffee afterwards.','public','1.4k','2 km','["Show up, or tell us you can''t — no silent no-shows.","Keep photos of members inside the group.","No selling. Recommendations are fine, ads are not."]'),
('group-film','Yangon Film Photographers','','public','8.2k','3.1 km','[]'),
('group-cooks','Home Cooks of Yangon','','private','3.1k','1.8 km','[]'))v(key,name,body,visibility,members,distance,rules);
INSERT INTO memberships(item_id,user_id) SELECT i.id,o.id FROM fixture_owner o JOIN items i ON i.author_id=o.id WHERE i.kind='group' AND i.metadata->>'fixture_source'='social-suite-v3.html';
INSERT INTO items(kind,author_id,parent_id,body,metadata) SELECT 'post',o.id,g.id,v.body,
jsonb_build_object('fixture_source','social-suite-v3.html','fixture_key',v.key,'display_author',v.who,'time_display',v.time)
FROM fixture_owner o JOIN items g ON g.author_id=o.id AND g.metadata->>'fixture_key'='group-runners'
CROSS JOIN (VALUES('group-route','Thiri Aung','2h','Saturday route is 5.2 km this week — meet at the north gate, 5:45am.'),('group-photos','Nang Seng','5h','Photos from last week are up. Tag yourself if you want.'))v(key,who,time,body);
-- Six distinct feed card types. Metrics/reasons/relative times are source display fixtures.
INSERT INTO items(kind,author_id,name,body,metadata) SELECT 'post',o.id,v.name,v.body,v.metadata::jsonb||jsonb_build_object('fixture_source','social-suite-v3.html','fixture_key',v.key)
FROM fixture_owner o CROSS JOIN (VALUES
('feed-p1','','Editorial video — shot by the lake at golden hour. No filter, just light.','{"card_type":"video","source_id":"p1","display_author":"@sophie.jap","location_display":"Ngwe Saung · Coast","reason":"Because you follow @sophie.jap","tags":["#editorial","#suits","#casual"],"music":"Hozier — Too Sweet","likes_display":"12.4K","comments_display":"1,208","saves_display":"8,342","score":62,"nearby":false,"friend":true}'),
('feed-p2','','Some evenings I just sit by the lake and let the day go. Nothing big happened today — and that felt like enough.','{"card_type":"feel","source_id":"p2","display_author":"Thiri Aung","handle":"@thiri.aung","mood":"GRATEFUL","location_display":"Inya Lake","distance_display":"1.2 km","time_display":"12 min","reason":"Because you reacted to @thiri.aung 3 times this week","likes_display":"892","comments_display":"42","shares_display":"18","score":92,"nearby":true,"friend":true}'),
('feed-p3','Sunset at Inya Lake','5 min walk from my place. Best light around 5:40pm — bring a jacket.','{"card_type":"loc","source_id":"p3","reason":"Popular with people near Inya Lake","distance_display":"800 m","relationship_display":"Following","likes_display":"431","comments_display":"27","shares_display":"11","score":74,"nearby":true,"friend":true}'),
('feed-p4','','Missing home today. Anyone else living far from family? Even a voice note would be enough.','{"card_type":"feel","source_id":"p4","display_author":"Nang Seng","handle":"@nang.seng","mood":"MISSING HOME","location_display":"Hledan","distance_display":"2.4 km","time_display":"40 min","reason":"Because @nang.seng follows you","likes_display":"1,204","comments_display":"88","shares_display":"64","score":51,"nearby":true,"friend":true}'),
('feed-p5','Shwe Kyaung Coffee','Mohinga, laphet thoke and slow-brewed coffee. 4.8 ★ from 216 neighbours.','{"card_type":"promo","source_id":"p5","reason":"Business near you · Shwe Kyaung Coffee","offer":"20% OFF BEFORE 10 AM","distance_display":"800 m","open_display":"Open now","likes_display":"318","comments_display":"19","shares_display":"42","score":70,"nearby":true,"friend":false}'),
('feed-p6','Inya Lake Runners','Weekly 6am runs around the lake','{"card_type":"group","source_id":"p6","reason":"A group 1.4k people near you joined","members_display":"1.4k","visibility_display":"Public","distance_display":"2 km","likes_display":"156","shares_display":"9","score":40,"nearby":true,"friend":false}'))v(key,name,body,metadata);
-- Resolve numeric resource links rather than exposing string fixture keys as IDs.
UPDATE items p SET metadata=p.metadata||jsonb_build_object('shop_id',s.id) FROM items s,fixture_owner o WHERE p.author_id=o.id AND s.author_id=o.id AND p.metadata->>'fixture_key'='feed-p5' AND s.metadata->>'fixture_key'='shop-coffee';
UPDATE items p SET metadata=p.metadata||jsonb_build_object('group_id',g.id) FROM items g,fixture_owner o WHERE p.author_id=o.id AND g.author_id=o.id AND p.metadata->>'fixture_key'='feed-p6' AND g.metadata->>'fixture_key'='group-runners';
INSERT INTO items(kind,author_id,parent_id,body,metadata) SELECT 'comment',o.id,p.id,v.body,jsonb_build_object('fixture_source','social-suite-v3.html','fixture_key',v.key,'display_author',v.who,'initials',v.initials,'time_display',v.time)
FROM fixture_owner o JOIN items p ON p.author_id=o.id AND p.metadata->>'fixture_key'='feed-p2'
CROSS JOIN (VALUES('comment-ko-min','Ko Min','KM','4 min','This is exactly what I needed to read today.'),('comment-thiri','Thiri Aung','TA','2 min','Come sit by the lake with me next time.'))v(key,who,initials,time,body);
INSERT INTO items(kind,author_id,name,visibility,metadata) SELECT 'thread',id,'Sophie Jap','private','{"fixture_source":"social-suite-v3.html","fixture_key":"chat-sophie","peer_display":"Sophie Jap","presence_display":"Active now","seen_display":"Seen 19:42"}'::jsonb FROM fixture_owner;
INSERT INTO memberships(item_id,user_id) SELECT i.id,o.id FROM fixture_owner o JOIN items i ON i.author_id=o.id AND i.metadata->>'fixture_key'='chat-sophie';
INSERT INTO items(kind,author_id,parent_id,body,metadata) SELECT 'message',o.id,t.id,v.body,jsonb_build_object('fixture_source','social-suite-v3.html','fixture_key',v.key,'direction_display',v.direction,'time_display',v.time)
FROM fixture_owner o JOIN items t ON t.author_id=o.id AND t.metadata->>'fixture_key'='chat-sophie'
CROSS JOIN (VALUES
('chat-1','in','19:38','Hey! Just watched the first cut. The golden hour shots by the arch are unreal.'),
('chat-2','in','19:38','Can we post it tonight?'),
('chat-3','out','19:41','Yes, uploading now. Ten minutes.'),
('chat-4','out','19:41','I also swapped in the new soundtrack — tell me if the intro feels too slow.'),
('chat-5','in','19:42','Perfect. The slow intro works — it holds the shot.'))v(key,direction,time,body);
-- Discover people are explicitly non-account display records, included in profile metadata.
UPDATE users SET metadata=metadata||'{"discover_people":[{"name":"Thiri Aung","initials":"TA","distance_display":"1.2 km","mutual_display":"6 mutual","interests":"photography, coffee"},{"name":"Kyaw Zin","initials":"KZ","distance_display":"800 m","mutual_display":"3 mutual","interests":"running, film"},{"name":"Nang Seng","initials":"NS","distance_display":"2.4 km","mutual_display":"2 mutual","interests":"cooking, travel"}]}'::jsonb WHERE id=(SELECT id FROM fixture_owner);
INSERT INTO items(kind,author_id,name,metadata) SELECT 'shop',o.id,v.name,jsonb_build_object('fixture_source','social-suite-v3.html','fixture_key',v.key,'category',v.category,'rating_display',v.rating,'reviews_display',v.reviews,'distance_display',v.distance,'open_display',v.open,'posts_this_week_display',v.posts)
FROM fixture_owner o CROSS JOIN (VALUES
('place-boats','Inya Lake Boats','place','4.5','98','1.4 km','Closed',''),
('place-market','Hledan Night Market','food','4.6','512','2.2 km','Closed','6 posts this week'),
('business-bike','Yangon Bike Repair','service','4.6','','1.1 km','Open','1 post this week'),
('business-tailor','Ponnya Thiri Tailor','fashion','4.9','','1.6 km','Open','2 posts this week'))v(key,name,category,rating,reviews,distance,open,posts);
-- HTML shows the market Open in places but Closed in business; retain both, do not invent resolution.
UPDATE items SET metadata=metadata||'{"places_open_display":"Open","business_open_display":"Closed"}'::jsonb WHERE author_id=(SELECT id FROM fixture_owner) AND metadata->>'fixture_key'='place-market';
COMMIT;
