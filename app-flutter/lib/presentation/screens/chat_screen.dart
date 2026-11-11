import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/nexus_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(nexusProvider), c = ref.read(nexusProvider.notifier);
    void notice(String message) =>
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    return Column(
      children: [
        Container(
          color: Tokens.soft,
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () => c.go('feed'),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              const ClipOval(child: Photo(width: 38, height: 38)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.threadName,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Active now',
                      style: TextStyle(color: Color(0xFF79DCA8), fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Voice call',
                onPressed: () => notice('Voice call'),
                icon: const Icon(Icons.call, size: 21),
              ),
              IconButton(
                tooltip: 'Video call',
                onPressed: () => notice('Video call'),
                icon: const Icon(Icons.videocam, size: 21),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              const Center(
                child: Chip(
                  label: Text(
                    'TODAY · 19:38',
                    style: TextStyle(fontSize: 10.5),
                  ),
                ),
              ),
              for (final m in s.messages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                    alignment: m.outgoing
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 248),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 13,
                      ),
                      decoration: BoxDecoration(
                        color: m.outgoing
                            ? Tokens.tan
                            : const Color(0xFF272C2F),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(m.outgoing ? 16 : 5),
                          bottomRight: Radius.circular(m.outgoing ? 5 : 16),
                        ),
                      ),
                      child: Text(
                        m.body,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: m.outgoing
                              ? const Color(0xFF20150F)
                              : const Color(0xFFECEEEF),
                        ),
                      ),
                    ),
                  ),
                ),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Seen 19:42',
                  style: TextStyle(color: Tokens.muted, fontSize: 10.5),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Tokens.soft,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Attach',
                onPressed: () => notice('Attach'),
                icon: const Icon(Icons.add_circle_outline),
              ),
              Expanded(
                child: NativeInput(
                  value: s.messageDraft,
                  onChanged: c.messageDraft,
                  hint: 'Message…',
                  onSubmitted: c.sendMessage,
                ),
              ),
              IconButton(
                tooltip: 'Emoji',
                onPressed: () => c.messageDraft('${s.messageDraft} 🙂'),
                icon: const Icon(Icons.sentiment_satisfied_alt),
              ),
              IconButton.filled(
                tooltip: 'Send message',
                onPressed: c.sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
