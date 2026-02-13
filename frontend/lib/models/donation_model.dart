class Donation {
  final String id;
  final String donor;
  final String campaign;
  final String ngo;
  final double amount;
  final String paymentMethod;
  final String? transactionId;
  final String paymentStatus;
  final String? receiptNumber;
  final String donationType;
  final List<DonationItem>? items;
  final bool isAnonymous;
  final String? message;
  final TaxExemption? taxExemption;
  final Refund? refund;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields (from API response)
  final DonorInfo? donorInfo;
  final CampaignInfo? campaignInfo;
  final NGOInfo? ngoInfo;

  Donation({
    required this.id,
    required this.donor,
    required this.campaign,
    required this.ngo,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    this.paymentStatus = 'pending',
    this.receiptNumber,
    this.donationType = 'monetary',
    this.items,
    this.isAnonymous = false,
    this.message,
    this.taxExemption,
    this.refund,
    required this.createdAt,
    required this.updatedAt,
    this.donorInfo,
    this.campaignInfo,
    this.ngoInfo,
  });

  // From JSON (API Response)
  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['_id'] ?? '',
      donor: json['donor'] is String 
          ? json['donor'] 
          : (json['donor']?['_id'] ?? ''),
      campaign: json['campaign'] is String 
          ? json['campaign'] 
          : (json['campaign']?['_id'] ?? ''),
      ngo: json['ngo'] is String 
          ? json['ngo'] 
          : (json['ngo']?['_id'] ?? ''),
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'card',
      transactionId: json['transactionId'],
      paymentStatus: json['paymentStatus'] ?? 'pending',
      receiptNumber: json['receiptNumber'],
      donationType: json['donationType'] ?? 'monetary',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => DonationItem.fromJson(item))
              .toList()
          : null,
      isAnonymous: json['isAnonymous'] ?? false,
      message: json['message'],
      taxExemption: json['taxExemption'] != null
          ? TaxExemption.fromJson(json['taxExemption'])
          : null,
      refund: json['refund'] != null
          ? Refund.fromJson(json['refund'])
          : null,
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updatedAt'] ?? DateTime.now().toIso8601String()),
      donorInfo: json['donor'] is Map
          ? DonorInfo.fromJson(json['donor'])
          : null,
      campaignInfo: json['campaign'] is Map
          ? CampaignInfo.fromJson(json['campaign'])
          : null,
      ngoInfo: json['ngo'] is Map
          ? NGOInfo.fromJson(json['ngo'])
          : null,
    );
  }

  // To JSON (API Request)
  Map<String, dynamic> toJson() {
    return {
      'donor': donor,
      'campaign': campaign,
      'ngo': ngo,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'paymentStatus': paymentStatus,
      'receiptNumber': receiptNumber,
      'donationType': donationType,
      'items': items?.map((item) => item.toJson()).toList(),
      'isAnonymous': isAnonymous,
      'message': message,
      'taxExemption': taxExemption?.toJson(),
      'refund': refund?.toJson(),
    };
  }

  // Copy with method
  Donation copyWith({
    String? id,
    String? donor,
    String? campaign,
    String? ngo,
    double? amount,
    String? paymentMethod,
    String? transactionId,
    String? paymentStatus,
    String? receiptNumber,
    String? donationType,
    List<DonationItem>? items,
    bool? isAnonymous,
    String? message,
    TaxExemption? taxExemption,
    Refund? refund,
    DateTime? createdAt,
    DateTime? updatedAt,
    DonorInfo? donorInfo,
    CampaignInfo? campaignInfo,
    NGOInfo? ngoInfo,
  }) {
    return Donation(
      id: id ?? this.id,
      donor: donor ?? this.donor,
      campaign: campaign ?? this.campaign,
      ngo: ngo ?? this.ngo,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      donationType: donationType ?? this.donationType,
      items: items ?? this.items,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      message: message ?? this.message,
      taxExemption: taxExemption ?? this.taxExemption,
      refund: refund ?? this.refund,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      donorInfo: donorInfo ?? this.donorInfo,
      campaignInfo: campaignInfo ?? this.campaignInfo,
      ngoInfo: ngoInfo ?? this.ngoInfo,
    );
  }

  // Helper getters
  bool get isPending => paymentStatus == 'pending';
  bool get isCompleted => paymentStatus == 'completed';
  bool get isFailed => paymentStatus == 'failed';
  bool get isRefunded => paymentStatus == 'refunded';

  bool get isMonetary => donationType == 'monetary';
  bool get isInKind => donationType == 'in-kind';

  String get statusDisplay {
    switch (paymentStatus) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return paymentStatus;
    }
  }

  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case 'card':
        return 'Credit/Debit Card';
      case 'upi':
        return 'UPI';
      case 'netbanking':
        return 'Net Banking';
      case 'wallet':
        return 'Wallet';
      case 'cash':
        return 'Cash';
      default:
        return paymentMethod;
    }
  }

  String get formattedAmount {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String get donorName {
    if (isAnonymous) return 'Anonymous';
    return donorInfo?.name ?? 'Donor';
  }
}

