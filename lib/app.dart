import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:listen/core/constants/app_theme.dart';
import 'package:listen/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:listen/features/auth/presentation/bloc/auth_event.dart';
import 'package:listen/features/auth/presentation/bloc/auth_state.dart';
import 'package:listen/features/auth/presentation/screens/login_page.dart';
import 'package:listen/features/auth/presentation/screens/register_page.dart';
import 'package:listen/features/history/presentation/screens/history_page.dart';
import 'package:listen/features/split_screen/presentation/screens/split_screen_page.dart';

class ListenApp extends StatelessWidget {
  const ListenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<AuthBloc>()..add(AuthCheckRequested()),
      child: MaterialApp(
        title: 'Listen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) return const HomePage();
            return const LoginPage();
          },
        ),
        routes: {
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/home': (_) => const HomePage(),
          //'/split-screen': (_) => const SplitScreenPage(),
          //'/history': (_) => const HistoryPage(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text(
          'LISTEN',
          style: TextStyle(
            color: Color(0xFF00FF41),
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF00FF41)),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF4DFF4D)),
            onPressed:
                () => context.read<AuthBloc>().add(AuthSignOutRequested()),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'REAL-TIME TRANSLATION',
              style: TextStyle(
                color: Color(0xFF4DFF4D),
                fontSize: 11,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 48),
            _ModeCard(
              label: 'SPLIT SCREEN',
              subtitle: 'Place phone between two people',
              icon: Icons.screen_rotation,
              onTap: () => Navigator.pushNamed(context, '/split-screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          border: Border.all(color: const Color(0xFF00FF41), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00FF41), size: 36),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF00FF41),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF4DFF4D), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
