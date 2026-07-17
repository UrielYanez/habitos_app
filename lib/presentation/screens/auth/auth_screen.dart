import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vita_habit/config/config.dart';
import 'package:vita_habit/presentation/providers/providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { login, register }

class _AuthScreenState extends ConsumerState<AuthScreen> {
  AuthMode _authMode = AuthMode.login;
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _autovalidate = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // Validadores
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Ingresa un correo válido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
    if (_authMode == AuthMode.login) return null;
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe contener una mayúscula';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Debe contener un número';
    return null;
  }

  String? _validateName(String? value) {
    if (_authMode == AuthMode.login) return null;
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() => _autovalidate = true);
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authNotifierProvider.notifier);

    if (_authMode == AuthMode.login) {
      await notifier.signIn(_emailCtrl.text, _passwordCtrl.text);
    } else {
      await notifier.signUp(
        _emailCtrl.text,
        _passwordCtrl.text,
        _nameCtrl.text,
      );
    }

    final authState = ref.read(authNotifierProvider);
    authState.whenOrNull(
      error: (e, _) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppTheme.pending,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      data: (_) {
        if (mounted) context.go(AppConstants.homeRoute);
      },
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailDialogCtrl = TextEditingController(text: _emailCtrl.text);
    final dialogFormKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Recuperar contraseña',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                _Field(
                  controller: emailDialogCtrl,
                  hint: 'Correo electrónico',
                  icon: Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: () async {
                if (!dialogFormKey.currentState!.validate()) return;
                final email = emailDialogCtrl.text;
                Navigator.pop(ctx);
                await ref
                    .read(authNotifierProvider.notifier)
                    .resetPassword(email);
                if (mounted) {
                  final state = ref.read(authNotifierProvider);
                  if (state.hasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.error}'),
                        backgroundColor: AppTheme.pending,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Se ha enviado el enlace a tu correo.'),
                        backgroundColor: AppTheme.completed,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Enviar enlace',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryDark,
              AppTheme.primary,
              AppTheme.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo & Header
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.appTagline,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Auth Card (Glassmorphism inspired)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppTheme.surface.withValues(alpha: 0.98),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _authMode == AuthMode.login
                                  ? 'Bienvenido de nuevo'
                                  : 'Crea tu cuenta',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Nombre (solo registro)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: animation,
                                      child: child,
                                    ),
                                  ),
                              child: _authMode == AuthMode.register
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: _Field(
                                        key: const ValueKey('name_field'),
                                        controller: _nameCtrl,
                                        hint: 'Nombre completo',
                                        icon: Icons.person_outline_rounded,
                                        validator: _validateName,
                                      ),
                                    )
                                  : const SizedBox.shrink(
                                      key: ValueKey('name_empty'),
                                    ),
                            ),

                            // Email
                            _Field(
                              controller: _emailCtrl,
                              hint: 'Correo electrónico',
                              icon: Icons.email_outlined,
                              keyboard: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),

                            // Contraseña
                            _Field(
                              controller: _passwordCtrl,
                              hint: 'Contraseña',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePass,
                              validator: _validatePassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePass = !_obscurePass,
                                ),
                              ),
                            ),

                            // Forgot password
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _authMode == AuthMode.login
                                  ? Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _showForgotPasswordDialog,
                                        child: const Text(
                                          '¿Olvidaste tu contraseña?',
                                          style: TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(height: 24),
                            ),

                            // Botón principal
                            FilledButton(
                              onPressed: isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _authMode == AuthMode.login
                                          ? 'Iniciar Sesión'
                                          : 'Registrarse',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),

                            // Switch mode
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _authMode == AuthMode.login
                                      ? '¿No tienes cuenta?'
                                      : '¿Ya tienes cuenta?',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _authMode = _authMode == AuthMode.login
                                          ? AuthMode.register
                                          : AuthMode.login;
                                      _autovalidate = false;
                                      _formKey.currentState?.reset();
                                    });
                                  },
                                  child: Text(
                                    _authMode == AuthMode.login
                                        ? 'Regístrate'
                                        : 'Inicia Sesión',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _Field({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.obscure = false,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, size: 22, color: AppTheme.textSecondary),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.pending, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.pending, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}
