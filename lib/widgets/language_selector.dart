import 'package:flutter/material.dart';
import 'package:ashop/utils/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onChanged;

  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: currentLanguage,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        _buildLanguageItem(
          'fr',
          'Français',
          'assets/icons/fr_flag.png',
        ),
        _buildLanguageItem(
          'en',
          'English',
          'assets/icons/en_flag.png',
        ),
        _buildLanguageItem(
          'es',
          'Español',
          'assets/icons/es_flag.png',
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getLanguageLabel(currentLanguage),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildLanguageItem(
    String code,
    String label,
    String flagAsset,
  ) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                flagAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: currentLanguage == code
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: currentLanguage == code
                  ? AppTheme.primaryColor
                  : null,
            ),
          ),
          if (currentLanguage == code) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.check,
              size: 16,
              color: AppTheme.primaryColor,
            ),
          ],
        ],
      ),
    );
  }

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Français';
    }
  }
}
