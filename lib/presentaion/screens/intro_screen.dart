import 'package:ella_lyaabdoon/app_router.dart';
import 'package:ella_lyaabdoon/utils/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/utils/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<Map<String, String>> _pages = [
    {'title': 'intro_title_1', 'desc': 'intro_desc_1'},
    {'title': 'intro_title_2', 'desc': 'intro_desc_2'},
    {'title': 'intro_title_3', 'desc': 'intro_desc_3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _pages[i]['title']!.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _pages[i]['desc']!.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  );
                },
              ),
            ),

            /// Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_index == _pages.length - 1) {
                    // AppServicesDBprovider.setFirstOpen();
                    AppRouter.router.pushReplacementNamed(AppRoutes.home);
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  _index == _pages.length - 1 ? 'start_now'.tr() : 'next'.tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
