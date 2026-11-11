// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Post {

 String get id; String get kind; String get body; String get title; String get author; String get subtitle; String get location; String get reason; String get tags; String get music; int get score; bool get nearby; bool get friend; int get likes; int get comments; int get shares; bool get liked; bool get saved; String? get originalId; String? get originalAuthor; String? get originalBody;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Post;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.subtitle, _this.subtitle) || other.subtitle == _this.subtitle)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.tags, _this.tags) || other.tags == _this.tags)&&(identical(other.music, _this.music) || other.music == _this.music)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.nearby, _this.nearby) || other.nearby == _this.nearby)&&(identical(other.friend, _this.friend) || other.friend == _this.friend)&&(identical(other.likes, _this.likes) || other.likes == _this.likes)&&(identical(other.comments, _this.comments) || other.comments == _this.comments)&&(identical(other.shares, _this.shares) || other.shares == _this.shares)&&(identical(other.liked, _this.liked) || other.liked == _this.liked)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.originalId, _this.originalId) || other.originalId == _this.originalId)&&(identical(other.originalAuthor, _this.originalAuthor) || other.originalAuthor == _this.originalAuthor)&&(identical(other.originalBody, _this.originalBody) || other.originalBody == _this.originalBody));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Post;
  return Object.hashAll([runtimeType,_this.id,_this.kind,_this.body,_this.title,_this.author,_this.subtitle,_this.location,_this.reason,_this.tags,_this.music,_this.score,_this.nearby,_this.friend,_this.likes,_this.comments,_this.shares,_this.liked,_this.saved,_this.originalId,_this.originalAuthor,_this.originalBody]);
}

@override
String toString() {
  final _this = this as Post;
  return 'Post(id: ${_this.id}, kind: ${_this.kind}, body: ${_this.body}, title: ${_this.title}, author: ${_this.author}, subtitle: ${_this.subtitle}, location: ${_this.location}, reason: ${_this.reason}, tags: ${_this.tags}, music: ${_this.music}, score: ${_this.score}, nearby: ${_this.nearby}, friend: ${_this.friend}, likes: ${_this.likes}, comments: ${_this.comments}, shares: ${_this.shares}, liked: ${_this.liked}, saved: ${_this.saved}, originalId: ${_this.originalId}, originalAuthor: ${_this.originalAuthor}, originalBody: ${_this.originalBody})';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String id, String kind, String body, String title, String author, String subtitle, String location, String reason, String tags, String music, int score, bool nearby, bool friend, int likes, int comments, int shares, bool liked, bool saved, String? originalId, String? originalAuthor, String? originalBody
});




}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? body = null,Object? title = null,Object? author = null,Object? subtitle = null,Object? location = null,Object? reason = null,Object? tags = null,Object? music = null,Object? score = null,Object? nearby = null,Object? friend = null,Object? likes = null,Object? comments = null,Object? shares = null,Object? liked = null,Object? saved = null,Object? originalId = freezed,Object? originalAuthor = freezed,Object? originalBody = freezed,}) {
  return _then(Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as String,music: null == music ? _self.music : music // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,nearby: null == nearby ? _self.nearby : nearby // ignore: cast_nullable_to_non_nullable
as bool,friend: null == friend ? _self.friend : friend // ignore: cast_nullable_to_non_nullable
as bool,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as int,liked: null == liked ? _self.liked : liked // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,originalId: freezed == originalId ? _self.originalId : originalId // ignore: cast_nullable_to_non_nullable
as String?,originalAuthor: freezed == originalAuthor ? _self.originalAuthor : originalAuthor // ignore: cast_nullable_to_non_nullable
as String?,originalBody: freezed == originalBody ? _self.originalBody : originalBody // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String kind,  String body,  String title,  String author,  String subtitle,  String location,  String reason,  String tags,  String music,  int score,  bool nearby,  bool friend,  int likes,  int comments,  int shares,  bool liked,  bool saved,  String? originalId,  String? originalAuthor,  String? originalBody)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.kind,_that.body,_that.title,_that.author,_that.subtitle,_that.location,_that.reason,_that.tags,_that.music,_that.score,_that.nearby,_that.friend,_that.likes,_that.comments,_that.shares,_that.liked,_that.saved,_that.originalId,_that.originalAuthor,_that.originalBody);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String kind,  String body,  String title,  String author,  String subtitle,  String location,  String reason,  String tags,  String music,  int score,  bool nearby,  bool friend,  int likes,  int comments,  int shares,  bool liked,  bool saved,  String? originalId,  String? originalAuthor,  String? originalBody)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.kind,_that.body,_that.title,_that.author,_that.subtitle,_that.location,_that.reason,_that.tags,_that.music,_that.score,_that.nearby,_that.friend,_that.likes,_that.comments,_that.shares,_that.liked,_that.saved,_that.originalId,_that.originalAuthor,_that.originalBody);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String kind,  String body,  String title,  String author,  String subtitle,  String location,  String reason,  String tags,  String music,  int score,  bool nearby,  bool friend,  int likes,  int comments,  int shares,  bool liked,  bool saved,  String? originalId,  String? originalAuthor,  String? originalBody)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.kind,_that.body,_that.title,_that.author,_that.subtitle,_that.location,_that.reason,_that.tags,_that.music,_that.score,_that.nearby,_that.friend,_that.likes,_that.comments,_that.shares,_that.liked,_that.saved,_that.originalId,_that.originalAuthor,_that.originalBody);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Post implements Post {
  const _Post({required this.id, required this.kind, required this.body, this.title = '', this.author = '', this.subtitle = '', this.location = '', this.reason = '', this.tags = '', this.music = '', this.score = 0, this.nearby = false, this.friend = false, this.likes = 0, this.comments = 0, this.shares = 0, this.liked = false, this.saved = false, this.originalId, this.originalAuthor, this.originalBody});
  factory _Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

@override final  String id;
@override final  String kind;
@override final  String body;
@override@JsonKey() final  String title;
@override@JsonKey() final  String author;
@override@JsonKey() final  String subtitle;
@override@JsonKey() final  String location;
@override@JsonKey() final  String reason;
@override@JsonKey() final  String tags;
@override@JsonKey() final  String music;
@override@JsonKey() final  int score;
@override@JsonKey() final  bool nearby;
@override@JsonKey() final  bool friend;
@override@JsonKey() final  int likes;
@override@JsonKey() final  int comments;
@override@JsonKey() final  int shares;
@override@JsonKey() final  bool liked;
@override@JsonKey() final  bool saved;
@override final  String? originalId;
@override final  String? originalAuthor;
@override final  String? originalBody;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.body, body) || other.body == body)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.location, location) || other.location == location)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.tags, tags) || other.tags == tags)&&(identical(other.music, music) || other.music == music)&&(identical(other.score, score) || other.score == score)&&(identical(other.nearby, nearby) || other.nearby == nearby)&&(identical(other.friend, friend) || other.friend == friend)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.shares, shares) || other.shares == shares)&&(identical(other.liked, liked) || other.liked == liked)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.originalId, originalId) || other.originalId == originalId)&&(identical(other.originalAuthor, originalAuthor) || other.originalAuthor == originalAuthor)&&(identical(other.originalBody, originalBody) || other.originalBody == originalBody));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,kind,body,title,author,subtitle,location,reason,tags,music,score,nearby,friend,likes,comments,shares,liked,saved,originalId,originalAuthor,originalBody]);
}

