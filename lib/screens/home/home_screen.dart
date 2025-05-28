import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ashop/providers/auth_provider.dart';
import 'package:ashop/providers/shop_provider.dart';
import 'package:ashop/screens/shop/create_shop_screen.dart';
import 'package:ashop/utils/app_theme.dart';
import 'package:ashop/utils/constants.dart';
import 'package:ashop/widgets/custom_button.dart';
import 'package:ashop/widgets/shop_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    await shopProvider.loadUserShops(authProvider.user!.uid);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _getWelcomeMessage(AuthProvider authProvider) {
    final name = authProvider.userData?['name'] ?? '';
    switch (authProvider.currentLanguage) {
      case 'fr':
        return 'Bienvenue, $name';
      case 'es':
        return 'Bienvenido, $name';
      default:
        return 'Welcome, $name';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);
    final shops = shopProvider.shops;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getWelcomeMessage(authProvider)),
        actions: [
          // Language Selector
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    authProvider.currentLanguage == 'fr'
                        ? 'Choisir la langue'
                        : authProvider.currentLanguage == 'es'
                            ? 'Elegir idioma'
                            : 'Choose Language',
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Français'),
                        leading: Radio<String>(
                          value: 'fr',
                          groupValue: authProvider.currentLanguage,
                          onChanged: (value) {
                            authProvider.setLanguage(value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('English'),
                        leading: Radio<String>(
                          value: 'en',
                          groupValue: authProvider.currentLanguage,
                          onChanged: (value) {
                            authProvider.setLanguage(value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Español'),
                        leading: Radio<String>(
                          value: 'es',
                          groupValue: authProvider.currentLanguage,
                          onChanged: (value) {
                            authProvider.setLanguage(value!);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Profile Menu
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await authProvider.signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      authProvider.currentLanguage == 'fr'
                          ? 'Déconnexion'
                          : authProvider.currentLanguage == 'es'
                              ? 'Cerrar sesión'
                              : 'Logout',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.defaultPadding,
                    vertical: Constants.defaultPadding / 2,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Tous', 'All', 'Todos'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'international',
                        'International',
                        'International',
                        'Internacional',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'wholesale',
                        'Gros',
                        'Wholesale',
                        'Mayorista',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'retail',
                        'Détail',
                        'Retail',
                        'Minorista',
                      ),
                    ],
                  ),
                ),

                // Shop List
                Expanded(
                  child: shops.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.store_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                authProvider.currentLanguage == 'fr'
                                    ? 'Vous n\'avez pas encore de boutique'
                                    : authProvider.currentLanguage == 'es'
                                        ? 'Aún no tienes tiendas'
                                        : 'You don\'t have any shops yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              CustomButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CreateShopScreen(),
                                    ),
                                  );
                                },
                                text: authProvider.currentLanguage == 'fr'
                                    ? 'Créer une boutique'
                                    : authProvider.currentLanguage == 'es'
                                        ? 'Crear tienda'
                                        : 'Create Shop',
                                icon: Icons.add,
                                width: 200,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadShops,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(Constants.defaultPadding),
                            itemCount: shops.length,
                            itemBuilder: (context, index) {
                              final shop = shops[index];
                              if (_selectedFilter != 'all' &&
                                  !shop['salesTypes'].contains(_selectedFilter)) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ShopCard(shop: shop),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: shops.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateShopScreen(),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFilterChip(
    String value,
    String frLabel,
    String enLabel,
    String esLabel,
  ) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    String label;
    switch (authProvider.currentLanguage) {
      case 'fr':
        label = frLabel;
        break;
      case 'es':
        label = esLabel;
        break;
      default:
        label = enLabel;
    }

    return FilterChip(
      selected: _selectedFilter == value,
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: _selectedFilter == value
            ? AppTheme.primaryColor
            : Colors.grey[800],
        fontWeight: _selectedFilter == value
            ? FontWeight.w600
            : FontWeight.normal,
      ),
    );
  }
}
