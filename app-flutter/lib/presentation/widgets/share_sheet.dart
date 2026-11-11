import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../domain/models.dart';
import '../controllers/nexus_controller.dart';
import 'sheets.dart';
import 'composer_sheet.dart';

class ShareSheet extends ConsumerWidget {
  const ShareSheet({super.key, required this.post});
  final Post post;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(nexusProvider.notifier);
    final link = 'https://nexus.app/p/${post.id}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Share this post', style: Theme.of(context).textTheme.titleLarge),
        const Text('Anyone with the link can open it · public post'),
        Row(
          children: [
            Expanded(child: Text(link)),
            TextButton(
              onPressed: () => Clipboard.setData(ClipboardData(text: link)),
              child: const Text('Copy link'),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in const [
              ('Share to your profile', Icons.account_circle),
              ('Messenger', Icons.chat),
              ('Viber', Icons.call),
              ('Telegram', Icons.send),
              ('Facebook', Icons.public),
              ('Copy text', Icons.content_copy),
              ('Save post', Icons.bookmark_border),
              ('QR code', Icons.qr_code_2),
            ])
              SizedBox(
                width: 76,
                child: TextButton(
                  onPressed: () async {
                    switch (item.$1) {
                      case 'Share to your profile':
                        c.repost(post);
                        Navigator.pop(context);
                        openSheet(context, const ComposerSheet());
                      case 'Copy text':
                        await Clipboard.setData(
                          ClipboardData(text: '${post.body}\n$link'),
                        );
                      case 'Save post':
                        await c.save(post);
                      case 'QR code':
                        if (context.mounted) {
                          showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('QR code'),
                              content: SizedBox(
                                width: 240,
                                height: 240,
                                child: QrImageView(
                                  data: link,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }
                      default:
                        await SharePlus.instance.share(
                          ShareParams(
                            text: '${post.body}\n$link',
                            title: item.$1,
                          ),
                        );
                        await c.share(post, item.$1);
                    }
                  },
                  child: Column(
                    children: [
                      Icon(item.$2),
                      Text(
                        item.$1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
