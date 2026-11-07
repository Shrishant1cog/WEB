/// FFT Tournament Card Component
/// Modern tournament card with clean information hierarchy

import 'package:flutter/material.dart';

import '../../../data/models/tournament_models.dart';
import '../themes/design_tokens.dart';
import '../../features/tournaments/presentation/tournament_helpers.dart';

class FFTTournamentCard extends StatelessWidget {
  final TournamentListing listing;
  final VoidCallback? onTap;
  final bool isCompact;

  const FFTTournamentCard({
    super.key,
    required this.listing,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: isCompact
          ? const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs)
          : const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Padding(
          padding: isCompact
              ? const EdgeInsets.all(Spacing.md)
              : const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row: Title + Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      listing.title,
                      style: isCompact
                          ? TypeScale.titleSmall.copyWith(fontWeight: FontWeight.w600)
                          : TypeScale.titleMedium.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  StatusChip(status: listing.status),
                ],
              ),

              const SizedBox(height: Spacing.xs),

              // Meta row: Format · Mode · Map · Organizer
              if (!isCompact) ...[
                Text(
                  [
                    formatFormat(listing.format, listing.teamSize),
                    listing.mode.toUpperCase(),
                    if (listing.map != null && listing.map!.isNotEmpty) listing.map!,
                    'by ${listing.organizerName}',
                  ].join(' · '),
                  style: TypeScale.bodySmall.copyWith(
                    color: isDark ? TextColors.darkSecondary : TextColors.lightSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.sm),
              ],

              // Info row: Date + Capacity
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: isCompact ? IconSizes.sm : IconSizes.md,
                    color: isDark ? TextColors.darkTertiary : TextColors.lightTertiary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      formatDateTime(listing.tournamentStartsAt),
                      style: TypeScale.bodySmall.copyWith(
                        color: isDark ? TextColors.darkSecondary : TextColors.lightSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.groups_outlined,
                    size: isCompact ? IconSizes.sm : IconSizes.md,
                    color: isDark ? TextColors.darkTertiary : TextColors.lightTertiary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    '${listing.confirmedEntries}/${listing.maxTeams}',
                    style: TypeScale.bodySmall.copyWith(
                      color: isDark ? TextColors.darkSecondary : TextColors.lightSecondary,
                    ),
                  ),
                ],
              ),

              // Status badges row
              if (!isCompact) ...[
                const SizedBox(height: Spacing.xs),
                Row(
                  children: [
                    if (listing.isFull)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Semantic.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(Radii.round),
                          border: Border.all(
                            color: Semantic.warning.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Full',
                          style: TypeScale.labelSmall.copyWith(
                            color: Semantic.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (listing.prizePool != null && listing.prizePool!.isNotEmpty) ...[
                      if (listing.isFull) const SizedBox(width: Spacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.workspace_premium_outlined,
                            size: isCompact ? IconSizes.xs : IconSizes.sm,
                            color: Brand.primaryAmber,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Expanded(
                            child: Text(
                              listing.prizePool!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TypeScale.bodySmall.copyWith(
                                color: Brand.primaryAmber,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}