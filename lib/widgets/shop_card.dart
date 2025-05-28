import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ashop/providers/auth_provider.dart';
import 'package:ashop/utils/app_theme.dart';
import 'package:ashop/utils/constants.dart';

class ShopCard extends StatelessWidget {
  final Map<String, dynamic> shop;

  const ShopCard({
    super.key,
    required this.shop,
  });

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
    final salesTypes = (shop['salesTypes'] as List<dynamic>).cast<String>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to shop details
          // Will be implemented later
        },
        borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Shop Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Constants.defaultBorderRadius),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: shop['imageUrl'] != null
                    ? Image.network(
                        shop['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.store,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.store,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (shop['isVerified'] == true)
                        Icon(
                          Icons.verified,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Country
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        shop['country'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Sales Types
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: salesTypes.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getSalesTypeLabel(type, authProvider.currentLanguage),
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  if (shop['description'] != null &&
                      shop['description'].isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      shop['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Rating and Review Count
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        shop['rating']?.toStringAsFixed(1) ?? '0.0',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${shop['reviewCount'] ?? 0})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