@override
String toString() {
    return 'Post(id: $id, kind: $kind, body: $body, title: $title, author: $author, subtitle: $subtitle, location: $location, reason: $reason, tags: $tags, music: $music, score: $score, nearby: $nearby, friend: $friend, likes: $likes, comments: $comments, shares: $shares, liked: $liked, saved: $saved, originalId: $originalId, originalAuthor: $originalAuthor, originalBody: $originalBody)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String id, String kind, String body, String title, String author, String subtitle, String location, String reason, String tags, String music, int score, bool nearby, bool friend, int likes, int comments, int shares, bool liked, bool saved, String? originalId, String? originalAuthor, String? originalBody
});




}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? body = null,Object? title = null,Object? author = null,Object? subtitle = null,Object? location = null,Object? reason = null,Object? tags = null,Object? music = null,Object? score = null,Object? nearby = null,Object? friend = null,Object? likes = null,Object? comments = null,Object? shares = null,Object? liked = null,Object? saved = null,Object? originalId = freezed,Object? originalAuthor = freezed,Object? originalBody = freezed,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as String,music: null == music ? _self.music : music // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,nearby: null == nearby ? _self.nearby : nearby // ignore: cast_nullable_to_non_nullable
as bool,friend: null == friend ? _self.friend : friend // ignore: cast_nullable_to_non_nullable
as bool,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as int,liked: null == liked ? _self.liked : liked // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,originalId: freezed == originalId ? _self.originalId : originalId // ignore: cast_nullable_to_non_nullable
as String?,originalAuthor: freezed == originalAuthor ? _self.originalAuthor : originalAuthor // ignore: cast_nullable_to_non_nullable
as String?,originalBody: freezed == originalBody ? _self.originalBody : originalBody // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Entry {

 String get id; String get title; String get subtitle; String get body; String get category; String get subtype; String get icon; String get target; String get action; String get price; bool get selected; bool get unread; bool get outgoing;
/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryCopyWith<Entry> get copyWith => _$EntryCopyWithImpl<Entry>(this as Entry, _$identity);

  /// Serializes this Entry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Entry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Entry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.subtitle, _this.subtitle) || other.subtitle == _this.subtitle)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.subtype, _this.subtype) || other.subtype == _this.subtype)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.target, _this.target) || other.target == _this.target)&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.selected, _this.selected) || other.selected == _this.selected)&&(identical(other.unread, _this.unread) || other.unread == _this.unread)&&(identical(other.outgoing, _this.outgoing) || other.outgoing == _this.outgoing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Entry;
  return Object.hash(runtimeType,_this.id,_this.title,_this.subtitle,_this.body,_this.category,_this.subtype,_this.icon,_this.target,_this.action,_this.price,_this.selected,_this.unread,_this.outgoing);
}

@override
String toString() {
  final _this = this as Entry;
  return 'Entry(id: ${_this.id}, title: ${_this.title}, subtitle: ${_this.subtitle}, body: ${_this.body}, category: ${_this.category}, subtype: ${_this.subtype}, icon: ${_this.icon}, target: ${_this.target}, action: ${_this.action}, price: ${_this.price}, selected: ${_this.selected}, unread: ${_this.unread}, outgoing: ${_this.outgoing})';
}


}

