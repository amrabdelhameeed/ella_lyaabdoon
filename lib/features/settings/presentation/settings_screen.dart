import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/constants/app_lists.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/features/settings/logic/location_cubit.dart';
import 'package:ella_lyaabdoon/features/settings/logic/location_state.dart';
import 'package:ella_lyaabdoon/features/settings/logic/settings_cubit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:ella_lyaabdoon/utils/notification_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<PendingNotificationRequest> _scheduledNotifications = [];
  bool _isLoadingNotifications = true;
  final InAppReview _inAppReview = InAppReview.instance;

  // Showcase Keys
  final GlobalKey _scheduledKey = GlobalKey();
  final GlobalKey _themeKey = GlobalKey();
  final GlobalKey _languageKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _playAyahKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadScheduledNotifications();
    _logScreenView();
  }

  void _logScreenView() {
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'SettingsScreen',
      screenClass: 'SettingsScreen',
    );
  }

  void _logEvent(String eventName, {Map<String, Object>? parameters}) {
    FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  Future<void> _loadScheduledNotifications() async {
    setState(() => _isLoadingNotifications = true);
    try {
      final notifications = await NotificationHelper.getPendingNotifications();
      setState(() {
        _scheduledNotifications = notifications;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      setState(() => _isLoadingNotifications = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
    }
  }

  void _launchUrl(String url) async {
    _logEvent('url_launched', parameters: {'url': url});
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showVideoDialog(BuildContext context) {
    _logEvent('app_idea_video_opened');

    final controller = YoutubePlayerController(
      initialVideoId: 'Hxz9g5Z6MMg',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: AppServicesDBprovider.currentLocale() == 'en',
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
                aspectRatio: 9 / 16,
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

  Future<void> _handleReviewRequest() async {
    _logEvent('rate_app_clicked');

    final isAvailable = await _inAppReview.isAvailable();

    if (isAvailable) {
      await _inAppReview.requestReview();
      _logEvent('rate_app_shown');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('thank_you_for_rating'.tr()),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      _logEvent('store_listing_opened');
      await _inAppReview.openStoreListing();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(create: (_) => SettingsCubit()),
        BlocProvider<LocationCubit>(create: (_) => LocationCubit()..init()),
      ],
      child: ShowCaseWidget(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!CacheHelper.getBool('settings_showcase_shown2')) {
              ShowCaseWidget.of(context).startShowCase([
                if (_scheduledNotifications.isNotEmpty) _scheduledKey,
                _playAyahKey,
                _locationKey,
              ]);
              CacheHelper.setBool('settings_showcase_shown2', true);
              _logEvent('showcase_shown');
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: Text('settings_screen'.tr()),
              centerTitle: false,
            ),
            body: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                final cubit = context.read<SettingsCubit>();

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    /// SCHEDULED NOTIFICATIONS SECTION
                    if (_isLoadingNotifications)
                      ListTile(
                        leading: Icon(Icons.alarm, color: colorScheme.primary),
                        title: Text("Loading scheduled reminders...".tr()),
                        trailing: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (_scheduledNotifications.isNotEmpty) ...[
                      _buildSectionHeader(context, 'reminders'.tr()),
                      Showcase(
                        key: _scheduledKey,
                        title: 'showcase_reminders_title'.tr(),
                        description: 'showcase_reminders_desc'.tr(),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ExpansionTile(
                            title: Text(
                              "${"Scheduled Reminders".tr()} (${_scheduledNotifications.length})",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            leading: Icon(
                              Icons.alarm,
                              color: colorScheme.primary,
                            ),
                            children: _scheduledNotifications.map((notif) {
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                leading: SizedBox(
                                  width: 80,
                                  child: Builder(
                                    builder: (context) {
                                      try {
                                        if (notif.payload == null ||
                                            notif.payload!.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        final payloadData = jsonDecode(
                                          notif.payload!,
                                        );
                                        final timestamp =
                                            payloadData['timestamp'];

                                        if (timestamp == null) {
                                          return const SizedBox.shrink();
                                        }

                                        // Handle both int and string timestamps
                                        final milliseconds = timestamp is int
                                            ? timestamp
                                            : int.tryParse(
                                                timestamp.toString(),
                                              );

                                        if (milliseconds == null) {
                                          return const SizedBox.shrink();
                                        }

                                        final dateTime =
                                            DateTime.fromMillisecondsSinceEpoch(
                                              milliseconds,
                                            );
                                        final formattedDate = DateFormat(
                                          'yyyy-MM-dd\nhh:mm a',
                                          AppServicesDBprovider.currentLocale(),
                                        ).format(dateTime);

                                        return Text(
                                          formattedDate,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                          textAlign: TextAlign.center,
                                        );
                                      } catch (e) {
                                        debugPrint(
                                          'Error parsing notification payload: $e',
                                        );
                                        return const SizedBox.shrink();
                                      }
                                    },
                                  ),
                                ),
                                title: Text(
                                  notif.title ?? 'No Title',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                subtitle: Text(
                                  notif.body ?? 'No Description',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: colorScheme.error,
                                  ),
                                  tooltip: 'delete_reminder'.tr(),
                                  onPressed: () async {
                                    _logEvent(
                                      'notification_deleted',
                                      parameters: {'notification_id': notif.id},
                                    );
                                    await NotificationHelper.cancel(notif.id);
                                    await _loadScheduledNotifications();
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Notification cancelled'.tr(),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    /// APPEARANCE SECTION
                    _buildSectionHeader(context, 'appearance'.tr()),
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          Showcase(
                            key: _themeKey,
                            title: 'showcase_theme_title'.tr(),
                            description: 'showcase_theme_desc'.tr(),
                            child: SwitchListTile(
                              title: Text('theme'.tr()),
                              subtitle: Text(
                                state.isDarkMode
                                    ? 'dark_mode'.tr()
                                    : 'light_mode'.tr(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                              value: state.isDarkMode,
                              onChanged: (value) {
                                _logEvent(
                                  'theme_changed',
                                  parameters: {
                                    'is_dark_mode': value ? 'true' : 'false',
                                  },
                                );
                                setState(() {});
                                cubit.toggleTheme(value);
                              },
                              secondary: Icon(
                                state.isDarkMode
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          Divider(height: 1, indent: 16, endIndent: 16),
                          Showcase(
                            key: _languageKey,
                            title: 'showcase_language_title'.tr(),
                            description: 'showcase_language_desc'.tr(),
                            child: ListTile(
                              leading: Icon(
                                Icons.language,
                                color: colorScheme.primary,
                              ),
                              title: Text('language'.tr()),
                              subtitle: Text(
                                state.isEnglish ? 'English' : 'العربية',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: state.isEnglish ? 'en' : 'ar',
                                    isDense: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'en',
                                        child: Text('English'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'ar',
                                        child: Text('العربية'),
                                      ),
                                    ],
                                    onChanged: (lang) {
                                      if (lang != null) {
                                        _logEvent(
                                          'language_changed',
                                          parameters: {'language': lang},
                                        );
                                        final isEnglish = lang == 'en';
                                        context.setLocale(Locale(lang));
                                        cubit.toggleLanguage(isEnglish);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// QURAN SETTINGS SECTION
                    _buildSectionHeader(context, 'quran_settings'.tr()),
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Showcase(
                        key: _playAyahKey,
                        title: 'showcase_play_ayah_title'.tr(),
                        description: 'showcase_play_ayah_desc'.tr(),
                        child: ListTile(
                          leading: Icon(
                            Icons.play_circle_filled,
                            color: colorScheme.primary,
                          ),
                          title: Text('play_ayah'.tr()),
                          subtitle: Text(
                            state.playAyahReciter.isEmpty
                                ? 'OFF'.tr()
                                : AppLists.reciters.firstWhere(
                                        (r) => r['id'] == state.playAyahReciter,
                                        orElse: () => {'name': 'OFF'},
                                      )['name'] ??
                                      'OFF',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                          trailing: Container(
                            constraints: const BoxConstraints(maxWidth: 140),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: state.playAyahReciter.isEmpty
                                    ? 'OFF'
                                    : state.playAyahReciter,
                                isExpanded: true,
                                isDense: true,
                                items: [
                                  DropdownMenuItem(
                                    value: 'OFF',
                                    child: Text('OFF'.tr()),
                                  ),
                                  ...AppLists.reciters.map(
                                    (reciter) => DropdownMenuItem(
                                      value: reciter['id'],
                                      child: Text(
                                        reciter['name'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    _logEvent(
                                      'ayah_reciter_changed',
                                      parameters: {'reciter': value},
                                    );
                                    cubit.setAyahReciter(value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// LOCATION SECTION
                    _buildSectionHeader(context, 'location_settings'.tr()),
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Showcase(
                        key: _locationKey,
                        title: 'showcase_location_title'.tr(),
                        description: 'showcase_location_desc'.tr(),
                        child: BlocBuilder<LocationCubit, LocationState>(
                          builder: (context, locationState) {
                            return ListTile(
                              leading: Icon(
                                Icons.location_on,
                                color: colorScheme.primary,
                              ),
                              title: Text('location'.tr()),
                              subtitle: Text(
                                locationState.currentCity ?? 'not_set'.tr(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.refresh),
                                tooltip: 'update_location'.tr(),
                                onPressed: () {
                                  _logEvent('location_updated');

                                  context.read<LocationCubit>().updateLocation(
                                    fromUserAction: true,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// ABOUT SECTION
                    _buildSectionHeader(context, 'about'.tr()),
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.ondemand_video_outlined,
                              color: colorScheme.primary,
                            ),
                            title: Text('app_idea_video_title'.tr()),
                            subtitle: Text(
                              'app_idea_video_subtitle'.tr(),
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showVideoDialog(context),
                          ),
                          Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: Icon(
                              Icons.star_rounded,
                              color: colorScheme.primary,
                            ),
                            title: Text('rate_the_app'.tr()),
                            subtitle: Text(
                              'rate_the_app_subtitle'.tr(),
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _handleReviewRequest,
                          ),
                          Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: Icon(
                              Icons.share,
                              color: colorScheme.primary,
                            ),
                            title: Text('sadqah_garyah'.tr()),
                            subtitle: Text(
                              'sadkah_desc'.tr(),
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              _logEvent('share_app_clicked');
                              final result = await SharePlus.instance.share(
                                ShareParams(
                                  text:
                                      '${'sadqah_garyah'.tr()}\n\nI am using Ella Lyaabdoon app \n Download it from the Play Store with this link: https://play.google.com/store/apps/details?id=com.amrabdelhameed.ella_lyaabdoon',
                                  subject: 'Ella Lyaabdoon'.tr(),
                                ),
                              );

                              if (result.status == ShareResultStatus.success) {
                                _logEvent('share_app_success');
                              }
                            },
                          ),
                          Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: Icon(
                              Icons.code,
                              color: colorScheme.primary,
                            ),
                            title: Text('open_source_title'.tr()),
                            subtitle: Text(
                              'open_source_desc'.tr(),
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.open_in_new),
                            onTap: () => _launchUrl(
                              'https://github.com/amrabdelhameeed/ella_lyaabdoon',
                            ),
                          ),
                          Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: Icon(
                              Icons.favorite,
                              color: colorScheme.primary,
                            ),
                            title: Text('dua_support_title'.tr()),
                            subtitle: Text(
                              'dua_support_desc'.tr(),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// CONTRIBUTORS SECTION
                    _buildSectionHeader(context, 'contributors'.tr()),
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ExpansionTile(
                        title: Text('list_of_contributors'.tr()),
                        leading: Icon(Icons.group, color: colorScheme.primary),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primaryContainer,
                                backgroundImage: AssetImage(
                                  'assets/contributors/assem.png',
                                ),
                                // child: Icon(
                                //   Icons.person,
                                //   color: colorScheme.onPrimaryContainer,
                                // ),
                              ),
                              onTap: () {
                                _launchUrl(
                                  'https://www.behance.net/ahmd3assem',
                                );
                              },
                              title: const Text('أحمد عاصم'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// DEVELOPER INFO SECTION
                    _buildSectionHeader(context, 'developer'.tr()),
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ExpansionTile(
                        title: Text('developer_info'.tr()),
                        leading: Icon(Icons.person, color: colorScheme.primary),
                        onExpansionChanged: (expanded) {
                          if (expanded) {
                            _logEvent('developer_info_expanded');
                          }
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 48,
                                  backgroundImage: CachedNetworkImageProvider(
                                    'https://avatars.githubusercontent.com/u/53038487?v=4',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: Icon(
                                    Icons.code,
                                    color: colorScheme.primary,
                                  ),
                                  title: const Text('GitHub'),
                                  subtitle: const Text(
                                    'amrabdelhameeed',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  trailing: const Icon(Icons.open_in_new),
                                  onTap: () => _launchUrl(
                                    'https://github.com/amrabdelhameeed',
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.work,
                                    color: colorScheme.primary,
                                  ),
                                  title: const Text('LinkedIn'),
                                  subtitle: const Text(
                                    'amrabdelhameeed',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  trailing: const Icon(Icons.open_in_new),
                                  onTap: () => _launchUrl(
                                    'https://www.linkedin.com/in/amrabdelhameeed/',
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.chat_bubble_outline,
                                    color: colorScheme.primary,
                                  ),
                                  title: const Text('WhatsApp'),
                                  subtitle: Text(
                                    'for_suggestions_and_complaints'.tr(),
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  trailing: const Icon(Icons.open_in_new),
                                  onTap: () =>
                                      _launchUrl('https://wa.me/201121009270'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
