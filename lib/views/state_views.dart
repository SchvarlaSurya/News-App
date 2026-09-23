import 'package:flutter/material.dart';
import 'package:news_app/utils/constants.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Tampilan saat daftar kosong. Selalu menawarkan langkah berikutnya,
/// bukan sekadar memberi tahu bahwa isinya kosong.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function()? onRefresh;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final content = _Message(icon: icon, title: title, message: message);
    if (onRefresh == null) return content;

    return RefreshIndicator(
      onRefresh: onRefresh!,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [SizedBox(height: 120), content],
      ),
    );
  }
}

/// Tampilan saat pemuatan gagal, lengkap dengan tombol coba lagi.
class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Message(
              icon: Icons.cloud_off_outlined,
              title: 'Berita gagal dimuat',
              message: message,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

/// Penanda akhir daftar: indikator saat memuat, garis penutup saat habis.
class ListFooter extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;

  const ListFooter({super.key, required this.isLoading, required this.hasMore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (hasMore) return const SizedBox(height: AppSpacing.xl);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Center(
        child: Text(
          'Sudah sampai berita terakhir',
          style: theme.textTheme.labelMedium,
        ),
      ),
    );
  }
}

/// Pita penanda bahwa isi layar berasal dari simpanan lokal.
class OfflineBanner extends StatelessWidget {
  final DateTime? lastUpdated;
  final Future<void> Function() onRetry;

  const OfflineBanner({
    super.key,
    required this.lastUpdated,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              lastUpdated == null
                  ? 'Menampilkan berita tersimpan'
                  : 'Berita tersimpan, diunduh ${timeago.format(lastUpdated!, locale: 'id')}',
              style: theme.textTheme.labelMedium,
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Muat ulang')),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _Message({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
