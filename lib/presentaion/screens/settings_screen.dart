import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/utils/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/utils/location_service.dart';
import 'package:ella_lyaabdoon/utils/location_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _dropdownContainer(BuildContext context, Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: child,
    );
  }

  // helper function
  Future<String?> _getCityFromStorage() async {
    final lat = await LocationStorage.getLat();
    final lng = await LocationStorage.getLng();

    if (lat != null && lng != null) {
      return await LocationService.getCity(lat, lng);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppServicesDBprovider.isDark();
    final currentLocale = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text('settings_screen'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// THEME
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('theme'.tr()),
            trailing: _dropdownContainer(
              context,
              DropdownButtonHideUnderline(
                child: DropdownButton<ThemeMode>(
                  value: isDark ? ThemeMode.dark : ThemeMode.light,
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('light'.tr()),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('dark'.tr()),
                    ),
                  ],
                  onChanged: (_) {
                    AppServicesDBprovider.switchTheme();
                  },
                ),
              ),
            ),
          ),

          const Divider(),

          /// LANGUAGE
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('language'.tr()),
            trailing: _dropdownContainer(
              context,
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentLocale,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  ],
                  onChanged: (lang) {
                    if (lang == null) return;
                    context.setLocale(Locale(lang));
                    AppServicesDBprovider.changeLocale(lang);
                  },
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text('location'.tr()),
            subtitle: FutureBuilder<String?>(
              future:
                  _getCityFromStorage(), // call a method that returns Future<String?>
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading'.tr());
                }
                return Text(snapshot.data ?? 'Not set'.tr());
              },
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final position = await LocationService.determinePosition();
              final city = await LocationService.getCity(
                position.latitude,
                position.longitude,
              );

              await LocationStorage.saveLocation(
                position.latitude,
                position.longitude,
              );

              setState(() {}); // لتحديث FutureBuilder
            },
          ),

          const Divider(height: 32),

          /// DEVELOPER INFO
          ExpansionTile(
            title: Text('developer_info'.tr()),
            leading: const Icon(Icons.person),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: CachedNetworkImageProvider(
                  'https://avatars.githubusercontent.com/u/53038487?v=4',
                ),
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('GitHub'),
                subtitle: const Text('amrabdelhameeed'),
                onTap: () => _launch('https://github.com/amrabdelhameeed'),
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text('LinkedIn'),
                subtitle: const Text('amrabdelhameeed'),
                onTap: () =>
                    _launch('https://www.linkedin.com/in/amrabdelhameeed/'),
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('WhatsApp'),
                subtitle: const Text('+201121009270'),
                onTap: () => _launch('https://wa.me/201121009270'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
