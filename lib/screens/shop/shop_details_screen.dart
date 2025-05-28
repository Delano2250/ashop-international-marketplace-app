import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ashop/providers/auth_provider.dart';
import 'package:ashop/providers/shop_provider.dart';
import 'package:ashop/utils/app_theme.dart';
import 'package:ashop/utils/constants.dart';
import 'package:ashop/widgets/custom_button.dart';

class ShopDetailsScreen extends StatefulWidget {
  final String shopId;

  const ShopDetailsScreen({
    super.key,
    required this.shopId,
  });

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadShopDetails();
  }

  Future<void> _loadShopDetails() async {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    await shopProvider.loadShopDetails(widget.shopId);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteShop() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          authProvider.currentLanguage == 'fr'
              ? 'Supprimer la boutique'
              : authProvider.currentLanguage == 'es'
                  ? 'Eliminar tienda'
                  : 'Delete Shop',
        ),
        content: Text(
          authProvider.currentLanguage == 'fr'
              ? 'Êtes-vous sûr de vouloir supprimer cette boutique ? Cette action est irréversible.'
              : authProvider.currentLanguage == 'es'
                  ? '¿Estás seguro de que quieres eliminar esta tienda? Esta acción es irreversible.'
                  : 'Are you sure you want to delete this shop? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              authProvider.currentLanguage == 'fr'
                  ? 'Annuler'
                  : authProvider.currentLanguage == 'es'
                      ? 'Cancelar'
                      : 'Cancel',
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: Text(
              authProvider.currentLanguage == 'fr'
                  ? 'Supprimer'
                  : authProvider.currentLanguage == 'es'
                      ? 'Eliminar'
                      : 'Delete',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final success = await shopProvider.deleteShop(widget.shopId);

    if (mounted) {
      setState(() => _isDeleting = false);

      if (success) {
        Navigator.pop(context);
      } else if (shopProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shopProvider.error!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _getSalesTypeLabel(String type, String language) {
    switch (type) {
      case 'international':
        return language == 'fr'
            ? 'International'
            : language == 'es'
                ? 'Internacional'
                : 'International';
      case 'wholesale':
        return language == 'fr'
            ? 'Gros'
            : language == 'es'
                ? 'Mayorista'
                : 'Wholesale';
      case 'semi_wholesale':
        return language == 'fr'
            ? 'Demi-gros'
            : language == 'es'
                ? 'Semi-mayorista'
                : 'Semi-wholesale';
      case 'retail':
        return language == 'fr'
            ? 'Détail'
            : language == 'es'
                ? 'Minorista'
                : 'Retail';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);
    final shop = shopProvider.currentShop;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (shop == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            authProvider.currentLanguage == 'fr'
                ? 'Boutique non trouvée'
                : authProvider.currentLanguage == 'es'
                    ? 'Tienda no encontrada'
                    : 'Shop not found',
          ),
        ),
      );
    }

    final salesTypes = (shop['salesTypes'] as List<dynamic>).cast<String>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: shop['imageUrl'] != null
                  ? Image.network(
                      shop['imageUrl'],
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.store,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to edit shop screen
                  // Will be implemented later
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _isDeleting ? null : _deleteShop,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Constants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Name and Verification Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          shop['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (shop['isVerified'] == true)
                        Icon(
                          Icons.verified,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Country
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        shop['country'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sales Types
                  Text(
                    authProvider.currentLanguage == 'fr'
                        ? 'Types de vente'
                        : authProvider.currentLanguage == 'es'
                            ? 'Tipos de venta'
                            : 'Sales Types',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: salesTypes.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getSalesTypeLabel(type, authProvider.currentLanguage),
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  if (shop['description'] != null &&
                      shop['description'].isNotEmpty) ...[
                    const SizedBox(height: 24),

                    Text(
                      authProvider.currentLanguage == 'fr'
                          ? 'Description'
                          : authProvider.currentLanguage == 'es'
                              ? 'Descripción'
                              : 'Description',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      shop['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Statistics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatistic(
                        icon: Icons.star,
                        value: shop['rating']?.toStringAsFixed(1) ?? '0.0',
                        label: authProvider.currentLanguage == 'fr'
                            ? 'Note'
                            : authProvider.currentLanguage == 'es'
                                ? 'Calificación'
                                : 'Rating',
                        iconColor: Colors.amber[600],
                      ),
                      _buildStatistic(
                        icon: Icons.reviews_outlined,
                        value: (shop['reviewCount'] ?? 0).toString(),
                        label: authProvider.currentLanguage == 'fr'
                            ? 'Avis'
                            : authProvider.currentLanguage == 'es'
                                ? 'Reseñas'
                                : 'Reviews',
                      ),
                      _buildStatistic(
                        icon: Icons.shopping_bag_outlined,
                        value: (shop['orderCount'] ?? 0).toString(),
                        label: authProvider.currentLanguage == 'fr'
                            ? 'Commandes'
                            : authProvider.currentLanguage == 'es'
                                ? 'Pedidos'
                                : 'Orders',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistic({
    required IconData icon,
    required String value,
    required String label,
    Color? iconColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: iconColor ?? Colors.grey[600],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
