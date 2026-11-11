import 'package:freezed_annotation/freezed_annotation.dart';
part 'models.freezed.dart';
part 'models.g.dart';

@freezed
abstract class Post with _$Post {
  const factory Post({
    required String id,
    required String kind,
    required String body,
    @Default('') String title,
    @Default('') String author,
    @Default('') String subtitle,
    @Default('') String location,
    @Default('') String reason,
    @Default('') String tags,
    @Default('') String music,
    @Default(0) int score,
    @Default(false) bool nearby,
    @Default(false) bool friend,
    @Default(0) int likes,
    @Default(0) int comments,
    @Default(0) int shares,
    @Default(false) bool liked,
    @Default(false) bool saved,
    String? originalId,
    String? originalAuthor,
    String? originalBody,
  }) = _Post;
  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

@freezed
abstract class Entry with _$Entry {
  const factory Entry({
    required String id,
    @Default('') String title,
    @Default('') String subtitle,
    @Default('') String body,
    @Default('') String category,
    @Default('') String subtype,
    @Default('') String icon,
    @Default('') String target,
    @Default('') String action,
    @Default('') String price,
    @Default(false) bool selected,
    @Default(false) bool unread,
    @Default(false) bool outgoing,
  }) = _Entry;
  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
}

@freezed
abstract class Session with _$Session {
  const factory Session({required String jwt, required String refresh}) =
      _Session;
  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default('login') String stage,
    @Default('') String phone,
    @Default('') String email,
    @Default('') String otp,
    @Default(0) int resendSeconds,
    @Default('') String verificationStatus,
    @Default(false) bool busy,
    String? error,
  }) = _AuthState;
}

@freezed
abstract class NexusState with _$NexusState {
  const factory NexusState({
    @Default('feed') String screen,
    @Default('foryou') String filter,
    @Default('groups') String category,
    @Default('all') String subtype,
    @Default('') String query,
    @Default('videos') String profileTab,
    @Default([]) List<Post> posts,
    @Default([]) List<Entry> discover,
    @Default([]) List<Entry> messages,
    @Default([]) List<Entry> notifications,
    @Default({}) Map<String, List<Entry>> comments,
    @Default(false) bool joined,
    @Default(false) bool busy,
    @Default({}) Map<String, int> cart,
    @Default({}) Map<String, dynamic> profile,
    @Default({}) Map<String, dynamic> shop,
    @Default({}) Map<String, dynamic> group,
    @Default([]) List<Entry> products,
    @Default('') String threadId,
    @Default('') String threadName,
    @Default('') String draft,
    @Default('feel') String kind,
    @Default('Grateful') String mood,
    Post? repost,
    @Default('') String messageDraft,
    @Default('') String commentDraft,
    @Default('') String replyTo,
    String? error,
  }) = _NexusState;
}
