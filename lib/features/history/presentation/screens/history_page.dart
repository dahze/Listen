import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:listen/core/constants/app_colors.dart';
import 'package:listen/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:listen/features/auth/presentation/bloc/auth_state.dart';
import 'package:listen/features/conversation/domain/entities/message.dart';
import 'package:listen/features/conversation/domain/entities/session.dart';
import 'package:listen/features/conversation/domain/usecases/delete_session.dart';
import 'package:listen/features/conversation/domain/usecases/get_sessions.dart';
import 'package:listen/features/history/presentation/bloc/history_bloc.dart';
import 'package:listen/features/history/presentation/bloc/history_event.dart';
import 'package:listen/features/history/presentation/bloc/history_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    return BlocProvider(
      create:
          (_) => HistoryBloc(
            getSessions: GetIt.instance<GetSessions>(),
            deleteSession: GetIt.instance<DeleteSession>(),
          )..add(HistoryLoadRequested(userId)),
      child: _HistoryView(userId: userId),
    );
  }
}

class _HistoryView extends StatelessWidget {
  final String userId;
  const _HistoryView({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HISTORY',
          style: TextStyle(
            color: AppColors.kPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.kTextSecondary),
            onPressed:
                () => context.read<HistoryBloc>().add(
                  HistoryLoadRequested(userId),
                ),
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          return switch (state) {
            HistoryInitial() || HistoryLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.kPrimary),
            ),
            HistoryError(:final message) => _ErrorView(
              message: message,
              onRetry:
                  () => context.read<HistoryBloc>().add(
                    HistoryLoadRequested(userId),
                  ),
            ),
            HistoryLoaded(:final sessions) =>
              sessions.isEmpty
                  ? const _EmptyView()
                  : _SessionList(sessions: sessions, userId: userId),
          };
        },
      ),
    );
  }
}

// ── Session list ─────────────────────────────────────────────────────────────

class _SessionList extends StatelessWidget {
  final List<Session> sessions;
  final String userId;

  const _SessionList({required this.sessions, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _SessionTile(session: session, userId: userId);
      },
    );
  }
}

// ── Session tile ─────────────────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  final Session session;
  final String userId;

  const _SessionTile({required this.session, required this.userId});

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Session session) {
    if (session.endedAt == null) return '--:--';
    final diff = session.endedAt!.difference(session.createdAt);
    final m = diff.inMinutes.toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.kSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColors.kError),
            ),
            title: const Text(
              'DELETE SESSION?',
              style: TextStyle(
                color: AppColors.kError,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            content: const Text(
              'This cannot be undone.',
              style: TextStyle(color: AppColors.kTextSecondary, fontSize: 12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: AppColors.kTextSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<HistoryBloc>().add(
                    HistorySessionDeleted(
                      userId: userId,
                      sessionId: session.id,
                    ),
                  );
                },
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: AppColors.kError),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSessionDetail(context),
      onLongPress: () => _confirmDelete(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.kPrimaryDim),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speaker names
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.kPrimary, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${session.speakerAName}  ↔  ${session.speakerBName}',
                  style: const TextStyle(
                    color: AppColors.kTextPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Metadata row
            Row(
              children: [
                _MetaChip(
                  icon: Icons.calendar_today,
                  label: _formatDate(session.createdAt),
                ),
                const SizedBox(width: 12),
                _MetaChip(icon: Icons.timer, label: _formatDuration(session)),
                const SizedBox(width: 12),
                _MetaChip(
                  icon: Icons.chat_bubble_outline,
                  label: '${session.messageCount} msgs',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Tap/long-press hints
            const Text(
              'TAP to view  ·  HOLD to delete',
              style: TextStyle(
                color: AppColors.kTextDisabled,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        side: BorderSide(color: AppColors.kPrimary),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            expand: false,
            builder:
                (_, scrollController) => _SessionDetailSheet(
                  session: session,
                  scrollController: scrollController,
                ),
          ),
    );
  }
}

// ── Session detail bottom sheet ───────────────────────────────────────────────

class _SessionDetailSheet extends StatelessWidget {
  final Session session;
  final ScrollController scrollController;

  const _SessionDetailSheet({
    required this.session,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.kPrimaryDim,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.history, color: AppColors.kPrimary, size: 16),
              const SizedBox(width: 8),
              Text(
                '${session.speakerAName}  ↔  ${session.speakerBName}',
                style: const TextStyle(
                  color: AppColors.kPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.kPrimaryDim, height: 1),
        // Messages
        Expanded(
          child:
              session.messages.isEmpty
                  ? const Center(
                    child: Text(
                      'NO MESSAGES',
                      style: TextStyle(
                        color: AppColors.kTextDisabled,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                  )
                  : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: session.messages.length,
                    itemBuilder:
                        (_, i) =>
                            _HistoryMessageTile(message: session.messages[i]),
                  ),
        ),
      ],
    );
  }
}

// ── History message tile ─────────────────────────────────────────────────────

class _HistoryMessageTile extends StatelessWidget {
  final Message message;
  const _HistoryMessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kSurfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speaker + timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                message.speakerName.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.kPrimary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                _formatTime(message.timestamp),
                style: const TextStyle(
                  color: AppColors.kTextDisabled,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Original
          Text(
            message.originalText,
            style: const TextStyle(color: AppColors.kTextPrimary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: AppColors.kSurfaceLight),
          const SizedBox(height: 6),
          // Translation
          Row(
            children: [
              const Icon(
                Icons.translate,
                color: AppColors.kTextSecondary,
                size: 12,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  message.translatedText,
                  style: const TextStyle(
                    color: AppColors.kTextSecondary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.kTextSecondary, size: 11),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.kTextSecondary, fontSize: 10),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, color: AppColors.kTextDisabled, size: 48),
          SizedBox(height: 16),
          Text(
            'NO SESSIONS YET',
            style: TextStyle(
              color: AppColors.kTextDisabled,
              fontSize: 11,
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start a conversation to see it here',
            style: TextStyle(color: AppColors.kTextDisabled, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.kError, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.kError, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.kPrimary),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'RETRY',
                style: TextStyle(
                  color: AppColors.kPrimary,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
