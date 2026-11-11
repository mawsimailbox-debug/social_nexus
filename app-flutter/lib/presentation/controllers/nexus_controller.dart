import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_client.dart';
import '../../data/scoped_repository.dart';
import '../../domain/models.dart';
import '../../domain/repository.dart';
import 'providers.dart';

final nexusProvider = NotifierProvider<NexusController, NexusState>(
  NexusController.new,
);
final rankedPostsProvider = Provider((ref) {
  final s = ref.watch(nexusProvider);
  return ref.watch(repositoryProvider).isDemo
      ? rankPosts(s.posts, s.filter)
      : s.posts;
});
final discoverResultsProvider = Provider((ref) {
  final s = ref.watch(nexusProvider);
  return s.discover
      .where((e) => (s.subtype == 'all' || e.subtype == s.subtype))
      .toList();
});
final canPostProvider = Provider(
  (ref) => ref.watch(
    nexusProvider.select(
      (s) => s.draft.trim().length >= 3 && s.draft.length <= 200 && !s.busy,
    ),
  ),
);

class NexusController extends Notifier<NexusState> {
  late NexusRepository repo;
  int _discoverRevision = 0;
  @override
  NexusState build() {
    var active = true;
    ref.onDispose(() {
      active = false;
    });
    repo = ScopedRepository(ref.read(repositoryProvider), () => active);
    return const NexusState();
  }

