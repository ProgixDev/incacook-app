import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/models/auth/payout_readiness.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/payments/data/payout_onboarding_service.dart';
import 'package:incacook/features/wallet/data/wallet_models.dart';
import 'package:incacook/features/wallet/data/wallet_repository.dart';

/// Seller / driver wallet: real balance from `GET /v1/wallet/me`, ledger, and a
/// withdrawal request (enabled only when available >= the server minimum, 50 €).
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, WalletRepository? repository})
    : _repository = repository;

  /// Test seam — production call sites always omit this and get a fresh
  /// [WalletRepository] per fetch, same as before this field existed.
  final WalletRepository? _repository;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with WidgetsBindingObserver {
  late Future<WalletSummary> _future;
  bool _withdrawing = false;

  WalletRepository get _repo => widget._repository ?? WalletRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _repo.getSummary();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The wallet screen otherwise has zero proactive freshness (fetch-once on
  /// mount, then only on manual pull-to-refresh) — a ledger transition that
  /// lands while the user is foregrounded on this screen would never appear
  /// until they backed out and back in. Refresh on every resume so it does.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    final next = _repo.getSummary();
    // Block body, not `() => _future = next` — an arrow-expression closure
    // here evaluates to the assignment's value (the Future itself), and
    // setState() asserts in debug mode if its callback returns one.
    if (mounted) {
      setState(() {
        _future = next;
      });
    }
    await next;
  }

  /// Opens Stripe Connect payout onboarding (required only to withdraw), then
  /// refreshes the user so the prompt hides itself once payouts are ready.
  Future<void> _configurePayments() async {
    await PayoutOnboardingService.instance.openOnboarding(context);
    try {
      await UserController.instance.refreshFromServer();
    } catch (_) {
      // Best-effort — next /users/me read reconciles.
    }
  }

  Future<void> _withdraw() async {
    setState(() => _withdrawing = true);
    try {
      await _repo.withdraw();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande de retrait envoyée.')),
      );
      await _refresh();
    } on ApiFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _withdrawing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          'Portefeuille',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<WalletSummary>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ScrollMessage(
                child: _ErrorState(
                  error: '${snapshot.error}',
                  onRetry: _refresh,
                ),
              );
            }
            final s = snapshot.data!;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                _BalanceCard(summary: s),
                const Gap(AppSizes.md),
                // Payout setup prompt for either earner role, while not yet
                // configured. Reactive so it disappears once onboarding
                // completes.
                Obx(
                  () => UserController.instance.needsPayoutSetup
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.md),
                          child: _PayoutSetupCard(
                            onConfigure: _configurePayments,
                            // Details already with Stripe → swap the setup
                            // CTA for "verification in progress".
                            pendingVerification:
                                UserController.instance.payoutSetupState ==
                                PayoutSetupState.pendingVerification,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                _WithdrawSection(
                  summary: s,
                  withdrawing: _withdrawing,
                  onWithdraw: _withdraw,
                ),
                const Gap(AppSizes.lg),
                Text(
                  'Transactions',
                  style:
                      textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Gap(AppSizes.sm),
                if (s.entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                    child: Text(
                      'Aucune transaction pour le moment.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final e in s.entries) ...[
                    _EntryTile(entry: e),
                    const Gap(AppSizes.sm),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary});

  final WalletSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solde disponible',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(AppSizes.xs),
          Text(
            currency.format(summary.availableEuros),
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const Gap(AppSizes.md),
          Row(
            children: [
              _MiniStat(
                label: 'En attente',
                value: currency.format(summary.pendingEuros),
              ),
              const Gap(AppSizes.lg),
              _MiniStat(
                label: 'Déjà versé',
                value: currency.format(summary.paidOutEuros),
              ),
            ],
          ),
          if (summary.hasDebt) ...[
            const Gap(AppSizes.md),
            _MiniStat(
              label: 'Dette',
              value: '-${currency.format(summary.debtEuros)}',
              valueColor: scheme.error,
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const Gap(2),
        Text(
          value,
          style: textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700, color: valueColor),
        ),
      ],
    );
  }
}

/// Non-blocking prompt: sellers and drivers both earn without Stripe payout
/// onboarding; it's only needed to withdraw. Shown in the wallet until set up.
/// While Stripe verifies submitted details ([pendingVerification]), the copy
/// switches to "verification in progress" and the CTA re-opens Stripe to
/// check status instead of starting over.
class _PayoutSetupCard extends StatelessWidget {
  const _PayoutSetupCard({
    required this.onConfigure,
    this.pendingVerification = false,
  });

  final Future<void> Function() onConfigure;
  final bool pendingVerification;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pendingVerification
                ? AppTexts.walletPayoutPendingTitle
                : AppTexts.walletPayoutSetupTitle,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Gap(AppSizes.xs),
          Text(
            pendingVerification
                ? AppTexts.walletPayoutPendingBody
                : AppTexts.walletPayoutSetupBody,
            style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const Gap(AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfigure,
              child: Text(
                pendingVerification
                    ? AppTexts.walletPayoutPendingCta
                    : AppTexts.incomingOrderConfigurePaymentsCta,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawSection extends StatelessWidget {
  const _WithdrawSection({
    required this.summary,
    required this.withdrawing,
    required this.onWithdraw,
  });

  final WalletSummary summary;
  final bool withdrawing;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final enabled = summary.canWithdraw && !withdrawing;
    final minLabel = summary.minWithdrawalEuros.toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: enabled ? onWithdraw : null,
          child: withdrawing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Demander un retrait'),
        ),
        if (summary.hasDebt) ...[
          const Gap(AppSizes.xs),
          Text(
            'Retrait impossible : votre solde présente une dette.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ] else if (!summary.canWithdraw) ...[
          const Gap(AppSizes.xs),
          Text(
            'Retrait disponible à partir de $minLabel €',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final WalletEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final date = DateFormat('d MMM yyyy', 'fr_FR').format(entry.createdAt);
    final isDebit = entry.amountCents < 0;
    final amountColor = isDebit
        ? scheme.error
        : const Color(0xFF1FA463); // credit green (semantic)
    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.label,
                  style:
                      textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Gap(2),
                Text(
                  '$date · ${_statusLabel(entry.status)}',
                  style: textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            '${isDebit ? '' : '+'}${currency.format(entry.amountEuros)}',
            style: textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800, color: amountColor),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'AVAILABLE':
        return 'Disponible';
      case 'PENDING':
        return 'En attente';
      case 'HELD':
        return 'Bloqué';
      case 'PAID_OUT':
        return 'Versé';
      case 'CANCELLED':
        return 'Annulé';
      default:
        return status;
    }
  }
}

class _ScrollMessage extends StatelessWidget {
  const _ScrollMessage({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Center(child: child),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: scheme.error, size: 40),
        const Gap(AppSizes.sm),
        Text(error, textAlign: TextAlign.center),
        const Gap(AppSizes.md),
        OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
      ],
    );
  }
}
