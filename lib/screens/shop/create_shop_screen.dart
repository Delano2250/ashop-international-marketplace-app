import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:ashop/providers/auth_provider.dart';
import 'package:ashop/providers/shop_provider.dart';
import 'package:ashop/utils/app_theme.dart';
import 'package:ashop/utils/constants.dart';
import 'package:ashop/widgets/custom_button.dart';
import 'package:ashop/widgets/custom_text_field.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCountry = '';
  final List<String> _selectedSalesTypes = [];
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<AuthProvider>(context, listen: false).currentLanguage ==
                      'fr'
                  ? 'Erreur lors de la sélection de l\'image'
                  : Provider.of<AuthProvider>(context, listen: false)
                              .currentLanguage ==
                          'es'
                      ? 'Error al seleccionar la imagen'
                      : 'Error selecting image',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _createShop() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<AuthProvider>(context, listen: false).currentLanguage ==
                    'fr'
                ? 'Veuillez sélectionner un pays'
                : Provider.of<AuthProvider>(context, listen: false)
                            .currentLanguage ==
                        'es'
                    ? 'Por favor seleccione un país'
                    : 'Please select a country',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    if (_selectedSalesTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<AuthProvider>(context, listen: false).currentLanguage ==
                    'fr'
                ? 'Veuillez sélectionner au moins un type de vente'
                : Provider.of<AuthProvider>(context, listen: false)
                            .currentLanguage ==
                        'es'
                    ? 'Por favor seleccione al menos un tipo de venta'
                    : 'Please select at least one sales type',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);

      final success = await shopProvider.createShop(
        userId: authProvider.user!.uid,
        name: _nameController.text.trim(),
        country: _selectedCountry,
        salesTypes: _selectedSalesTypes,
        description: _descriptionController.text.trim(),
        imageFile: _selectedImage,
      );

      if (mounted) {
        setState(() => _isLoading = false);

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
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<AuthProvider>(context, listen: false).currentLanguage ==
                      'fr'
                  ? 'Une erreur est survenue'
                  : Provider.of<AuthProvider>(context, listen: false)
                              .currentLanguage ==
                          'es'
                      ? 'Ha ocurrido un error'
                      : 'An error occurred',
            ),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          authProvider.currentLanguage == 'fr'
              ? 'Créer une boutique'
              : authProvider.currentLanguage == 'es'
                  ? 'Crear tienda'
                  : 'Create Shop',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Constants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(Constants.defaultBorderRadius),
                          child: Image.network(
                            _selectedImage!.path,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              authProvider.currentLanguage == 'fr'
                                  ? 'Ajouter une image'
                                  : authProvider.currentLanguage == 'es'
                                      ? 'Agregar imagen'
                                      : 'Add Image',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Shop Name
              CustomTextField(
                controller: _nameController,
                label: authProvider.currentLanguage == 'fr'
                    ? 'Nom de la boutique'
                    : authProvider.currentLanguage == 'es'
                        ? 'Nombre de la tienda'
                        : 'Shop Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return authProvider.currentLanguage == 'fr'
                        ? 'Le nom est requis'
                        : authProvider.currentLanguage == 'es'
                            ? 'El nombre es requerido'
                            : 'Name is required';
                  }
                  if (value.length > Constants.maxShopNameLength) {
                    return authProvider.currentLanguage == 'fr'
                        ? 'Le nom est trop long'
                        : authProvider.currentLanguage == 'es'
                            ? 'El nombre es demasiado largo'
                            : 'Name is too long';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Country Selector
              ListTile(
                title: Text(
                  _selectedCountry.isEmpty
                      ? (authProvider.currentLanguage == 'fr'
                          ? 'Sélectionner un pays'
                          : authProvider.currentLanguage == 'es'
                              ? 'Seleccionar país'
                              : 'Select Country')
                      : _selectedCountry,
                  style: TextStyle(
                    color: _selectedCountry.isEmpty ? Colors.grey : null,
                  ),
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: false,
                    countryListTheme: CountryListThemeData(
                      borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                    ),
                    onSelect: (Country country) {
                      setState(() {
                        _selectedCountry = country.name;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Sales Types
              Text(
                authProvider.currentLanguage == 'fr'
                    ? 'Types de vente'
                    : authProvider.currentLanguage == 'es'
                        ? 'Tipos de venta'
                        : 'Sales Types',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Constants.salesTypes.map((type) {
                  final isSelected = _selectedSalesTypes.contains(type);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(_getSalesTypeLabel(type, authProvider.currentLanguage)),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSalesTypes.add(type);
                        } else {
                          _selectedSalesTypes.remove(type);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: authProvider.currentLanguage == 'fr'
                    ? 'Description'
                    : authProvider.currentLanguage == 'es'
                        ? 'Descripción'
                        : 'Description',
                maxLines: 4,
                hint: authProvider.currentLanguage == 'fr'
                    ? 'Décrivez votre boutique...'
                    : authProvider.currentLanguage == 'es'
                        ? 'Describe tu tienda...'
                        : 'Describe your shop...',
                validator: (value) {
                  if (value != null && value.length > Constants.maxDescriptionLength) {
                    return authProvider.currentLanguage == 'fr'
                        ? 'La description est trop longue'
                        : authProvider.currentLanguage == 'es'
                            ? 'La descripción es demasiado larga'
                            : 'Description is too long';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Create Button
              CustomButton(
                onPressed: _isLoading ? null : _createShop,
                text: authProvider.currentLanguage == 'fr'
                    ? 'Créer la boutique'
                    : authProvider.currentLanguage == 'es'
                        ? 'Crear tienda'
                        : 'Create Shop',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
