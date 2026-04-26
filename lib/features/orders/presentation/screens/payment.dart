import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/styles/shadows_styles.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/features/orders/domain/delivery_details.dart';
import 'package:homemade/features/orders/domain/fulfillment_options.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/features/orders/domain/payment_method.dart';
import 'package:homemade/features/orders/presentation/screens/payment_processing.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.selection,
    required this.options,
    this.deliveryDetails,
  });

  final double totalAmount;
  final FulfillmentSelection selection;
  final FulfillmentOptions options;
  final DeliveryDetails? deliveryDetails;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  //? demo payment methods — swap for user account + Stripe lookup later
  static const List<PaymentMethod> _methods = [
    SavedCardPaymentMethod(
      id: 'mastercard',
      last4: '3508',
      expiry: '02/30',
      brand: 'Mastercard',
    ),
    PayPalPaymentMethod(id: 'paypal', maskedEmail: 'ariyen***@gmaile.com'),
    SavedCardPaymentMethod(
      id: 'visa',
      last4: '4242',
      expiry: '08/27',
      brand: 'Visa',
    ),
    WalletPaymentMethod(id: 'wallet', balance: 12.00),
    ApplePayPaymentMethod(id: 'apple'),
  ];

  String? _selectedId;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _selectedId = _pickDefaultId();
  }

  String? _pickDefaultId() {
    final wallet = _methods.whereType<WalletPaymentMethod>().firstOrNull;
    if (wallet != null && wallet.coversAmount(widget.totalAmount)) {
      return wallet.id;
    }
    final firstSelectable = _methods.firstWhere(
      (m) => _isSelectable(m),
      orElse: () => _methods.first,
    );
    return _isSelectable(firstSelectable) ? firstSelectable.id : null;
  }

  bool _isSelectable(PaymentMethod m) {
    if (m is WalletPaymentMethod) return m.coversAmount(widget.totalAmount);
    return true;
  }

  void _select(PaymentMethod m) {
    if (!_isSelectable(m)) return;
    setState(() => _selectedId = m.id);
  }

  Future<void> _pay() async {
    if (_selectedId == null || _processing) return;
    HapticFeedback.mediumImpact();
    setState(() => _processing = true);

    await Get.to<void>(
      () => PaymentProcessingScreen(
        totalAmount: widget.totalAmount,
        selection: widget.selection,
        options: widget.options,
        deliveryDetails: widget.deliveryDetails,
      ),
    );

    if (mounted) setState(() => _processing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppTexts.paymentTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TotalHeader(amount: widget.totalAmount),
                  // const _Divider(),
                  const Gap(AppSizes.spaceBtwSections),
                  Text(
                    AppTexts.paymentMethodLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(AppSizes.md - 4),
                  for (final method in _methods) ...[
                    _MethodCard(
                      method: method,
                      totalAmount: widget.totalAmount,
                      selected: _selectedId == method.id,
                      enabled: _isSelectable(method),
                      onTap: () => _select(method),
                    ),
                    const Gap(AppSizes.sm + 2),
                  ],
                  const _AddCardLink(),
                  const _Divider(),
                  const _SecureNote(),
                  const Gap(AppSizes.sm + 2),
                  const _TermsText(),
                ],
              ),
            ),
          ),
          _PayFooter(
            total: widget.totalAmount,
            enabled: _selectedId != null && !_processing,
            processing: _processing,
            onPay: _pay,
          ),
        ],
      ),
    );
  }
}

class _TotalHeader extends StatelessWidget {
  const _TotalHeader({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.paymentTotalLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(AppSizes.xs),
        Text(
          '€${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Container(height: 1, color: Theme.of(context).colorScheme.outline),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.method,
    required this.totalAmount,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final PaymentMethod method;
  final double totalAmount;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppSizes.md - 2),
        decoration: BoxDecoration(
          color: selected ? colors.selectedSurface : scheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          boxShadow: [CustomShadowStyle.customCircleShadows()],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _MethodLeading(method: method),
            const Gap(AppSizes.md - 2),
            Expanded(
              child: _MethodInfo(
                method: method,
                totalAmount: totalAmount,
                onDark: selected,
              ),
            ),
            const Gap(AppSizes.sm),
            _RadioDot(selected: selected, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? color : Colors.transparent,
        border: selected
            ? null
            : Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
      ),
    );
  }
}

class _MethodLeading extends StatelessWidget {
  const _MethodLeading({required this.method});

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget child;
    switch (method) {
      case WalletPaymentMethod():
        child = Icon(
          Iconsax.wallet_2,
          size: 22,
          color: scheme.onSurface,
        );
      case SavedCardPaymentMethod(:final brand):
        final asset = _brandAsset(brand);
        child = asset != null
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(asset, fit: BoxFit.contain),
              )
            : Icon(Iconsax.card, size: 22, color: scheme.onSurface);
      case PayPalPaymentMethod():
        child = Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(AppImages.paypal, fit: BoxFit.contain),
        );
      case ApplePayPaymentMethod():
      case GooglePayPaymentMethod():
        child = Icon(
          Iconsax.mobile,
          size: 22,
          color: scheme.onSurface,
        );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: child),
    );
  }

  static String? _brandAsset(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return AppImages.visa;
      case 'mastercard':
        return AppImages.mastercard;
      default:
        return null;
    }
  }
}

