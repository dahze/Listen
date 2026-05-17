import 'package:flutter/material.dart';
import 'package:listen/core/constants/app_colors.dart';
import 'package:listen/features/conversation/domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String panelSpeakerId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.panelSpeakerId,
  });

  bool get _isOwn => message.speakerId == panelSpeakerId;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isOwn ? AppColors.kGreenMuted : AppColors.kSurfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(_isOwn ? 12 : 2),
            bottomRight: Radius.circular(_isOwn ? 2 : 12),
          ),
          border: Border.all(
            color: _isOwn ? AppColors.kPrimaryDim : AppColors.kSurfaceLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speaker name
            Text(
              message.speakerName,
              style: const TextStyle(
                color: AppColors.kTextSecondary,
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // Original text
            Text(
              message.originalText,
              style: const TextStyle(
                color: AppColors.kTextPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            // Divider
            Container(height: 1, color: AppColors.kPrimaryDim.withOpacity(0.3)),
            const SizedBox(height: 6),
            // Translated text
            Text(
              message.translatedText,
              style: const TextStyle(
                color: AppColors.kTextSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            // Timestamp
            Text(
              _formatTime(message.timestamp),
              style: const TextStyle(
                color: AppColors.kTextDisabled,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
