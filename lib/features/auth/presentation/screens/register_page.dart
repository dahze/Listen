import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listen/core/constants/app_colors.dart';
import 'package:listen/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:listen/features/auth/presentation/bloc/auth_event.dart';
import 'package:listen/features/auth/presentation/bloc/auth_state.dart';
import 'package:listen/features/auth/presentation/widgets/terminal_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.4);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.kBackground,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.kError,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),

                          Text(
                            'LISTEN',
                            style: TextStyle(
                              color: AppColors.kPrimary,
                              fontSize: (32 * scale).clamp(24, 42),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                            ),
                          ),
                          SizedBox(height: 6 * scale),
                          Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              color: AppColors.kTextSecondary,
                              fontSize: (10 * scale).clamp(8, 13),
                              letterSpacing: 4,
                            ),
                          ),

                          SizedBox(height: 48 * scale),

                          _buildField(
                            controller: _emailController,
                            label: 'Email',
                            obscure: false,
                            scale: scale,
                            keyboardType: TextInputType.emailAddress,
                            validator:
                                (v) =>
                                    v == null || v.isEmpty
                                        ? 'Enter your email'
                                        : !v.contains('@')
                                        ? 'Enter a valid email'
                                        : null,
                          ),
                          SizedBox(height: 16 * scale),
                          _buildField(
                            controller: _passwordController,
                            label: 'Password',
                            obscure: _obscurePassword,
                            scale: scale,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.kTextSecondary,
                                size: (18 * scale).clamp(14, 24),
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                            ),
                            validator:
                                (v) =>
                                    v == null || v.length < 6
                                        ? 'Min 6 characters'
                                        : null,
                          ),
                          SizedBox(height: 16 * scale),
                          _buildField(
                            controller: _confirmController,
                            label: 'Confirm Password',
                            obscure: _obscureConfirm,
                            scale: scale,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.kTextSecondary,
                                size: (18 * scale).clamp(14, 24),
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Confirm your password';
                              if (v != _passwordController.text)
                                return 'Passwords do not match';
                              return null;
                            },
                          ),

                          SizedBox(height: 32 * scale),

                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return TerminalButton(
                                label: 'REGISTER',
                                scale: scale,
                                color: AppColors.kPrimary,
                                labelColor: AppColors.kBackground,
                                fullWidth: true,
                                isLoading: state is AuthLoading,
                                onTap: state is AuthLoading ? null : _onSubmit,
                              );
                            },
                          ),

                          const Spacer(),

                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Already have an account?  Sign in',
                                style: TextStyle(
                                  color: AppColors.kTextSecondary,
                                  fontSize: (10 * scale).clamp(8, 12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16 * scale),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required double scale,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kSurfaceLight,
        border: Border.all(color: AppColors.kPrimaryDim),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.none,
        style: TextStyle(
          color: AppColors.kTextPrimary,
          fontSize: (13 * scale).clamp(11, 16),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.kTextSecondary,
            fontSize: (10 * scale).clamp(8, 12),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(14 * scale),
          suffixIcon: suffixIcon,
          errorStyle: TextStyle(
            color: AppColors.kError,
            fontSize: (8 * scale).clamp(7, 10),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
