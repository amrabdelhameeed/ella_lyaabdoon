import 'package:ella_lyaabdoon/app_router.dart';
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

  final List<String> _texts = [
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt.',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut enim ad minim veniam.',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis aute irure dolor in reprehenderit.',
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
                itemCount: _texts.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  return Center(
                    child: Text(
                      _texts[i],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                },
              ),
            ),

            /// Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _texts.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
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
                onPressed: _index == _texts.length - 1
                    ? () {
                        AppRouter.router.pushReplacementNamed(AppRoutes.home);
                      }
                    : () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                child: Text(
                  _index == _texts.length - 1 ? 'Go to Home' : 'Next',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
