// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Post _$PostFromJson(Map<String, dynamic> json) => _Post(
  id: json['id'] as String,
  kind: json['kind'] as String,
  body: json['body'] as String,
  title: json['title'] as String? ?? '',
  author: json['author'] as String? ?? '',
  subtitle: json['subtitle'] as String? ?? '',
  location: json['location'] as String? ?? '',
  reason: json['reason'] as String? ?? '',
  tags: json['tags'] as String? ?? '',
  music: json['music'] as String? ?? '',
  score: (json['score'] as num?)?.toInt() ?? 0,
  nearby: json['nearby'] as bool? ?? false,
  friend: json['friend'] as bool? ?? false,
  likes: (json['likes'] as num?)?.toInt() ?? 0,
  comments: (json['comments'] as num?)?.toInt() ?? 0,
  shares: (json['shares'] as num?)?.toInt() ?? 0,
  liked: json['liked'] as bool? ?? false,
  saved: json['saved'] as bool? ?? false,
  originalId: json['originalId'] as String?,
  originalAuthor: json['originalAuthor'] as String?,
  originalBody: json['originalBody'] as String?,
);

Map<String, dynamic> _$PostToJson(_Post instance) => <String, dynamic>{
  'id': instance.id,
  'kind': instance.kind,
  'body': instance.body,
  'title': instance.title,
  'author': instance.author,
  'subtitle': instance.subtitle,
  'location': instance.location,
  'reason': instance.reason,
  'tags': instance.tags,
  'music': instance.music,
  'score': instance.score,
  'nearby': instance.nearby,
  'friend': instance.friend,
  'likes': instance.likes,
  'comments': instance.comments,
  'shares': instance.shares,
  'liked': instance.liked,
  'saved': instance.saved,
  'originalId': instance.originalId,
  'originalAuthor': instance.originalAuthor,
  'originalBody': instance.originalBody,
};

_Entry _$EntryFromJson(Map<String, dynamic> json) => _Entry(
  id: json['id'] as String,
  title: json['title'] as String? ?? '',
  subtitle: json['subtitle'] as String? ?? '',
  body: json['body'] as String? ?? '',
  category: json['category'] as String? ?? '',
  subtype: json['subtype'] as String? ?? '',
  icon: json['icon'] as String? ?? '',
  target: json['target'] as String? ?? '',
  action: json['action'] as String? ?? '',
  price: json['price'] as String? ?? '',
  selected: json['selected'] as bool? ?? false,
  unread: json['unread'] as bool? ?? false,
  outgoing: json['outgoing'] as bool? ?? false,
);

Map<String, dynamic> _$EntryToJson(_Entry instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'body': instance.body,
  'category': instance.category,
  'subtype': instance.subtype,
  'icon': instance.icon,
  'target': instance.target,
  'action': instance.action,
  'price': instance.price,
  'selected': instance.selected,
  'unread': instance.unread,
  'outgoing': instance.outgoing,
};

_Session _$SessionFromJson(Map<String, dynamic> json) =>
    _Session(jwt: json['jwt'] as String, refresh: json['refresh'] as String);

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'jwt': instance.jwt,
  'refresh': instance.refresh,
};