/// @nodoc
abstract mixin class $EntryCopyWith<$Res>  {
  factory $EntryCopyWith(Entry value, $Res Function(Entry) _then) = _$EntryCopyWithImpl;
@useResult
$Res call({
 String id, String title, String subtitle, String body, String category, String subtype, String icon, String target, String action, String price, bool selected, bool unread, bool outgoing
});




}
/// @nodoc
class _$EntryCopyWithImpl<$Res>
    implements $EntryCopyWith<$Res> {
  _$EntryCopyWithImpl(this._self, this._then);

  final Entry _self;
  final $Res Function(Entry) _then;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? subtitle = null,Object? body = null,Object? category = null,Object? subtype = null,Object? icon = null,Object? target = null,Object? action = null,Object? price = null,Object? selected = null,Object? unread = null,Object? outgoing = null,}) {
  return _then(Entry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subtype: null == subtype ? _self.subtype : subtype // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as bool,outgoing: null == outgoing ? _self.outgoing : outgoing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Entry].
extension EntryPatterns on Entry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Entry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Entry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Entry value)  $default,){
final _that = this;
switch (_that) {
case _Entry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Entry value)?  $default,){
final _that = this;
switch (_that) {
case _Entry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String subtitle,  String body,  String category,  String subtype,  String icon,  String target,  String action,  String price,  bool selected,  bool unread,  bool outgoing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Entry() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.body,_that.category,_that.subtype,_that.icon,_that.target,_that.action,_that.price,_that.selected,_that.unread,_that.outgoing);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String subtitle,  String body,  String category,  String subtype,  String icon,  String target,  String action,  String price,  bool selected,  bool unread,  bool outgoing)  $default,) {final _that = this;
switch (_that) {
case _Entry():
return $default(_that.id,_that.title,_that.subtitle,_that.body,_that.category,_that.subtype,_that.icon,_that.target,_that.action,_that.price,_that.selected,_that.unread,_that.outgoing);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String subtitle,  String body,  String category,  String subtype,  String icon,  String target,  String action,  String price,  bool selected,  bool unread,  bool outgoing)?  $default,) {final _that = this;
switch (_that) {
case _Entry() when $default != null:
return $default(_that.id,_that.title,_that.subtitle,_that.body,_that.category,_that.subtype,_that.icon,_that.target,_that.action,_that.price,_that.selected,_that.unread,_that.outgoing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Entry implements Entry {
  const _Entry({required this.id, this.title = '', this.subtitle = '', this.body = '', this.category = '', this.subtype = '', this.icon = '', this.target = '', this.action = '', this.price = '', this.selected = false, this.unread = false, this.outgoing = false});
  factory _Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String subtitle;
@override@JsonKey() final  String body;
@override@JsonKey() final  String category;
@override@JsonKey() final  String subtype;
@override@JsonKey() final  String icon;
@override@JsonKey() final  String target;
@override@JsonKey() final  String action;
@override@JsonKey() final  String price;
@override@JsonKey() final  bool selected;
@override@JsonKey() final  bool unread;
@override@JsonKey() final  bool outgoing;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryCopyWith<_Entry> get copyWith => __$EntryCopyWithImpl<_Entry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Entry&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.body, body) || other.body == body)&&(identical(other.category, category) || other.category == category)&&(identical(other.subtype, subtype) || other.subtype == subtype)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.target, target) || other.target == target)&&(identical(other.action, action) || other.action == action)&&(identical(other.price, price) || other.price == price)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.unread, unread) || other.unread == unread)&&(identical(other.outgoing, outgoing) || other.outgoing == outgoing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,subtitle,body,category,subtype,icon,target,action,price,selected,unread,outgoing);
}

@override
String toString() {
    return 'Entry(id: $id, title: $title, subtitle: $subtitle, body: $body, category: $category, subtype: $subtype, icon: $icon, target: $target, action: $action, price: $price, selected: $selected, unread: $unread, outgoing: $outgoing)';
}


}

/// @nodoc
abstract mixin class _$EntryCopyWith<$Res> implements $EntryCopyWith<$Res> {
  factory _$EntryCopyWith(_Entry value, $Res Function(_Entry) _then) = __$EntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String subtitle, String body, String category, String subtype, String icon, String target, String action, String price, bool selected, bool unread, bool outgoing
});




}
/// @nodoc
class __$EntryCopyWithImpl<$Res>
    implements _$EntryCopyWith<$Res> {
  __$EntryCopyWithImpl(this._self, this._then);

  final _Entry _self;
  final $Res Function(_Entry) _then;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? subtitle = null,Object? body = null,Object? category = null,Object? subtype = null,Object? icon = null,Object? target = null,Object? action = null,Object? price = null,Object? selected = null,Object? unread = null,Object? outgoing = null,}) {
  return _then(_Entry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subtype: null == subtype ? _self.subtype : subtype // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as bool,unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as bool,outgoing: null == outgoing ? _self.outgoing : outgoing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Session {

 String get jwt; String get refresh;
/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionCopyWith<Session> get copyWith => _$SessionCopyWithImpl<Session>(this as Session, _$identity);

  /// Serializes this Session to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Session;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Session&&(identical(other.jwt, _this.jwt) || other.jwt == _this.jwt)&&(identical(other.refresh, _this.refresh) || other.refresh == _this.refresh));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Session;
  return Object.hash(runtimeType,_this.jwt,_this.refresh);
}

@override
String toString() {
  final _this = this as Session;
  return 'Session(jwt: ${_this.jwt}, refresh: ${_this.refresh})';
}


}

