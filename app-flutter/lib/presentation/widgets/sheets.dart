import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/nexus_controller.dart';
import 'composer_sheet.dart';

void openSheet(BuildContext context, Widget child) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(child: child),
      ),
    );

void openComposer(BuildContext context, WidgetRef ref) {
  ref.read(nexusProvider.notifier).repost(null);
  openSheet(context, const ComposerSheet());
}
