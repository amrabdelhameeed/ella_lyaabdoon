import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/utils/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/utils/location_service.dart';
import 'package:ella_lyaabdoon/utils/location_storage.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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

  void _showVideoDialog(BuildContext context) {
    final controller = YoutubePlayerController(
      initialVideoId: 'Hxz9g5Z6MMg',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: AppServicesDBprovider.currentLocale() == 'en'
            ? true
            : false,
        useHybridComposition: true,
      ),
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Video',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: AspectRatio(
                aspectRatio: 9 / 16, // Portrait
                child: YoutubePlayer(
                  controller: controller,
                  showVideoProgressIndicator: true,
                ),
              ),
            ),
          ),
        );
      },
    );
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
            leading: Icon(Icons.brightness_6),
            // contentPadding: EdgeInsets.zero,
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
            leading: Icon(Icons.language),
            // contentPadding: EdgeInsets.zero,
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

          const Divider(height: 32),

          ListTile(
            leading: const Icon(Icons.play_circle_fill),
            title: Text('app_idea_video_title'.tr()),
            subtitle: Text('app_idea_video_subtitle'.tr()),

            onTap: () => _showVideoDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('sadqah_garyah'.tr()),
            onTap: () {
              SharePlus.instance.share(
                ShareParams(
                  title: 'sadqah_garyah'.tr(),
                  text: "I am using Ella Lyaabdoon app",
                  subject: 'sadqah_garyah'.tr(),
                  // uri: Uri.parse(
                  //   'https://github.com/amrabdelhameeed/ella_lyaabdoon',
                  // ),
                ),
              );
            },
          ),
          const Divider(),
          ExpansionTile(
            title: Text('list_of_contributors'.tr()),
            leading: const Icon(Icons.assignment_rounded),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: Icon(Icons.circle, size: 5),
                title: Text('خالد فؤاد عوض'),
              ),
              ListTile(
                leading: Icon(Icons.circle, size: 5),
                title: Text('لوشا'),
              ),
            ],
          ),
          const Divider(),

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
                subtitle: Text('for_suggestions_and_complaints'.tr()),
                onTap: () => _launch('https://wa.me/201121009270'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
