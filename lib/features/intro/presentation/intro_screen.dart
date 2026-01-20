import 'package:ella_lyaabdoon/app_router.dart';
import 'package:ella_lyaabdoon/core/constants/app_routes.dart';
import 'package:ella_lyaabdoon/features/intro/logic/intro_cubit.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class IntroScreen extends StatelessWidget {
  IntroScreen({super.key});

  final PageController _controller = PageController();
  final List<Map<String, String>> _pages = [
    {'title': 'intro_title_1', 'desc': 'intro_desc_1', 'icon': 'timeline'},
    {'title': 'intro_title_2', 'desc': 'intro_desc_2', 'icon': 'auto_awesome'},
    {
      'title': 'intro_title_4',
      'desc': 'intro_desc_4',
      'icon': 'calendar_month',
    },
    {'title': 'intro_title_3', 'desc': 'intro_desc_3', 'icon': 'bolus'},
  ];

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'timeline':
        return Icons.timeline;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'bolus':
        return Icons.volunteer_activism;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => IntroCubit(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withAlpha(200),
                    ]
                  : [Colors.green.shade50, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Expanded(
                    child: BlocBuilder<IntroCubit, IntroState>(
                      buildWhen: (previous, current) => false,
                      builder: (context, state) {
                        return PageView.builder(
                          controller: _controller,
                          itemCount: _pages.length,
                          onPageChanged: (i) =>
                              context.read<IntroCubit>().pageChanged(i),
                          itemBuilder: (_, i) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withAlpha(50),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getIcon(_pages[i]['icon']!),
                                    size: 60,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _pages[i]['title']!.tr(),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        _pages[i]['desc']!.tr(),
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color: theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withAlpha(200),
                                              height: 1.5,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),

                  /// Quranic Verse (only on last page)
                  BlocBuilder<IntroCubit, IntroState>(
                    builder: (context, state) {
                      final isLastPage = state.index == _pages.length - 1;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: isLastPage ? null : 0,
                        margin: EdgeInsets.only(bottom: isLastPage ? 20 : 0),
                        child: isLastPage
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withAlpha(
                                      50,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'وَفِي ذَٰلِكَ فَلْيَتَنَافَسِ الْمُتَنَافِسُونَ',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    height: 1.8,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      );
                    },
                  ),

                  /// Indicators & Buttons
                  Column(
                    children: [
                      BlocBuilder<IntroCubit, IntroState>(
                        builder: (context, state) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: state.index == i ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: state.index == i
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.primary.withAlpha(50),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: BlocBuilder<IntroCubit, IntroState>(
                          builder: (context, state) {
                            final isLastPage = state.index == _pages.length - 1;
                            return ElevatedButton(
                              onPressed: () {
                                if (isLastPage) {
                                  context.read<IntroCubit>().completeIntro((
                                    route,
                                  ) {
                                    GoRouter.of(
                                      context,
                                    ).pushReplacementNamed(route);
                                  });
                                } else {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.fastOutSlowIn,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                (isLastPage ? 'start_now' : 'next').tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
