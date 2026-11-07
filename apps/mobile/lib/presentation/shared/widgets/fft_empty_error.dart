/// FFT Empty & Error States
/// Modern empty and error state presentations

import 'package:flutter/material.dart';

import '../themes/design_tokens.dart';
import 'fft_button.dart';

/// Modern empty state widget
class FFTEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final double iconSize;

  const FFTEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize + 24,
              height: iconSize + 24,
              decoration: BoxDecoration(
                color: isDark
                    ? Brand.primaryAmber.withValues(alpha: 0.12)
                    : Brand.primaryAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Radii.xl),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: Brand.primaryAmber,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              title,
              style: TypeScale.titleLarge.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                message!,
                style: TypeScale.bodyMedium.copyWith(
                  color: isDark ? TextColors.darkSecondary : TextColors.lightSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: Spacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states
class FFTEmptyStates {
  static const FFTEmptyState noTournaments = FFTEmptyState(
    icon: Icons.emoji_events_outlined,
    title: 'No tournaments found',
    message: 'Try a different search or filter.',
    iconSize: 64,
  );

  static const FFTEmptyState noTeams = FFTEmptyState(
    icon: Icons.groups_outlined,
    title: 'No teams yet',
    message: 'Create your first team to get started.',
    iconSize: 64,
  );

  static const FFTEmptyState noMatches = FFTEmptyState(
    icon: Icons.sports_esports_outlined,
    title: 'No matches scheduled',
    message: 'Matches will appear here when tournaments are live.',
    iconSize: 64,
  );

  static const FFTEmptyState noNotifications = FFTEmptyState(
    icon: Icons.notifications_none_outlined,
    title: 'No notifications',
    message: 'You\'re all caught up!',
    iconSize: 64,
  );

  static const FFTEmptyState noResults = FFTEmptyState(
    icon: Icons.search_off_outlined,
    title: 'No results found',
    message: 'Try adjusting your search or filters.',
    iconSize: 64,
  );

  static const FFTEmptyState noProfile = FFTEmptyState(
    icon: Icons.person_outline,
    title: 'Profile not found',
    message: 'This user doesn\'t exist or has been removed.',
    iconSize: 64,
  );
}

/// Modern error state widget
class FFTErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData icon;

  const FFTErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: isDark
                    ? Semantic.error.withValues(alpha: 0.12)
                    : Semantic.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Radii.xl),
              ),
              child: Icon(
                icon,
                size: 40,
                color: Semantic.error,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'Something went wrong',
              style: TypeScale.titleLarge.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              message,
              style: TypeScale.bodyMedium.copyWith(
                color: isDark ? TextColors.darkSecondary : TextColors.lightSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Spacing.lg),
              FFTButton(
                text: retryLabel!,
                onPressed: onRetry,
                variant: ButtonVariant.filled,
                icon: Icons.refresh,
                size: ButtonSize.md,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error state
class FFTNetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const FFTNetworkErrorState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FFTErrorState(
      message: 'Unable to connect. Please check your internet connection.',
      onRetry: onRetry,
      retryLabel: 'Retry',
      icon: Icons.wifi_off,
    );
  }
}

/// Offline state
class FFTOfflineState extends StatelessWidget {
  final VoidCallback? onRetry;

  const FFTOfflineState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FFTErrorState(
      message: 'You\'re offline. Some features may be limited.',
      onRetry: onRetry,
      retryLabel: 'Try again',
      icon: Icons.cloud_off,
    );
  }
}

/// Unauthorized state
class FFTUnauthorizedState extends StatelessWidget {
  final VoidCallback? onLogin;

  const FFTUnauthorizedState({
    super.key,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Brand.primaryAmber.withValues(alpha: 0.12)
                    : Brand.primaryAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Radii.xl),
              ),
              child: Icon(
                Icons.lock_outline,
                size: 40,
                color: Brand.primaryAmber,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'Sign in required',
              style: TypeScale.titleLarge.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Please sign in to access this feature.',
              style: TypeScale.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),
            if (onLogin != null)
              FFTButton(
                text: 'Sign in',
                onPressed: onLogin,
                variant: ButtonVariant.filled,
                icon: Icons.login,
                size: ButtonSize.md,
              ),
          ],
        ),
      ),
    );
  }
}

/// Loading state with message
class FFTLoadingState extends StatelessWidget {
  final String? message;
  final bool showIndicator;

  const FFTLoadingState({
    super.key,
    this.message,
    this.showIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIndicator)
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Brand.primaryAmber),
              ),
            ),
          if (message != null) ...[
            const SizedBox(height: Spacing.lg),
            Text(
              message!,
              style: TypeScale.bodyMedium.copyWith(
                color: isDark ? TextColors.darkSecondary : TextColors.lightSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline loading indicator
class FFTInlineLoading extends StatelessWidget {
  final String? label;
  final double size;

  const FFTInlineLoading({
    super.key,
    this.label,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Brand.primaryAmber),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: Spacing.sm),
          Text(
            label!,
            style: TypeScale.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Pull-to-refresh indicator
class FFTRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;

  const FFTRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? Brand.primaryAmber,
      backgroundColor: backgroundColor ?? (isDark ? const Color(0xFF1F2735) : Colors.white),
      displacement: 40,
      strokeWidth: 3,
      child: child,
    );
  }
}