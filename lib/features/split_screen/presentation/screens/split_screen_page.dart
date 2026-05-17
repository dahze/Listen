import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:listen/core/constants/app_colors.dart';
import 'package:listen/core/di/injection_container.dart';
import 'package:listen/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:listen/features/auth/presentation/bloc/auth_state.dart';
import 'package:listen/features/conversation/domain/usecases/add_message.dart';
import 'package:listen/features/conversation/domain/usecases/create_session.dart';
import 'package:listen/features/conversation/domain/usecases/end_session.dart';
import 'package:listen/features/speech/presentation/bloc/speech_bloc.dart';
import 'package:listen/features/speech/presentation/bloc/speech_event.dart';
import 'package:listen/features/translation/presentation/bloc/translation_bloc.dart';
import 'package:listen/features/split_screen/presentation/bloc/split_screen_bloc.dart';
import 'package:listen/features/split_screen/presentation/bloc/split_screen_event.dart';
import 'package:listen/features/split_screen/presentation/bloc/split_screen_state.dart';
import 'package:listen/features/split_screen/presentation/bloc/panel_state.dart';
import 'package:listen/features/split_screen/presentation/widgets/speaker_panel.dart';
import 'package:listen/features/split_screen/presentation/widgets/divider_bar.dart';

class SplitScreenPage extends StatefulWidget {
  const SplitScreenPage({super.key});

  @override
  State<SplitScreenPage> createState() => _SplitScreenPageState();
}

class _SplitScreenPageState extends State<SplitScreenPage> {
  late final SpeechBloc _speechBloc;
  late final TranslationBloc _translationBloc;
  late final SplitScreenBloc _splitScreenBloc;

  final _nameAController = TextEditingController();
  final _nameBController = TextEditingController();

  DateTime _sessionStart = DateTime.now();

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    _speechBloc = sl<SpeechBloc>();
    _translationBloc = sl<TranslationBloc>();

    _splitScreenBloc = SplitScreenBloc(
      speechBloc: _speechBloc,
      translationBloc: _translationBloc,
      createSession: sl<CreateSession>(),
      addMessage: sl<AddMessage>(),
      endSession: sl<EndSession>(),
      userId: userId,
    );

    // Request mic permission then show names dialog.
    _speechBloc.add(const SpeechPermissionRequested());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNamesDialog();
    });
  }

  @override
  void dispose() {
    _splitScreenBloc.close();
    _speechBloc.close();
    _translationBloc.close();
    _nameAController.dispose();
    _nameBController.dispose();
    super.dispose();
  }

  void _showNamesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.kSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColors.kPrimary),
            ),
            title: const Text(
              'WHO IS SPEAKING?',
              style: TextStyle(
                color: AppColors.kPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Names are optional — tap Skip to use defaults.',
                  style: TextStyle(
                    color: AppColors.kTextSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),
                _NameField(
                  controller: _nameAController,
                  label: 'Speaker A (top panel)',
                ),
                const SizedBox(height: 12),
                _NameField(
                  controller: _nameBController,
                  label: 'Speaker B (bottom panel)',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _startSession('', '');
                },
                child: const Text(
                  'SKIP',
                  style: TextStyle(color: AppColors.kTextSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _startSession(_nameAController.text, _nameBController.text);
                },
                child: const Text(
                  'START',
                  style: TextStyle(color: AppColors.kPrimary),
                ),
              ),
            ],
          ),
    );
  }

  void _startSession(String nameA, String nameB) {
    _sessionStart = DateTime.now();
    _splitScreenBloc.add(
      SessionStartRequested(speakerAName: nameA, speakerBName: nameB),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _splitScreenBloc),
        BlocProvider.value(value: _speechBloc),
        BlocProvider.value(value: _translationBloc),
      ],
      child: Scaffold(
        backgroundColor: AppColors.kBackground,
        body: BlocListener<SplitScreenBloc, SplitScreenState>(
          listener: (context, state) {
            if (state is SplitScreenEnded) {
              Navigator.pop(context);
            }
            if (state is SplitScreenError) {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      backgroundColor: AppColors.kSurface,
                      title: const Text(
                        'ERROR',
                        style: TextStyle(color: AppColors.kError),
                      ),
                      content: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.kTextSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'OK',
                            style: TextStyle(color: AppColors.kPrimary),
                          ),
                        ),
                      ],
                    ),
              );
            }
          },
          child: BlocBuilder<SplitScreenBloc, SplitScreenState>(
            builder: (context, state) {
              if (state is SplitScreenLoading || state is SplitScreenInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.kPrimary),
                );
              }

              if (state is! SplitScreenActive) {
                return const SizedBox.shrink();
              }

              return SafeArea(
                child: Column(
                  children: [
                    // ── Panel A (Speaker A — normal orientation) ──────────
                    Expanded(
                      child: SpeakerPanel(
                        speakerId: 'A',
                        speakerName: state.speakerAName,
                        panelState: state.panelA,
                        isLocked: state.activeSpeaker == 'B',
                        messages: state.messages,
                        onMicTap:
                            () => context.read<SplitScreenBloc>().add(
                              const MicTapped('A'),
                            ),
                        onConfirm:
                            (t, l) => context.read<SplitScreenBloc>().add(
                              TranscriptConfirmed(
                                speakerId: 'A',
                                transcript: t,
                                detectedLang: l,
                              ),
                            ),
                        onRedo:
                            () => context.read<SplitScreenBloc>().add(
                              const RedoRequested('A'),
                            ),
                        onDiscard:
                            () => context.read<SplitScreenBloc>().add(
                              const TranscriptDiscarded('A'),
                            ),
                      ),
                    ),

                    // ── Divider ───────────────────────────────────────────
                    DividerBar(
                      sessionStart: _sessionStart,
                      onEndSession:
                          () => context.read<SplitScreenBloc>().add(
                            const SessionEnded(),
                          ),
                    ),

                    // ── Panel B (Speaker B — rotated 180°) ────────────────
                    Expanded(
                      child: Transform.rotate(
                        angle: math.pi,
                        child: SpeakerPanel(
                          speakerId: 'B',
                          speakerName: state.speakerBName,
                          panelState: state.panelB,
                          isLocked: state.activeSpeaker == 'A',
                          messages: state.messages,
                          onMicTap:
                              () => context.read<SplitScreenBloc>().add(
                                const MicTapped('B'),
                              ),
                          onConfirm:
                              (t, l) => context.read<SplitScreenBloc>().add(
                                TranscriptConfirmed(
                                  speakerId: 'B',
                                  transcript: t,
                                  detectedLang: l,
                                ),
                              ),
                          onRedo:
                              () => context.read<SplitScreenBloc>().add(
                                const RedoRequested('B'),
                              ),
                          onDiscard:
                              () => context.read<SplitScreenBloc>().add(
                                const TranscriptDiscarded('B'),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Name input field ─────────────────────────────────────────────────────────

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _NameField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kSurfaceLight,
        border: Border.all(color: AppColors.kPrimaryDim),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.kTextPrimary, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColors.kTextSecondary,
            fontSize: 10,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}
