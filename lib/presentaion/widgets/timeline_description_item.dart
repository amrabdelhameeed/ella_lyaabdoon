import 'package:ella_lyaabdoon/utils/app_services_database_provider.dart';
import 'package:flutter/material.dart';

class TimelineDescriptionItem extends StatelessWidget {
  final String description;
  final bool isCurrent;
  final bool isLeftAligned;
  final bool isLast;
  final Animation<double> pulseAnimation;
  final VoidCallback onTranslate;

  const TimelineDescriptionItem({
    super.key,
    required this.description,
    required this.isCurrent,
    required this.isLeftAligned,
    required this.isLast,
    required this.pulseAnimation,
    required this.onTranslate,
  });

  void _showFullDescription(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          content: SingleChildScrollView(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final centerX = screenWidth / 2;
        final cardStart = isLeftAligned ? 16.0 : centerX + 16;
        final cardEnd = isLeftAligned ? centerX - 16 : screenWidth - 16;
        final lineStart = centerX + 6;
        final lineEnd = isLeftAligned ? cardEnd : cardStart;
        final lineWidth = (lineEnd - lineStart).abs();

        return SizedBox(
          height: 100,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: centerX - 1.5,
                top: 0,
                bottom: isLast ? null : 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 3,
                  height: isLast ? 35 : null,
                  color: isCurrent ? Colors.greenAccent : Colors.grey[300],
                ),
              ),
              Positioned(
                left: centerX - 6,
                top: 34,
                child: isCurrent
                    ? FadeTransition(
                        opacity: pulseAnimation,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
              ),
              Positioned(
                left: isLeftAligned ? lineEnd : lineStart,
                top: 39,
                width: lineWidth,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 2,
                  color: isCurrent
                      ? Colors.greenAccent.withOpacity(0.5)
                      : Colors.grey[300],
                ),
              ),
              Positioned(
                left: cardStart,
                right: screenWidth - cardEnd,
                top: 8,
                bottom: 8,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showFullDescription(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Colors.green.withOpacity(0.08)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? Colors.greenAccent.withOpacity(0.3)
                            : Colors.grey[200]!,
                        width: 1,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            description,
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  height: 1.5,
                                  color: isCurrent
                                      ? Colors.black87
                                      : Colors.grey[700],
                                ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppServicesDBprovider.currentLocale() == "en"
                            ? InkWell(
                                onTap: onTranslate,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.translate,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
