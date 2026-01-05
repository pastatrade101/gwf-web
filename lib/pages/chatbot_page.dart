import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/chatbot_controller.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';

class ChatbotPage extends StatelessWidget {
  ChatbotPage({super.key});

  final ChatbotController c = Get.put(ChatbotController(), permanent: false);
  final TextEditingController input = TextEditingController();
  final ScrollController scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bg;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text("GWF Assistant", style: AppTextStyles.appBar),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final items = c.messages;
              if (c.loading.value && items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePadding,
                  AppDimens.md,
                  AppDimens.pagePadding,
                  AppDimens.lg,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final msg = items[i];
                  return _MessageBubble(message: msg);
                },
              );
            }),
          ),
          _InputBar(
            controller: input,
            onSend: () {
              c.sendMessage(input.text);
              input.clear();
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (!scroll.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scroll.animateTo(
        scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final align = message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bg = message.isUser
        ? AppColors.primary
        : (isDark ? AppColors.cardDark : AppColors.card);
    final textColor = message.isUser ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);
    final border = isDark ? AppColors.borderDark : AppColors.border;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.smPlus),
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.smPlus),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: message.isUser ? null : Border.all(color: border),
        ),
        child: Text(
          message.text,
          style: AppTextStyles.body.copyWith(color: textColor, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.card;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final hint = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.sm, AppDimens.pagePadding, AppDimens.sm),
        decoration: BoxDecoration(
          color: card,
          border: Border(top: BorderSide(color: border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: "Type your question...",
                  hintStyle: TextStyle(color: hint),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: AppDimens.smPlus),
            IconButton(
              onPressed: onSend,
              icon: Icon(Icons.send_rounded, color: AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
