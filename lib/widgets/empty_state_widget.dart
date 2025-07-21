import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/blocs.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: themeState.primaryGradient.colors
                              .map(
                                (color) => color.withAlpha((0.3 * 255).toInt()),
                              )
                              .toList(),
                          begin: themeState.primaryGradient.begin,
                          end: themeState.primaryGradient.end,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .then()
                    .shimmer(
                      duration: 1500.ms,
                      color: Colors.white.withAlpha((0.3 * 255).toInt()),
                    ),

                const SizedBox(height: 32),

                Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 16),

                Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                if (onActionPressed != null && actionText != null) ...[
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                        onPressed: onActionPressed,
                        icon: const Icon(Icons.add),
                        label: Text(actionText!),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 600.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                      ),
                ],

                const SizedBox(height: 40),

                _buildMotivationalQuote(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMotivationalQuote(BuildContext context) {
    final quotes = [
      '"The secret of getting ahead is getting started." - Mark Twain',
      '"Small steps every day lead to big changes." - Unknown',
      '"Your future self will thank you for what you do today." - Unknown',
      '"Progress, not perfection." - Unknown',
      '"A goal without a plan is just a wish." - Antoine de Saint-Exupéry',
      '"The way to get started is to quit talking and begin doing." - Walt Disney',
    ];

    final quote = quotes[DateTime.now().day % quotes.length];

    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withAlpha((0.3 * 255).toInt()),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withAlpha((0.2 * 255).toInt()),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.format_quote,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  quote,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha((0.8 * 255).toInt()),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Icon(
                Icons.format_quote,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 900.ms, duration: 800.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