// Donation Item Model (for in-kind donations)
class DonationItem {
  final String name;
  final int quantity;
  final double? value;

  DonationItem({
    required this.name,
    required this.quantity,
    this.value,
  });

  factory DonationItem.fromJson(Map<String, dynamic> json) {
    return DonationItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      value: json['value']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'value': value,
    };
  }

  String get formattedValue {
    return value != null ? '₹${value!.toStringAsFixed(2)}' : 'N/A';
  }
}

// Tax Exemption Model
class TaxExemption {
  final bool eligible;
  final bool certificateGenerated;
  final String? certificateUrl;

  TaxExemption({
    this.eligible = true,
    this.certificateGenerated = false,
    this.certificateUrl,
  });

  factory TaxExemption.fromJson(Map<String, dynamic> json) {
    return TaxExemption(
      eligible: json['eligible'] ?? true,
      certificateGenerated: json['certificateGenerated'] ?? false,
      certificateUrl: json['certificateUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eligible': eligible,
      'certificateGenerated': certificateGenerated,
      'certificateUrl': certificateUrl,
    };
  }
}

// Refund Model
class Refund {
  final bool requested;
  final DateTime? requestedAt;
  final String? reason;
  final String? status;
  final DateTime? processedAt;
  final String? processedBy;

  Refund({
    this.requested = false,
    this.requestedAt,
    this.reason,
    this.status,
    this.processedAt,
    this.processedBy,
  });

  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      requested: json['requested'] ?? false,
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'])
          : null,
      reason: json['reason'],
      status: json['status'],
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      processedBy: json['processedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requested': requested,
      'requestedAt': requestedAt?.toIso8601String(),
      'reason': reason,
      'status': status,
      'processedAt': processedAt?.toIso8601String(),
      'processedBy': processedBy,
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCompleted => status == 'completed';
}

// Donor Info (populated from API)
class DonorInfo {
  final String id;
  final String name;
  final String? email;

  DonorInfo({
    required this.id,
    required this.name,
    this.email,
  });

  factory DonorInfo.fromJson(Map<String, dynamic> json) {
    return DonorInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
    );
  }
}

// Campaign Info (populated from API)
class CampaignInfo {
  final String id;
  final String title;
  final String? category;

  CampaignInfo({
    required this.id,
    required this.title,
    this.category,
  });

  factory CampaignInfo.fromJson(Map<String, dynamic> json) {
    return CampaignInfo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'],
    );
  }
}

// NGO Info (populated from API)
class NGOInfo {
  final String id;
  final String organizationName;

  NGOInfo({
    required this.id,
    required this.organizationName,
  });

  factory NGOInfo.fromJson(Map<String, dynamic> json) {
    return NGOInfo(
      id: json['_id'] ?? '',
      organizationName: json['organizationName'] ?? '',
    );
  }
}

// Donation Statistics Model
class DonationStats {
  final int totalDonations;
  final double totalAmount;
  final int campaignsSupported;
  final int peopleHelped;

  DonationStats({
    required this.totalDonations,
    required this.totalAmount,
    required this.campaignsSupported,
    required this.peopleHelped,
  });

  factory DonationStats.fromJson(Map<String, dynamic> json) {
    return DonationStats(
      totalDonations: json['totalDonations'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      campaignsSupported: json['campaignsSupported'] ?? 0,
      peopleHelped: json['peopleHelped'] ?? 0,
    );
  }

  String get formattedTotalAmount {
    return '₹${totalAmount.toStringAsFixed(2)}';
  }
}