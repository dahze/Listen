import 'dart:async';
import 'package:flutter/material.dart';
import 'package:listen/core/constants/app_colors.dart';

class DividerBar extends StatefulWidget {
  final VoidCallback onEndSession;
  final DateTime sessionStart;

  const DividerBar({
    super.key,
    required this.onEndSession,
    required this.sessionStart,
  });

  @override
  State<DividerBar> createState() => _DividerBarState();
}

class _DividerBarState extends State<DividerBar> {
  late Timer _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.sessionStart);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(widget.sessionStart);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _timerText {
    final m = _elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onTap(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.kSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColors.kPrimary),
            ),
            title: const Text(
              'END SESSION?',
              style: TextStyle(
                color: AppColors.kPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            content: const Text(
              'This conversation will be saved to history.',
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
                  widget.onEndSession();
                },
                child: const Text(
                  'END',
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
      onTap: () => _onTap(context),
      child: Container(
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.kSurface,
          border: Border.symmetric(
            horizontal: BorderSide(color: AppColors.kPrimary, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Timer
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                _timerText,
                style: const TextStyle(
                  color: AppColors.kTextSecondary,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
            ),
            // App name
            const Text(
              'L I S T E N',
              style: TextStyle(
                color: AppColors.kPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
            // End hint
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                'TAP TO END',
                style: TextStyle(
                  color: AppColors.kTextDisabled,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
