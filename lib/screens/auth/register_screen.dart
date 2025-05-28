import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ashop/providers/auth_provider.dart';
import 'package:ashop/screens/home/home_screen.dart';
import 'package:ashop/utils/app_theme.dart';
import 'package:ashop/utils/constants.dart';
import 'package:ashop/widgets/custom_button.dart';
import 'package:ashop/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
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
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    String getTitle() {
      switch (authProvider.currentLanguage) {
        case 'fr':
          return 'Créer un compte';
        case 'es':
          return 'Crear una cuenta';
        default:
          return 'Create Account';
      }
    }

    String getSubtitle() {
      switch (authProvider.currentLanguage) {
        case 'fr':
          return 'Rejoignez ASHOP et commencez à vendre';
        case 'es':
          return 'Únete a ASHOP y empieza a vender';
        default:
          return 'Join ASHOP and start selling';
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Constants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.02),

                // Title
                Text(
                  getTitle(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  getSubtitle(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: size.height * 0.04),

                // Registration Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name Field
                      CustomTextField(
                        controller: _nameController,
                        label: authProvider.currentLanguage == 'fr'
                            ? 'Nom complet'
                            : authProvider.currentLanguage == 'es'
                                ? 'Nombre completo'
                                : 'Full Name',
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return authProvider.currentLanguage == 'fr'
                                ? 'Le nom est requis'
                                : authProvider.currentLanguage == 'es'
                                    ? 'El nombre es requerido'
                                    : 'Name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
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

                      // Password Field
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
                          if (value.length < Constants.minPasswordLength) {
                            return authProvider.currentLanguage == 'fr'
                                ? 'Le mot de passe doit contenir au moins ${Constants.minPasswordLength} caractères'
                                : authProvider.currentLanguage == 'es'
                                    ? 'La contraseña debe tener al menos ${Constants.minPasswordLength} caracteres'
                                    : 'Password must be at least ${Constants.minPasswordLength} characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password Field
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: authProvider.currentLanguage == 'fr'
                            ? 'Confirmer le mot de passe'
                            : authProvider.currentLanguage == 'es'
                                ? 'Confirmar contraseña'
                                : 'Confirm Password',
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return authProvider.currentLanguage == 'fr'
                                ? 'La confirmation du mot de passe est requise'
                                : authProvider.currentLanguage == 'es'
                                    ? 'La confirmación de la contraseña es requerida'
                                    : 'Password confirmation is required';
                          }
                          if (value != _passwordController.text) {
                            return authProvider.currentLanguage == 'fr'
                                ? 'Les mots de passe ne correspondent pas'
                                : authProvider.currentLanguage == 'es'
                                    ? 'Las contraseñas no coinciden'
                                    : 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Register Button
                      CustomButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        text: authProvider.currentLanguage == 'fr'
                            ? 'S\'inscrire'
                            : authProvider.currentLanguage == 'es'
                                ? 'Registrarse'
                                : 'Sign Up',
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 16),

                      // Login Link
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          authProvider.currentLanguage == 'fr'
                              ? 'Déjà un compte ? Connectez-vous'
                              : authProvider.currentLanguage == 'es'
                                  ? '¿Ya tienes una cuenta? Inicia sesión'
                                  : 'Already have an account? Sign in',
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