class _MethodInfo extends StatelessWidget {
  const _MethodInfo({
    required this.method,
    required this.totalAmount,
    required this.onDark,
  });

  final PaymentMethod method;
  final double totalAmount;
  final bool onDark;

  String _maskedCardNumber(String last4) => '•••• •••• •••• $last4';

  String _label() {
    switch (method) {
      case WalletPaymentMethod():
        return AppTexts.paymentWalletLabel;
      case SavedCardPaymentMethod(:final brand):
        return brand;
      case PayPalPaymentMethod():
        return AppTexts.paymentPayPalLabel;
      case ApplePayPaymentMethod():
        return AppTexts.paymentApplePayLabel;
      case GooglePayPaymentMethod():
        return AppTexts.paymentGooglePayLabel;
    }
  }

  /// Returns (subtitle text, optional override colour for warnings)
  (String, Color?) _subtitle() {
    switch (method) {
      case WalletPaymentMethod(:final balance):
        if (balance >= totalAmount) {
          return (
            '${AppTexts.paymentWalletBalancePrefix} €${balance.toStringAsFixed(2)}',
            null,
          );
        }
        final shortfall = totalAmount - balance;
        return (
          '${AppTexts.paymentWalletInsufficientPrefix} €${shortfall.toStringAsFixed(2)}',
          const Color(0xFFE53935),
        );
      case SavedCardPaymentMethod(:final last4):
        return (_maskedCardNumber(last4), null);
      case PayPalPaymentMethod(:final maskedEmail):
        return (maskedEmail, null);
      case ApplePayPaymentMethod():
        return (AppTexts.paymentApplePayHint, null);
      case GooglePayPaymentMethod():
        return (AppTexts.paymentGooglePayHint, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final (subtitle, subtitleOverride) = _subtitle();
    final titleColor = onDark ? colors.selectedOnSurface : scheme.onSurface;
    final subColor =
        subtitleOverride ??
        (onDark
            ? colors.selectedOnSurface.withValues(alpha: 0.6)
            : scheme.onSurfaceVariant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _label(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: titleColor,
            letterSpacing: 0.1,
          ),
        ),
        const Gap(4),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: subColor,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _AddCardLink extends StatelessWidget {
  const _AddCardLink();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        child: Row(
          children: [
            Icon(Iconsax.add, size: 18, color: scheme.onSurface),
            const Gap(AppSizes.sm),
            Text(
              AppTexts.paymentAddCard,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecureNote extends StatelessWidget {
  const _SecureNote();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Iconsax.lock_1, size: 14, color: scheme.onSurfaceVariant),
        const Gap(6),
        Flexible(
          child: Text(
            AppTexts.paymentSecureNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.35);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${AppTexts.paymentTermsPrefix} '),
          TextSpan(
            text: AppTexts.paymentTermsLink,
            style: base?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: scheme.onSurface,
            ),
          ),
        ],
      ),
      style: base,
    );
  }
}

class _PayFooter extends StatelessWidget {
  const _PayFooter({
    required this.total,
    required this.enabled,
    required this.processing,
    required this.onPay,
  });

  final double total;
  final bool enabled;
  final bool processing;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: Colors.transparent)),
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enabled ? onPay : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.selectedSurface,
              foregroundColor: colors.selectedOnSurface,
              disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.38),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              textStyle: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            child: processing
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(colors.selectedOnSurface),
                    ),
                  )
                : Text(
                    '${AppTexts.paymentPayCtaPrefix} €${total.toStringAsFixed(2)}',
                  ),
          ),
        ),
      ),
    );
  }
}
