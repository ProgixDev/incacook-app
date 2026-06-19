/// One wallet ledger row from `GET /v1/wallet/me`.
class WalletEntry {
  const WalletEntry({
    required this.id,
    required this.type,
    required this.amountCents,
    required this.status,
    required this.createdAt,
    this.orderId,
  });

  final String id;

  /// Backend `WalletEntryType`: ORDER_EARNING | DELIVERY_EARNING | COMMISSION
  /// | REFUND | WITHDRAWAL.
  final String type;

  /// Positive = credit; negative = debit (WITHDRAWAL).
  final int amountCents;

  /// Backend `WalletEntryStatus`: PENDING | AVAILABLE | HELD | PAID_OUT | CANCELLED.
  final String status;
  final DateTime createdAt;
  final String? orderId;

  double get amountEuros => amountCents / 100.0;

  /// Short French label for the entry type.
  String get label {
    switch (type) {
      case 'ORDER_EARNING':
        return 'Vente';
      case 'DELIVERY_EARNING':
        return 'Livraison';
      case 'COMMISSION':
        return 'Commission';
      case 'REFUND':
        return 'Remboursement';
      case 'WITHDRAWAL':
        return 'Retrait';
      default:
        return type;
    }
  }

  factory WalletEntry.fromJson(Map<String, dynamic> json) {
    return WalletEntry(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      amountCents: (json['amountCents'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      orderId: json['orderId'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Wallet summary from `GET /v1/wallet/me`. All amounts in cents — the buyer
/// app never computes payouts; these are server-calculated.
class WalletSummary {
  const WalletSummary({
    required this.availableCents,
    required this.pendingCents,
    required this.heldCents,
    required this.paidOutCents,
    required this.minWithdrawalCents,
    required this.canWithdraw,
    required this.entries,
  });

  final int availableCents;

  /// Earnings inside the 24h safety window — visible but not yet withdrawable.
  final int pendingCents;
  final int heldCents;
  final int paidOutCents;
  final int minWithdrawalCents;
  final bool canWithdraw;
  final List<WalletEntry> entries;

  double get availableEuros => availableCents / 100.0;

  /// Pending (24h window) + held (disputed) — everything owed but not available.
  double get pendingEuros => (pendingCents + heldCents) / 100.0;
  double get heldEuros => heldCents / 100.0;
  double get paidOutEuros => paidOutCents / 100.0;
  double get minWithdrawalEuros => minWithdrawalCents / 100.0;

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      availableCents: (json['availableCents'] as num?)?.toInt() ?? 0,
      pendingCents: (json['pendingCents'] as num?)?.toInt() ?? 0,
      heldCents: (json['heldCents'] as num?)?.toInt() ?? 0,
      paidOutCents: (json['paidOutCents'] as num?)?.toInt() ?? 0,
      minWithdrawalCents: (json['minWithdrawalCents'] as num?)?.toInt() ?? 5000,
      canWithdraw: json['canWithdraw'] as bool? ?? false,
      entries: ((json['entries'] as List?) ?? const <dynamic>[])
          .map((e) => WalletEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
