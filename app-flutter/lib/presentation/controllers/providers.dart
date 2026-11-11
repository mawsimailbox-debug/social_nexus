import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository.dart';

final repositoryProvider = Provider<NexusRepository>(
  (ref) => throw StateError('Repository must be injected'),
);
