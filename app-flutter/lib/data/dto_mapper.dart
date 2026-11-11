/// Explicit adapter for Go core.Item/core.User/core.Activity JSON.
/// Missing presentation fields stay empty; IDs are never guessed from slugs.
class DtoMapper {
  DtoMapper({this.profileId = ''});
  String profileId;
  String id(dynamic value) {
    if (value is int && value > 0) return value.toString();
    if (value is String && value.isNotEmpty) return value;
    throw const FormatException('Missing backend ID');
  }

  Map<String, dynamic> profile(Map<String, dynamic> raw) {
    profileId = id(raw['id']);
    return {
      'id': profileId,
      'title': raw['name'] ?? '',
      'bio': raw['bio'] ?? '',
      'handle': '',
      'stats': <String>[],
      'email_verified': raw['email_verified'] ?? false,
    };
  }

  Map<String, dynamic> post(Map<String, dynamic> raw) => {
    'id': id(raw['id']),
    'kind': 'feel',
    'title': raw['name'] ?? '',
    'body': raw['body'] ?? '',
    'author': raw['author_id'] ?? '',
    'subtitle': raw['created_at'] ?? '',
  };
  Map<String, dynamic> item(Map<String, dynamic> raw, {String category = ''}) {
    final kind = raw['kind'] as String? ?? '';
    final person = kind == 'person' || kind == 'member';
    final itemId = person ? id(raw['author_id']) : id(raw['id']);
    final minor = raw['price_minor'] as int? ?? 0;
    final currency = raw['currency'] as String? ?? '';
    return {
      'id': itemId,
      'title': raw['name'] ?? '',
      'body': raw['body'] ?? '',
      'subtitle': raw['body'] ?? '',
      'category': category,
      'target': kind == 'shop'
          ? 'business'
          : kind == 'group'
          ? 'group'
          : '',
      'outgoing':
          kind == 'message' &&
          profileId.isNotEmpty &&
          raw['author_id'] == profileId,
      'price': currency.isEmpty
          ? ''
          : currency == 'MMK'
          ? '$minor K'
          : '${(minor / 100).toStringAsFixed(2)} $currency',
      'icon': person
          ? (raw['name'] as String? ?? '')
                .split(' ')
                .where((s) => s.isNotEmpty)
                .map((s) => s[0])
                .take(2)
                .join()
          : '',
    };
  }

  Map<String, dynamic> activity(Map<String, dynamic> raw) => {
    'id': id(raw['id']),
    'title': raw['body'] ?? '${raw['kind']} · ${raw['actor_id'] ?? ''}',
    'body': raw['body'] ?? '',
    'subtitle': raw['created_at'] ?? '',
    'category': raw['kind'] ?? '',
    'target': raw['item_id']?.toString() ?? '',
    'unread': raw['read'] != true,
  };
  Map<String, dynamic> detail(Map<String, dynamic> raw, {required bool shop}) =>
      {
        'id': id(raw['id']),
        'title': raw['name'] ?? '',
        'body': raw['body'] ?? '',
        'subtitle': raw['visibility'] ?? '',
        if (shop) ...{
          'contact': <dynamic>[],
          'reviews': <dynamic>[],
        } else ...{
          'rules': <String>[],
          'recent': <dynamic>[],
        },
      };
  Map<String, dynamic> page(
    Map<String, dynamic> raw,
    Map<String, dynamic> Function(Map<String, dynamic>) map,
  ) => {
    'items': (raw['items'] as List? ?? [])
        .map((v) => map(Map<String, dynamic>.from(v as Map)))
        .toList(),
    'next_cursor': raw['next_cursor'] ?? '',
  };
}
