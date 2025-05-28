import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ashop/providers/auth_provider.dart';
import 'package:ashop/screens/auth/register_screen.dart';
import 'package:ashop/screens/home/home_screen.dart';
import 'package:ashop/utils/app_theme.dart';
import 'package:ashop/utils/constants.dart';
import 'package:ashop/widgets/custom_button.dart';
import 'package:ashop/widgets/custom_text_field.dart';
import 'package:ashop/widgets/language_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Constants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language Selector
                Align(
                  alignment: Alignment.topRight,
                  child: LanguageSelector(
                    currentLanguage: authProvider.currentLanguage,
                    onChanged: (language) {
                      authProvider.setLanguage(language);
                    },
                  ),
                ),

                SizedBox(height: size.height * 0.08),

                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Welcome Text
                Text(
                  authProvider.currentLanguage == 'fr'
                      ? 'Bienvenue sur ASHOP'
                      : authProvider.currentLanguage == 'es'
                          ? 'Bienvenido a ASHOP'
                          : 'Welcome to ASHOP',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  authProvider.currentLanguage == 'fr'
                      ? 'Connectez-vous pour continuer'
                      : authProvider.currentLanguage == 'es'
                          ? 'Inicia sesión para continuar'
                          : 'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        label: authProvider.currentLanguage == 'fr'
                            ? 'Email'
                            : authProvider.currentLanguage == 'es'
                                ? 'Correo electrónico'
                                : 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return authProvider.currentLanguage == 'fr'
                                ? 'L\'email est requis'
                                : authProvider.currentLanguage == 'es'
                                    ? 'El correo electrónico es requerido'
                                    : 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return authProvider.currentLanguage == 'fr'
                                ? 'Email invalide'
                                : authProvider.currentLanguage == 'es'
                                    ? 'Correo electrónico inválido'
                                    : 'Invalid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _passwordController,
                        label: authProvider.currentLanguage == 'fr'
                            ? 'Mot de passe'
                            : authProvider.currentLanguage == 'es'
                                ? 'Contraseña'
                                : 'Password',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return authProvider.currentLanguage == 'fr'
                                ? 'Le mot de passe est requis'
                                : authProvider.currentLanguage == 'es'
                                    ? 'La contraseña es requerida'
                                    : 'Password is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      CustomButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        text: authProvider.currentLanguage == 'fr'
                            ? 'Se connecter'
                            : authProvider.currentLanguage == 'es'
                                ? 'Iniciar sesión'
                                : 'Sign In',
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 16),

                      // Register Link
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          authProvider.currentLanguage == 'fr'
                              ? 'Pas de compte ? Inscrivez-vous'
                              : authProvider.currentLanguage == 'es'
                                  ? '¿No tienes cuenta? Regístrate'
                                  : 'No account? Sign up',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