/// @nodoc
abstract mixin class $SessionCopyWith<$Res>  {
  factory $SessionCopyWith(Session value, $Res Function(Session) _then) = _$SessionCopyWithImpl;
@useResult
$Res call({
 String jwt, String refresh
});




}
/// @nodoc
class _$SessionCopyWithImpl<$Res>
    implements $SessionCopyWith<$Res> {
  _$SessionCopyWithImpl(this._self, this._then);

  final Session _self;
  final $Res Function(Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jwt = null,Object? refresh = null,}) {
  return _then(Session(
jwt: null == jwt ? _self.jwt : jwt // ignore: cast_nullable_to_non_nullable
as String,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Session].
extension SessionPatterns on Session {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Session value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Session value)  $default,){
final _that = this;
switch (_that) {
case _Session():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Session value)?  $default,){
final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String jwt,  String refresh)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.jwt,_that.refresh);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String jwt,  String refresh)  $default,) {final _that = this;
switch (_that) {
case _Session():
return $default(_that.jwt,_that.refresh);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String jwt,  String refresh)?  $default,) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.jwt,_that.refresh);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Session implements Session {
  const _Session({required this.jwt, required this.refresh});
  factory _Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

@override final  String jwt;
@override final  String refresh;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionCopyWith<_Session> get copyWith => __$SessionCopyWithImpl<_Session>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Session&&(identical(other.jwt, jwt) || other.jwt == jwt)&&(identical(other.refresh, refresh) || other.refresh == refresh));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,jwt,refresh);
}

@override
String toString() {
    return 'Session(jwt: $jwt, refresh: $refresh)';
}


}

/// @nodoc
abstract mixin class _$SessionCopyWith<$Res> implements $SessionCopyWith<$Res> {
  factory _$SessionCopyWith(_Session value, $Res Function(_Session) _then) = __$SessionCopyWithImpl;
@override @useResult
$Res call({
 String jwt, String refresh
});




}
/// @nodoc
class __$SessionCopyWithImpl<$Res>
    implements _$SessionCopyWith<$Res> {
  __$SessionCopyWithImpl(this._self, this._then);

  final _Session _self;
  final $Res Function(_Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jwt = null,Object? refresh = null,}) {
  return _then(_Session(
jwt: null == jwt ? _self.jwt : jwt // ignore: cast_nullable_to_non_nullable
as String,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$AuthState {

 String get stage; String get phone; String get email; String get otp; int get resendSeconds; String get verificationStatus; bool get busy; String? get error;
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateCopyWith<AuthState> get copyWith => _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AuthState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.otp, _this.otp) || other.otp == _this.otp)&&(identical(other.resendSeconds, _this.resendSeconds) || other.resendSeconds == _this.resendSeconds)&&(identical(other.verificationStatus, _this.verificationStatus) || other.verificationStatus == _this.verificationStatus)&&(identical(other.busy, _this.busy) || other.busy == _this.busy)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as AuthState;
  return Object.hash(runtimeType,_this.stage,_this.phone,_this.email,_this.otp,_this.resendSeconds,_this.verificationStatus,_this.busy,_this.error);
}

@override
String toString() {
  final _this = this as AuthState;
  return 'AuthState(stage: ${_this.stage}, phone: ${_this.phone}, email: ${_this.email}, otp: ${_this.otp}, resendSeconds: ${_this.resendSeconds}, verificationStatus: ${_this.verificationStatus}, busy: ${_this.busy}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res>  {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) = _$AuthStateCopyWithImpl;
@useResult
$Res call({
 String stage, String phone, String email, String otp, int resendSeconds, String verificationStatus, bool busy, String? error
});




}
/// @nodoc
class _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stage = null,Object? phone = null,Object? email = null,Object? otp = null,Object? resendSeconds = null,Object? verificationStatus = null,Object? busy = null,Object? error = freezed,}) {
  return _then(AuthState(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,resendSeconds: null == resendSeconds ? _self.resendSeconds : resendSeconds // ignore: cast_nullable_to_non_nullable
as int,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthState value)  $default,){
final _that = this;
switch (_that) {
case _AuthState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stage,  String phone,  String email,  String otp,  int resendSeconds,  String verificationStatus,  bool busy,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.stage,_that.phone,_that.email,_that.otp,_that.resendSeconds,_that.verificationStatus,_that.busy,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stage,  String phone,  String email,  String otp,  int resendSeconds,  String verificationStatus,  bool busy,  String? error)  $default,) {final _that = this;
switch (_that) {
case _AuthState():
return $default(_that.stage,_that.phone,_that.email,_that.otp,_that.resendSeconds,_that.verificationStatus,_that.busy,_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stage,  String phone,  String email,  String otp,  int resendSeconds,  String verificationStatus,  bool busy,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.stage,_that.phone,_that.email,_that.otp,_that.resendSeconds,_that.verificationStatus,_that.busy,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _AuthState implements AuthState {
  const _AuthState({this.stage = 'login', this.phone = '', this.email = '', this.otp = '', this.resendSeconds = 0, this.verificationStatus = '', this.busy = false, this.error});
  

@override@JsonKey() final  String stage;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String email;
@override@JsonKey() final  String otp;
@override@JsonKey() final  int resendSeconds;
@override@JsonKey() final  String verificationStatus;
@override@JsonKey() final  bool busy;
@override final  String? error;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthStateCopyWith<_AuthState> get copyWith => __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthState&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.otp, otp) || other.otp == otp)&&(identical(other.resendSeconds, resendSeconds) || other.resendSeconds == resendSeconds)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,stage,phone,email,otp,resendSeconds,verificationStatus,busy,error);
}

@override
String toString() {
    return 'AuthState(stage: $stage, phone: $phone, email: $email, otp: $otp, resendSeconds: $resendSeconds, verificationStatus: $verificationStatus, busy: $busy, error: $error)';
}


}