  List<Entry> entries(dynamic data) => (data as List? ?? [])
      .map((e) => Entry.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
  Future<void> guard(Future<void> Function() action) async {
    if (!ref.mounted) return;
    state = state.copyWith(error: null);
    try {
      await action();
    } on RequestCancelled {
      return;
    } catch (e) {
      if (ref.mounted) state = state.copyWith(error: e.toString());
    }
  }

  Future<void> load() => guard(() async {
    state = state.copyWith(busy: true);
    try {
      final profile = await repo.get('/users/me');
      final data = await Future.wait([
        repo.get('/feed'),
        repo.get('/discover', query: {'type': state.category}),
        repo.get('/chat/threads'),
        repo.get('/shops'),
        repo.get('/groups'),
      ]);
      final threads = entries(data[2]['items']),
          shops = entries(data[3]['items']),
          groups = entries(data[4]['items']);
      state = state.copyWith(
        profile: profile,
        posts: (data[0]['items'] as List? ?? [])
            .map((p) => Post.fromJson(Map<String, dynamic>.from(p as Map)))
            .toList(),
        discover: entries(data[1]['items']),
        threadId: threads.isEmpty ? '' : threads.first.id,
        threadName: threads.isEmpty ? '' : threads.first.title,
      );
      if (shops.isNotEmpty) await openShop(shops.first.id);
      if (groups.isNotEmpty) await openGroup(groups.first.id);
      if (state.threadId.isNotEmpty) {
        final messages = await repo.get(
          '/chat/threads/${state.threadId}/messages',
        );
        state = state.copyWith(messages: entries(messages['items']));
      }
      // Activity is optional in Go; a 404 is displayed, never replaced with demo data.
      try {
        final notes = await repo.get('/notifications');
        state = state.copyWith(notifications: entries(notes['items']));
      } on ApiException catch (e) {
        if (e.status == 404) {
          state = state.copyWith(
            error:
                'Notifications unavailable: backend ActivityStore route is not deployed. ${e.requestId ?? ''}',
          );
        } else {
          rethrow;
        }
      }
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  });
  Future<void> openShop(String id) async {
    final shop = await repo.get('/shops/$id');
    final products = await repo.get('/shops/$id/products');
    state = state.copyWith(shop: shop, products: entries(products['items']));
  }

  Future<void> openGroup(String id) async {
    final group = await repo.get('/groups/$id');
    state = state.copyWith(group: group);
  }

  Future<void> openEntry(Entry entry) => guard(() async {
    if (entry.target == 'business') {
      await openShop(entry.id);
      go('business');
    } else if (entry.target == 'group') {
      await openGroup(entry.id);
      go('group');
    }
  });
  void go(String screen) => state = state.copyWith(screen: screen);
  void filter(String value) => state = state.copyWith(filter: value);
  Future<void> _discover() async {
    final revision = ++_discoverRevision;
    final category = state.category, query = state.query;
    final result = await repo.get(
      '/discover',
      query: {'type': category, 'q': query},
    );
    if (revision == _discoverRevision) {
      state = state.copyWith(discover: entries(result['items']));
    }
  }

  Future<void> category(String value) => guard(() async {
    state = state.copyWith(category: value, subtype: 'all', discover: []);
    await _discover();
  });
  void subtype(String value) => state = state.copyWith(subtype: value);
  Future<void> query(String value) => guard(() async {
    state = state.copyWith(query: value);
    await _discover();
  });
  void profileTab(String value) => state = state.copyWith(profileTab: value);
  void draft(String value) => state = state.copyWith(draft: value);
  void kind(String value) => state = state.copyWith(kind: value);
  void mood(String value) => state = state.copyWith(mood: value);
  void messageDraft(String value) =>
      state = state.copyWith(messageDraft: value);
  void commentDraft(String value) =>
      state = state.copyWith(commentDraft: value);
  void reply(Entry entry) => state = state.copyWith(replyTo: entry.title);
  void repost(Post? post) => state = state.copyWith(repost: post, draft: '');
  void clearError() => state = state.copyWith(error: null);
  void updatePost(Post post) => state = state.copyWith(
    posts: state.posts.map((p) => p.id == post.id ? post : p).toList(),
  );
  Future<void> like(Post post) => guard(() async {
    await repo.send(
      '/items/${post.id}/like',
      {},
      method: post.liked ? 'DELETE' : 'PUT',
    );
    updatePost(
      post.copyWith(
        liked: !post.liked,
        likes: post.likes + (post.liked ? -1 : 1),
      ),
    );
  });
  Future<void> save(Post post) => guard(() async {
    await repo.send(
      '/items/${post.id}/save',
      {},
      method: post.saved ? 'DELETE' : 'PUT',
    );
    updatePost(post.copyWith(saved: !post.saved));
  });
  Future<void> publish() => guard(() async {
    if (state.busy ||
        state.draft.trim().length < 3 ||
        state.draft.length > 200) {
      return;
    }
    if (!repo.isDemo && (state.repost != null || state.kind != 'feel')) {
      throw UnsupportedError(
        'Backend does not persist post type, media, mood, location or repost attribution yet.',
      );
    }
    final draft = state.draft.trim();
    final repost = state.repost;
    final mood = state.mood;
    state = state.copyWith(busy: true);
    try {
      final data = await repo.send('/feed', {
        'name': repo.isDemo ? mood : '',
        'body': draft,
        'visibility': 'public',
      });
      final post = Post(
        id: data['id'].toString(),
        kind: 'feel',
        body: draft,
        title: repo.isDemo ? mood.toUpperCase() : '',
        author: state.profile['title'] as String? ?? '',
        score: 99,
        originalId: repost?.id,
        originalAuthor: repost?.author,
        originalBody: repost?.body,
      );
      state = state.copyWith(
        posts: [post, ...state.posts],
        screen: 'feed',
        draft: '',
        repost: null,
      );
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  });
  Future<void> comments(Post post) => guard(() async {
    final data = await repo.get('/feed/${post.id}/comments');
    state = state.copyWith(
      comments: {...state.comments, post.id: entries(data['items'])},
      replyTo: '',
    );
  });
  Future<void> sendComment(Post post) => guard(() async {
    if (state.commentDraft.trim().isEmpty) return;
    final body = state.commentDraft.trim();
    final result = await repo.send('/feed/${post.id}/comments', {'body': body});
    state = state.copyWith(
      comments: {
        ...state.comments,
        post.id: [
          ...?state.comments[post.id],
          Entry(
            id: result['id'].toString(),
            title: state.profile['title'] as String? ?? '',
            body: body,
            subtitle: 'now',
          ),
        ],
      },
      commentDraft: '',
      replyTo: '',
    );
    final current = state.posts.firstWhere((p) => p.id == post.id);
    updatePost(current.copyWith(comments: current.comments + 1));
  });
  Future<void> likeComment(Post post, Entry entry) => guard(() async {
    await repo.send(
      '/items/${entry.id}/like',
      {},
      method: entry.selected ? 'DELETE' : 'PUT',
    );
    state = state.copyWith(
      comments: {
        ...state.comments,
        post.id: state.comments[post.id]!
            .map(
              (e) => e.id == entry.id ? e.copyWith(selected: !e.selected) : e,
            )
            .toList(),
      },
    );
  });
  Future<void> sendMessage() => guard(() async {
    final text = state.messageDraft.trim();
    if (text.isEmpty) return;
    if (state.threadId.isEmpty) {
      throw StateError('No backend chat thread available');
    }
    final result = await repo.send('/chat/threads/${state.threadId}/messages', {
      'body': text,
    });
    state = state.copyWith(
      messages: [
        ...state.messages,
        Entry(id: result['id'].toString(), body: text, outgoing: true),
      ],
      messageDraft: '',
    );
  });
  Future<void> toggleEntry(Entry entry) => guard(() async {
    if (entry.category == 'groups') {
      await repo.send(
        '/groups/${entry.id}/join',
        {},
        method: entry.selected ? 'DELETE' : 'POST',
      );
    } else {
      await repo.send(
        entry.category == 'people'
            ? '/users/${entry.id}/follow'
            : '/items/${entry.id}/follow',
        {},
        method: entry.selected ? 'DELETE' : 'PUT',
      );
    }
    state = state.copyWith(
      discover: state.discover
          .map((e) => e.id == entry.id ? e.copyWith(selected: !e.selected) : e)
          .toList(),
    );
  });
  Future<void> join(bool joined) => guard(() async {
    final id = state.group['id'];
    if (id == null) throw StateError('No backend group available');
    await repo.send('/groups/$id/join', {}, method: joined ? 'POST' : 'DELETE');
    state = state.copyWith(joined: joined);
  });
  Future<void> addProduct(Entry product) => guard(() async {
    final quantity = (state.cart[product.id] ?? 0) + 1;
    await repo.send('/cart/${product.id}', {
      'quantity': quantity,
    }, method: 'PUT');
    state = state.copyWith(cart: {...state.cart, product.id: quantity});
  });
  Future<void> markRead([Entry? entry]) => guard(() async {
    final list = entry == null
        ? state.notifications.where((e) => e.unread).toList()
        : [entry];
    for (final n in list) {
      await repo.send('/notifications/${n.id}/read', {}, method: 'PATCH');
      state = state.copyWith(
        notifications: state.notifications
            .map((e) => e.id == n.id ? e.copyWith(unread: false) : e)
            .toList(),
      );
    }
  });
  Future<void> share(Post post, String channel) => guard(() async {
    await repo.send('/items/${post.id}/shares', {});
    updatePost(post.copyWith(shares: post.shares + 1));
  });
  Future<void> editProfile(String bio) => guard(() async {
    final profile = await repo.send('/users/me', {'bio': bio}, method: 'PATCH');
    state = state.copyWith(
      profile: repo.isDemo ? {...state.profile, 'bio': bio} : profile,
    );
  });
  Future<void> saveShop() => guard(() async {
    final id = state.shop['id'];
    if (id == null) throw StateError('No backend shop available');
    await repo.send('/items/$id/save', {}, method: 'PUT');
  });
}
