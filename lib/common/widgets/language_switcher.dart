import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/services/locale_service.dart';
import 'package:praxis/generated/l10n.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = Get.find<LocaleService>();
    final s = S.of(context);
    
    return Obx(() => PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: s.language,
      onSelected: (locale) => localeService.changeLocale(locale),
      itemBuilder: (context) => LocaleService.supportedLocales.map((locale) {
        final isSelected = localeService.isCurrentLocale(locale);
        return PopupMenuItem<Locale>(
          value: locale,
          child: Row(
            children: [
              if (isSelected) 
                const Icon(Icons.check, size: 20)
              else 
                const SizedBox(width: 20),
              const SizedBox(width: 8),
              Text(localeService.getLocaleName(locale)),
            ],
          ),
        );
      }).toList(),
    ));
  }
}

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = Get.find<LocaleService>();
    final s = S.of(context);
    
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.language,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ...LocaleService.supportedLocales.map((locale) {
          final isSelected = localeService.isCurrentLocale(locale);
          return ListTile(
            leading: Radio<Locale>(
              value: locale,
              groupValue: localeService.locale,
              onChanged: (locale) {
                if (locale != null) {
                  localeService.changeLocale(locale);
                }
              },
            ),
            title: Text(localeService.getLocaleName(locale)),
            onTap: () => localeService.changeLocale(locale),
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    ));
  }
}