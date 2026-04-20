import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/appbar/appbar.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/orders/domain/delivery_details.dart';
import 'package:vinted_v2/features/orders/domain/fulfillment_options.dart';
import 'package:vinted_v2/features/orders/domain/payment_method.dart';
import 'package:vinted_v2/features/orders/presentation/screens/payment_processing.dart';

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
    WalletPaymentMethod(id: 'wallet', balance: 12.00),
    SavedCardPaymentMethod(
      id: 'card1',
      last4: '4242',
      expiry: '08/27',
      brand: 'Visa',
    ),
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
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppTexts.paymentTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
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
                  const _Divider(),
                  Text(
                    AppTexts.paymentMethodLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.paymentTotalLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(AppSizes.xs),
        Text(
          '€${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppColors.textPrimary,
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
      child: Container(height: 1, color: AppColors.lightGrey),
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
    final borderColor = selected ? AppColors.primary : AppColors.lightGrey;
    final iconBg = selected
        ? AppColors.primary.withValues(alpha: 0.12)
        : AppColors.lightGrey;

    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppSizes.md - 2),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            border: Border.all(color: borderColor, width: selected ? 1.8 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _MethodLeading(
                method: method,
                iconBg: iconBg,
                selected: selected,
              ),
              const Gap(AppSizes.md - 2),
              Expanded(
                child: _MethodInfo(
                  method: method,
                  totalAmount: totalAmount,
                  enabled: enabled,
                ),
              ),
              const Gap(AppSizes.sm),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: selected ? 1 : 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.tick_square,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodLeading extends StatelessWidget {
  const _MethodLeading({
    required this.method,
    required this.iconBg,
    required this.selected,
  });

  final PaymentMethod method;
  final Color iconBg;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? AppColors.primary : AppColors.secondary;

    Widget child;
    switch (method) {
      case WalletPaymentMethod():
        child = Icon(Iconsax.wallet_2, size: 20, color: iconColor);
      case SavedCardPaymentMethod(:final brand):
        final asset = _brandAsset(brand);
        child = asset != null
            ? Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(asset, fit: BoxFit.contain),
              )
            : Icon(Iconsax.card, size: 20, color: iconColor);
      case ApplePayPaymentMethod():
      case GooglePayPaymentMethod():
        child = Icon(Iconsax.mobile, size: 20, color: iconColor);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
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
    required this.enabled,
  });

  final PaymentMethod method;
  final double totalAmount;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    );
    final subStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.grey);

    switch (method) {
      case WalletPaymentMethod(:final balance):
        final covers = balance >= totalAmount;
        final afterPayment = balance - totalAmount;
        final shortfall = totalAmount - balance;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppTexts.paymentWalletLabel, style: titleStyle),
            const Gap(2),
            Text(
              '${AppTexts.paymentWalletBalancePrefix} €${balance.toStringAsFixed(2)}',
              style: subStyle,
            ),
            const Gap(2),
            if (covers)
              Text(
                '${AppTexts.paymentWalletAfterPrefix} €${afterPayment.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              Text(
                '${AppTexts.paymentWalletInsufficientPrefix} €${shortfall.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFE53935),
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        );
      case SavedCardPaymentMethod(:final last4, :final expiry):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppTexts.paymentCardLabelPrefix} •••• $last4',
              style: titleStyle,
            ),
            const Gap(2),
            Text(
              '${AppTexts.paymentCardExpiryPrefix} $expiry',
              style: subStyle,
            ),
          ],
        );
      case ApplePayPaymentMethod():
        return Text(AppTexts.paymentApplePayLabel, style: titleStyle);
      case GooglePayPaymentMethod():
        return Text(AppTexts.paymentGooglePayLabel, style: titleStyle);
    }
  }
}

class _AddCardLink extends StatelessWidget {
  const _AddCardLink();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        child: Row(
          children: [
            const Icon(Iconsax.add, size: 18, color: AppColors.secondary),
            const Gap(AppSizes.sm),
            Text(
              AppTexts.paymentAddCard,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
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
    return Row(
      children: [
        const Icon(Iconsax.lock_1, size: 14, color: AppColors.grey),
        const Gap(6),
        Flexible(
          child: Text(
            AppTexts.paymentSecureNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
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
    final base = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.grey, height: 1.35);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${AppTexts.paymentTermsPrefix} '),
          TextSpan(
            text: AppTexts.paymentTermsLink,
            style: base?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.secondary,
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightBackground,
        border: Border(top: BorderSide(color: AppColors.lightGrey)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enabled ? onPay : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.buttonDisabled,
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
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(AppColors.white),
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