/// @nodoc
abstract mixin class _$AuthStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(_AuthState value, $Res Function(_AuthState) _then) = __$AuthStateCopyWithImpl;
@override @useResult
$Res call({
 String stage, String phone, String email, String otp, int resendSeconds, String verificationStatus, bool busy, String? error
});




}
/// @nodoc
class __$AuthStateCopyWithImpl<$Res>
    implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stage = null,Object? phone = null,Object? email = null,Object? otp = null,Object? resendSeconds = null,Object? verificationStatus = null,Object? busy = null,Object? error = freezed,}) {
  return _then(_AuthState(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,resendSeconds: null == resendSeconds ? _self.resendSeconds : resendSeconds // ignore: cast_nullable_to_non_nullable
as int,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$NexusState {

 String get screen; String get filter; String get category; String get subtype; String get query; String get profileTab; List<Post> get posts; List<Entry> get discover; List<Entry> get messages; List<Entry> get notifications; Map<String, List<Entry>> get comments; bool get joined; bool get busy; Map<String, int> get cart; Map<String, dynamic> get profile; Map<String, dynamic> get shop; Map<String, dynamic> get group; List<Entry> get products; String get threadId; String get threadName; String get draft; String get kind; String get mood; Post? get repost; String get messageDraft; String get commentDraft; String get replyTo; String? get error;
/// Create a copy of NexusState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NexusStateCopyWith<NexusState> get copyWith => _$NexusStateCopyWithImpl<NexusState>(this as NexusState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NexusState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NexusState&&(identical(other.screen, _this.screen) || other.screen == _this.screen)&&(identical(other.filter, _this.filter) || other.filter == _this.filter)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.subtype, _this.subtype) || other.subtype == _this.subtype)&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.profileTab, _this.profileTab) || other.profileTab == _this.profileTab)&&const DeepCollectionEquality().equals(other.posts, _this.posts)&&const DeepCollectionEquality().equals(other.discover, _this.discover)&&const DeepCollectionEquality().equals(other.messages, _this.messages)&&const DeepCollectionEquality().equals(other.notifications, _this.notifications)&&const DeepCollectionEquality().equals(other.comments, _this.comments)&&(identical(other.joined, _this.joined) || other.joined == _this.joined)&&(identical(other.busy, _this.busy) || other.busy == _this.busy)&&const DeepCollectionEquality().equals(other.cart, _this.cart)&&const DeepCollectionEquality().equals(other.profile, _this.profile)&&const DeepCollectionEquality().equals(other.shop, _this.shop)&&const DeepCollectionEquality().equals(other.group, _this.group)&&const DeepCollectionEquality().equals(other.products, _this.products)&&(identical(other.threadId, _this.threadId) || other.threadId == _this.threadId)&&(identical(other.threadName, _this.threadName) || other.threadName == _this.threadName)&&(identical(other.draft, _this.draft) || other.draft == _this.draft)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.mood, _this.mood) || other.mood == _this.mood)&&(identical(other.repost, _this.repost) || other.repost == _this.repost)&&(identical(other.messageDraft, _this.messageDraft) || other.messageDraft == _this.messageDraft)&&(identical(other.commentDraft, _this.commentDraft) || other.commentDraft == _this.commentDraft)&&(identical(other.replyTo, _this.replyTo) || other.replyTo == _this.replyTo)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as NexusState;
  return Object.hashAll([runtimeType,_this.screen,_this.filter,_this.category,_this.subtype,_this.query,_this.profileTab,const DeepCollectionEquality().hash(_this.posts),const DeepCollectionEquality().hash(_this.discover),const DeepCollectionEquality().hash(_this.messages),const DeepCollectionEquality().hash(_this.notifications),const DeepCollectionEquality().hash(_this.comments),_this.joined,_this.busy,const DeepCollectionEquality().hash(_this.cart),const DeepCollectionEquality().hash(_this.profile),const DeepCollectionEquality().hash(_this.shop),const DeepCollectionEquality().hash(_this.group),const DeepCollectionEquality().hash(_this.products),_this.threadId,_this.threadName,_this.draft,_this.kind,_this.mood,_this.repost,_this.messageDraft,_this.commentDraft,_this.replyTo,_this.error]);
}

@override
String toString() {
  final _this = this as NexusState;
  return 'NexusState(screen: ${_this.screen}, filter: ${_this.filter}, category: ${_this.category}, subtype: ${_this.subtype}, query: ${_this.query}, profileTab: ${_this.profileTab}, posts: ${_this.posts}, discover: ${_this.discover}, messages: ${_this.messages}, notifications: ${_this.notifications}, comments: ${_this.comments}, joined: ${_this.joined}, busy: ${_this.busy}, cart: ${_this.cart}, profile: ${_this.profile}, shop: ${_this.shop}, group: ${_this.group}, products: ${_this.products}, threadId: ${_this.threadId}, threadName: ${_this.threadName}, draft: ${_this.draft}, kind: ${_this.kind}, mood: ${_this.mood}, repost: ${_this.repost}, messageDraft: ${_this.messageDraft}, commentDraft: ${_this.commentDraft}, replyTo: ${_this.replyTo}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $NexusStateCopyWith<$Res>  {
  factory $NexusStateCopyWith(NexusState value, $Res Function(NexusState) _then) = _$NexusStateCopyWithImpl;
@useResult
$Res call({
 String screen, String filter, String category, String subtype, String query, String profileTab, List<Post> posts, List<Entry> discover, List<Entry> messages, List<Entry> notifications, Map<String, List<Entry>> comments, bool joined, bool busy, Map<String, int> cart, Map<String, dynamic> profile, Map<String, dynamic> shop, Map<String, dynamic> group, List<Entry> products, String threadId, String threadName, String draft, String kind, String mood, Post? repost, String messageDraft, String commentDraft, String replyTo, String? error
});


$PostCopyWith<$Res>? get repost;

}
/// @nodoc
class _$NexusStateCopyWithImpl<$Res>
    implements $NexusStateCopyWith<$Res> {
  _$NexusStateCopyWithImpl(this._self, this._then);

  final NexusState _self;
  final $Res Function(NexusState) _then;

/// Create a copy of NexusState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? screen = null,Object? filter = null,Object? category = null,Object? subtype = null,Object? query = null,Object? profileTab = null,Object? posts = null,Object? discover = null,Object? messages = null,Object? notifications = null,Object? comments = null,Object? joined = null,Object? busy = null,Object? cart = null,Object? profile = null,Object? shop = null,Object? group = null,Object? products = null,Object? threadId = null,Object? threadName = null,Object? draft = null,Object? kind = null,Object? mood = null,Object? repost = freezed,Object? messageDraft = null,Object? commentDraft = null,Object? replyTo = null,Object? error = freezed,}) {
  return _then(NexusState(
screen: null == screen ? _self.screen : screen // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subtype: null == subtype ? _self.subtype : subtype // ignore: cast_nullable_to_non_nullable
as String,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,profileTab: null == profileTab ? _self.profileTab : profileTab // ignore: cast_nullable_to_non_nullable
as String,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,discover: null == discover ? _self.discover : discover // ignore: cast_nullable_to_non_nullable
as List<Entry>,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<Entry>,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<Entry>,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as Map<String, List<Entry>>,joined: null == joined ? _self.joined : joined // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,cart: null == cart ? _self.cart : cart // ignore: cast_nullable_to_non_nullable
as Map<String, int>,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,shop: null == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<Entry>,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,threadName: null == threadName ? _self.threadName : threadName // ignore: cast_nullable_to_non_nullable
as String,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String,repost: freezed == repost ? _self.repost : repost // ignore: cast_nullable_to_non_nullable
as Post?,messageDraft: null == messageDraft ? _self.messageDraft : messageDraft // ignore: cast_nullable_to_non_nullable
as String,commentDraft: null == commentDraft ? _self.commentDraft : commentDraft // ignore: cast_nullable_to_non_nullable
as String,replyTo: null == replyTo ? _self.replyTo : replyTo // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of NexusState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res>? get repost {
    if (_self.repost == null) {
    return null;
  }

  return $PostCopyWith<$Res>(_self.repost!, (value) {
    return _then(_self.copyWith(repost: value));
  });
}
}


/// Adds pattern-matching-related methods to [NexusState].
extension NexusStatePatterns on NexusState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NexusState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NexusState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NexusState value)  $default,){
final _that = this;
switch (_that) {
case _NexusState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NexusState value)?  $default,){
final _that = this;
switch (_that) {
case _NexusState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String screen,  String filter,  String category,  String subtype,  String query,  String profileTab,  List<Post> posts,  List<Entry> discover,  List<Entry> messages,  List<Entry> notifications,  Map<String, List<Entry>> comments,  bool joined,  bool busy,  Map<String, int> cart,  Map<String, dynamic> profile,  Map<String, dynamic> shop,  Map<String, dynamic> group,  List<Entry> products,  String threadId,  String threadName,  String draft,  String kind,  String mood,  Post? repost,  String messageDraft,  String commentDraft,  String replyTo,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NexusState() when $default != null:
return $default(_that.screen,_that.filter,_that.category,_that.subtype,_that.query,_that.profileTab,_that.posts,_that.discover,_that.messages,_that.notifications,_that.comments,_that.joined,_that.busy,_that.cart,_that.profile,_that.shop,_that.group,_that.products,_that.threadId,_that.threadName,_that.draft,_that.kind,_that.mood,_that.repost,_that.messageDraft,_that.commentDraft,_that.replyTo,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String screen,  String filter,  String category,  String subtype,  String query,  String profileTab,  List<Post> posts,  List<Entry> discover,  List<Entry> messages,  List<Entry> notifications,  Map<String, List<Entry>> comments,  bool joined,  bool busy,  Map<String, int> cart,  Map<String, dynamic> profile,  Map<String, dynamic> shop,  Map<String, dynamic> group,  List<Entry> products,  String threadId,  String threadName,  String draft,  String kind,  String mood,  Post? repost,  String messageDraft,  String commentDraft,  String replyTo,  String? error)  $default,) {final _that = this;
switch (_that) {
case _NexusState():
return $default(_that.screen,_that.filter,_that.category,_that.subtype,_that.query,_that.profileTab,_that.posts,_that.discover,_that.messages,_that.notifications,_that.comments,_that.joined,_that.busy,_that.cart,_that.profile,_that.shop,_that.group,_that.products,_that.threadId,_that.threadName,_that.draft,_that.kind,_that.mood,_that.repost,_that.messageDraft,_that.commentDraft,_that.replyTo,_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String screen,  String filter,  String category,  String subtype,  String query,  String profileTab,  List<Post> posts,  List<Entry> discover,  List<Entry> messages,  List<Entry> notifications,  Map<String, List<Entry>> comments,  bool joined,  bool busy,  Map<String, int> cart,  Map<String, dynamic> profile,  Map<String, dynamic> shop,  Map<String, dynamic> group,  List<Entry> products,  String threadId,  String threadName,  String draft,  String kind,  String mood,  Post? repost,  String messageDraft,  String commentDraft,  String replyTo,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _NexusState() when $default != null:
return $default(_that.screen,_that.filter,_that.category,_that.subtype,_that.query,_that.profileTab,_that.posts,_that.discover,_that.messages,_that.notifications,_that.comments,_that.joined,_that.busy,_that.cart,_that.profile,_that.shop,_that.group,_that.products,_that.threadId,_that.threadName,_that.draft,_that.kind,_that.mood,_that.repost,_that.messageDraft,_that.commentDraft,_that.replyTo,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _NexusState implements NexusState {
  const _NexusState({this.screen = 'feed', this.filter = 'foryou', this.category = 'groups', this.subtype = 'all', this.query = '', this.profileTab = 'videos',  List<Post> posts = const [],  List<Entry> discover = const [],  List<Entry> messages = const [],  List<Entry> notifications = const [],  Map<String, List<Entry>> comments = const {}, this.joined = false, this.busy = false,  Map<String, int> cart = const {},  Map<String, dynamic> profile = const {},  Map<String, dynamic> shop = const {},  Map<String, dynamic> group = const {},  List<Entry> products = const [], this.threadId = '', this.threadName = '', this.draft = '', this.kind = 'feel', this.mood = 'Grateful', this.repost, this.messageDraft = '', this.commentDraft = '', this.replyTo = '', this.error}): _posts = posts,_discover = discover,_messages = messages,_notifications = notifications,_comments = comments,_cart = cart,_profile = profile,_shop = shop,_group = group,_products = products;
  

@override@JsonKey() final  String screen;
@override@JsonKey() final  String filter;
@override@JsonKey() final  String category;
@override@JsonKey() final  String subtype;
@override@JsonKey() final  String query;
@override@JsonKey() final  String profileTab;
 final  List<Post> _posts;
@override@JsonKey() List<Post> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

 final  List<Entry> _discover;
@override@JsonKey() List<Entry> get discover {
  if (_discover is EqualUnmodifiableListView) return _discover;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discover);
}

 final  List<Entry> _messages;
@override@JsonKey() List<Entry> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  List<Entry> _notifications;
@override@JsonKey() List<Entry> get notifications {
  if (_notifications is EqualUnmodifiableListView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifications);
}

 final  Map<String, List<Entry>> _comments;
@override@JsonKey() Map<String, List<Entry>> get comments {
  if (_comments is EqualUnmodifiableMapView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_comments);
}

@override@JsonKey() final  bool joined;
@override@JsonKey() final  bool busy;
 final  Map<String, int> _cart;
@override@JsonKey() Map<String, int> get cart {
  if (_cart is EqualUnmodifiableMapView) return _cart;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_cart);
}

 final  Map<String, dynamic> _profile;
@override@JsonKey() Map<String, dynamic> get profile {
  if (_profile is EqualUnmodifiableMapView) return _profile;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_profile);
}

 final  Map<String, dynamic> _shop;
@override@JsonKey() Map<String, dynamic> get shop {
  if (_shop is EqualUnmodifiableMapView) return _shop;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_shop);
}

 final  Map<String, dynamic> _group;
@override@JsonKey() Map<String, dynamic> get group {
  if (_group is EqualUnmodifiableMapView) return _group;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_group);
}

 final  List<Entry> _products;
@override@JsonKey() List<Entry> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

@override@JsonKey() final  String threadId;
@override@JsonKey() final  String threadName;
@override@JsonKey() final  String draft;
@override@JsonKey() final  String kind;
@override@JsonKey() final  String mood;
@override final  Post? repost;
@override@JsonKey() final  String messageDraft;
@override@JsonKey() final  String commentDraft;
@override@JsonKey() final  String replyTo;
@override final  String? error;

/// Create a copy of NexusState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NexusStateCopyWith<_NexusState> get copyWith => __$NexusStateCopyWithImpl<_NexusState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NexusState&&(identical(other.screen, screen) || other.screen == screen)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.category, category) || other.category == category)&&(identical(other.subtype, subtype) || other.subtype == subtype)&&(identical(other.query, query) || other.query == query)&&(identical(other.profileTab, profileTab) || other.profileTab == profileTab)&&const DeepCollectionEquality().equals(other.posts, _posts)&&const DeepCollectionEquality().equals(other.discover, _discover)&&const DeepCollectionEquality().equals(other.messages, _messages)&&const DeepCollectionEquality().equals(other.notifications, _notifications)&&const DeepCollectionEquality().equals(other.comments, _comments)&&(identical(other.joined, joined) || other.joined == joined)&&(identical(other.busy, busy) || other.busy == busy)&&const DeepCollectionEquality().equals(other.cart, _cart)&&const DeepCollectionEquality().equals(other.profile, _profile)&&const DeepCollectionEquality().equals(other.shop, _shop)&&const DeepCollectionEquality().equals(other.group, _group)&&const DeepCollectionEquality().equals(other.products, _products)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.threadName, threadName) || other.threadName == threadName)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.repost, repost) || other.repost == repost)&&(identical(other.messageDraft, messageDraft) || other.messageDraft == messageDraft)&&(identical(other.commentDraft, commentDraft) || other.commentDraft == commentDraft)&&(identical(other.replyTo, replyTo) || other.replyTo == replyTo)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,screen,filter,category,subtype,query,profileTab,const DeepCollectionEquality().hash(_posts),const DeepCollectionEquality().hash(_discover),const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_notifications),const DeepCollectionEquality().hash(_comments),joined,busy,const DeepCollectionEquality().hash(_cart),const DeepCollectionEquality().hash(_profile),const DeepCollectionEquality().hash(_shop),const DeepCollectionEquality().hash(_group),const DeepCollectionEquality().hash(_products),threadId,threadName,draft,kind,mood,repost,messageDraft,commentDraft,replyTo,error]);
}

@override
String toString() {
    return 'NexusState(screen: $screen, filter: $filter, category: $category, subtype: $subtype, query: $query, profileTab: $profileTab, posts: $posts, discover: $discover, messages: $messages, notifications: $notifications, comments: $comments, joined: $joined, busy: $busy, cart: $cart, profile: $profile, shop: $shop, group: $group, products: $products, threadId: $threadId, threadName: $threadName, draft: $draft, kind: $kind, mood: $mood, repost: $repost, messageDraft: $messageDraft, commentDraft: $commentDraft, replyTo: $replyTo, error: $error)';
}


}

/// @nodoc
abstract mixin class _$NexusStateCopyWith<$Res> implements $NexusStateCopyWith<$Res> {
  factory _$NexusStateCopyWith(_NexusState value, $Res Function(_NexusState) _then) = __$NexusStateCopyWithImpl;
@override @useResult
$Res call({
 String screen, String filter, String category, String subtype, String query, String profileTab, List<Post> posts, List<Entry> discover, List<Entry> messages, List<Entry> notifications, Map<String, List<Entry>> comments, bool joined, bool busy, Map<String, int> cart, Map<String, dynamic> profile, Map<String, dynamic> shop, Map<String, dynamic> group, List<Entry> products, String threadId, String threadName, String draft, String kind, String mood, Post? repost, String messageDraft, String commentDraft, String replyTo, String? error
});


@override $PostCopyWith<$Res>? get repost;

}
/// @nodoc
class __$NexusStateCopyWithImpl<$Res>
    implements _$NexusStateCopyWith<$Res> {
  __$NexusStateCopyWithImpl(this._self, this._then);

  final _NexusState _self;
  final $Res Function(_NexusState) _then;

/// Create a copy of NexusState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? screen = null,Object? filter = null,Object? category = null,Object? subtype = null,Object? query = null,Object? profileTab = null,Object? posts = null,Object? discover = null,Object? messages = null,Object? notifications = null,Object? comments = null,Object? joined = null,Object? busy = null,Object? cart = null,Object? profile = null,Object? shop = null,Object? group = null,Object? products = null,Object? threadId = null,Object? threadName = null,Object? draft = null,Object? kind = null,Object? mood = null,Object? repost = freezed,Object? messageDraft = null,Object? commentDraft = null,Object? replyTo = null,Object? error = freezed,}) {
  return _then(_NexusState(
screen: null == screen ? _self.screen : screen // ignore: cast_nullable_to_non_nullable
as String,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subtype: null == subtype ? _self.subtype : subtype // ignore: cast_nullable_to_non_nullable
as String,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,profileTab: null == profileTab ? _self.profileTab : profileTab // ignore: cast_nullable_to_non_nullable
as String,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,discover: null == discover ? _self._discover : discover // ignore: cast_nullable_to_non_nullable
as List<Entry>,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<Entry>,notifications: null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<Entry>,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as Map<String, List<Entry>>,joined: null == joined ? _self.joined : joined // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,cart: null == cart ? _self._cart : cart // ignore: cast_nullable_to_non_nullable
as Map<String, int>,profile: null == profile ? _self._profile : profile // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,shop: null == shop ? _self._shop : shop // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,group: null == group ? _self._group : group // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<Entry>,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,threadName: null == threadName ? _self.threadName : threadName // ignore: cast_nullable_to_non_nullable
as String,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,mood: null == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String,repost: freezed == repost ? _self.repost : repost // ignore: cast_nullable_to_non_nullable
as Post?,messageDraft: null == messageDraft ? _self.messageDraft : messageDraft // ignore: cast_nullable_to_non_nullable
as String,commentDraft: null == commentDraft ? _self.commentDraft : commentDraft // ignore: cast_nullable_to_non_nullable
as String,replyTo: null == replyTo ? _self.replyTo : replyTo // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of NexusState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res>? get repost {
    if (_self.repost == null) {
    return null;
  }

  return $PostCopyWith<$Res>(_self.repost!, (value) {
    return _then(_self.copyWith(repost: value));
  });
}
}

// dart format on
