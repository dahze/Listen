import 'package:flutter/material.dart';
import 'package:listen/core/constants/app_colors.dart';
import 'package:listen/features/conversation/domain/entities/message.dart';
import 'package:listen/features/split_screen/presentation/bloc/panel_state.dart';
import 'message_bubble.dart';

class SpeakerPanel extends StatefulWidget {
  final String speakerId;
  final String speakerName;
  final PanelState panelState;
  final bool isLocked;
  final List<Message> messages;
  final VoidCallback onMicTap;
  final void Function(String transcript, String detectedLang) onConfirm;
  final VoidCallback onRedo;
  final VoidCallback onDiscard;

  const SpeakerPanel({
    super.key,
    required this.speakerId,
    required this.speakerName,
    required this.panelState,
    required this.isLocked,
    required this.messages,
    required this.onMicTap,
    required this.onConfirm,
    required this.onRedo,
    required this.onDiscard,
  });

  @override
  State<SpeakerPanel> createState() => _SpeakerPanelState();
}

class _SpeakerPanelState extends State<SpeakerPanel>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(SpeakerPanel old) {
    super.didUpdateWidget(old);
    // Scroll to bottom when a new message is added.
    if (widget.messages.length != old.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.kBackground,
      child: Column(
        children: [
          // ── Speaker name header ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.kSurface,
            child: Text(
              widget.speakerName.toUpperCase(),
              style: const TextStyle(
                color: AppColors.kTextSecondary,
                fontSize: 10,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ── Message list ─────────────────────────────────────────────
          Expanded(
            child:
                widget.messages.isEmpty
                    ? Center(
                      child: Text(
                        'TAP THE MIC TO START',
                        style: TextStyle(
                          color: AppColors.kTextDisabled,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.messages.length,
                      itemBuilder:
                          (_, i) => MessageBubble(
                            message: widget.messages[i],
                            panelSpeakerId: widget.speakerId,
                          ),
                    ),
          ),

          // ── Active state controls ────────────────────────────────────
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final state = widget.panelState;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.kSurface,
      child: switch (state) {
        PanelIdle() => _buildMicButton(),
        PanelListening() => _buildListeningUI('LISTENING...'),
        PanelTranscribing(:final partialText) => _buildTranscribingUI(
          partialText,
        ),
        PanelPendingConfirmation(:final transcript, :final detectedLang) =>
          _buildConfirmationUI(transcript, detectedLang),
        PanelTranslating() => _buildTranslatingUI(),
      },
    );
  }

  // ── Idle ─────────────────────────────────────────────────────────────────

  Widget _buildMicButton() {
    final locked = widget.isLocked;
    return Center(
      child: GestureDetector(
        onTap: locked ? null : widget.onMicTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: locked ? AppColors.kGreenMuted : AppColors.kBackground,
            border: Border.all(
              color: locked ? AppColors.kTextDisabled : AppColors.kPrimary,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.mic,
            color: locked ? AppColors.kTextDisabled : AppColors.kPrimary,
            size: 28,
          ),
        ),
      ),
    );
  }

  // ── Listening ─────────────────────────────────────────────────────────────

  Widget _buildListeningUI(String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.kGreenMuted,
              border: Border.all(color: AppColors.kAccent, width: 2),
            ),
            child: const Icon(Icons.mic, color: AppColors.kAccent, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.kTextSecondary,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  // ── Transcribing ──────────────────────────────────────────────────────────

  Widget _buildTranscribingUI(String partialText) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildListeningUI('TRANSCRIBING...'),
        if (partialText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.kBackground,
              border: Border.all(color: AppColors.kPrimaryDim),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              partialText,
              style: const TextStyle(
                color: AppColors.kTextPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Pending confirmation ──────────────────────────────────────────────────

  Widget _buildConfirmationUI(String transcript, String detectedLang) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transcript display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.kBackground,
            border: Border.all(color: AppColors.kPrimaryDim),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            transcript.isEmpty ? '(no speech detected)' : transcript,
            style: const TextStyle(color: AppColors.kTextPrimary, fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: '✓  SEND',
                color: AppColors.kPrimary,
                textColor: AppColors.kBackground,
                onTap:
                    transcript.isEmpty
                        ? null
                        : () => widget.onConfirm(transcript, detectedLang),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                label: '↺  REDO',
                color: AppColors.kSurfaceLight,
                textColor: AppColors.kTextPrimary,
                onTap: widget.onRedo,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                label: '✕  DISCARD',
                color: AppColors.kSurfaceLight,
                textColor: AppColors.kError,
                onTap: widget.onDiscard,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Translating ───────────────────────────────────────────────────────────

  Widget _buildTranslatingUI() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            color: AppColors.kPrimary,
            strokeWidth: 2,
          ),
        ),
        SizedBox(width: 12),
        Text(
          'TRANSLATING...',
          style: TextStyle(
            color: AppColors.kTextSecondary,
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ── Shared action button ─────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.kPrimaryDim),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
