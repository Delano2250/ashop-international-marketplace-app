class Constants {
  // App Information
  static const String appName = 'ASHOP';
  static const String appVersion = '1.0.0';

  // API Endpoints (to be replaced with actual endpoints)
  static const String baseUrl = 'https://api.ashop.com';
  static const String apiVersion = '/v1';

  // Shop Types
  static const List<String> salesTypes = [
    'international',
    'wholesale',
    'semi_wholesale',
    'retail',
  ];

  // Subscription Plans
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'basic': {
      'name': 'Basic',
      'price': 9.99,
      'features': [
        'Create one shop',
        'Basic analytics',
        'Standard support',
      ],
      'commission_rate': 0.05, // 5%
    },
    'premium': {
      'name': 'Premium',
      'price': 29.99,
      'features': [
        'Create multiple shops',
        'Advanced analytics',
        'Priority support',
        'Promotional features',
      ],
      'commission_rate': 0.03, // 3%
    },
    'enterprise': {
      'name': 'Enterprise',
      'price': 99.99,
      'features': [
        'Unlimited shops',
        'Premium analytics',
        '24/7 support',
        'Custom features',
        'Lowest commission rates',
      ],
      'commission_rate': 0.02, // 2%
    },
  };

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxShopNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxProductsPerShop = 1000;

  // Image Settings
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const double thumbnailQuality = 0.7;

  // Cache Settings
  static const int cacheDuration = 7; // days
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultSpacing = 8.0;
  static const double defaultIconSize = 24.0;
  static const double defaultAvatarSize = 40.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Error Messages
  static const Map<String, String> errorMessages = {
    'fr': {
      'network_error': 'Erreur de connexion. Veuillez vérifier votre connexion internet.',
      'invalid_credentials': 'Email ou mot de passe incorrect.',
      'weak_password': 'Le mot de passe doit contenir au moins 8 caractères.',
      'email_in_use': 'Cet email est déjà utilisé.',
      'invalid_shop_name': 'Nom de boutique invalide.',
      'upload_failed': 'Échec du téléchargement de l\'image.',
    },
    'en': {
      'network_error': 'Connection error. Please check your internet connection.',
      'invalid_credentials': 'Invalid email or password.',
      'weak_password': 'Password must be at least 8 characters long.',
      'email_in_use': 'This email is already in use.',
      'invalid_shop_name': 'Invalid shop name.',
      'upload_failed': 'Failed to upload image.',
    },
    'es': {
      'network_error': 'Error de conexión. Por favor, compruebe su conexión a internet.',
      'invalid_credentials': 'Correo electrónico o contraseña incorrectos.',
      'weak_password': 'La contraseña debe tener al menos 8 caracteres.',
      'email_in_use': 'Este correo electrónico ya está en uso.',
      'invalid_shop_name': 'Nombre de tienda inválido.',
      'upload_failed': 'Error al cargar la imagen.',
    },
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'fr': {
      'login_success': 'Connexion réussie',
      'register_success': 'Inscription réussie',
      'shop_created': 'Boutique créée avec succès',
      'profile_updated': 'Profil mis à jour avec succès',
    },
    'en': {
      'login_success': 'Login successful',
      'register_success': 'Registration successful',
      'shop_created': 'Shop created successfully',
      'profile_updated': 'Profile updated successfully',
    },
    'es': {
      'login_success': 'Inicio de sesión exitoso',
      'register_success': 'Registro exitoso',
      'shop_created': 'Tienda creada con éxito',
      'profile_updated': 'Perfil actualizado con éxito',
    },
  };
}
