class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // donor, ngo, volunteer, admin
  final String? profileImage;
  final Address? address;
  final Location? location;
  final bool isVerified;
  final bool isActive;
  final double totalDonated;
  final NGODetails? ngoDetails;
  final VolunteerDetails? volunteerDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.address,
    this.location,
    this.isVerified = false,
    this.isActive = true,
    this.totalDonated = 0.0,
    this.ngoDetails,
    this.volunteerDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  // From JSON (API Response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'donor',
      profileImage: json['profileImage'],
      address: json['address'] != null 
          ? Address.fromJson(json['address']) 
          : null,
      location: json['location'] != null 
          ? Location.fromJson(json['location']) 
          : null,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      totalDonated: (json['totalDonated'] ?? 0).toDouble(),
      ngoDetails: json['ngoDetails'] != null 
          ? NGODetails.fromJson(json['ngoDetails']) 
          : null,
      volunteerDetails: json['volunteerDetails'] != null 
          ? VolunteerDetails.fromJson(json['volunteerDetails']) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // To JSON (API Request)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'address': address?.toJson(),
      'location': location?.toJson(),
      'isVerified': isVerified,
      'isActive': isActive,
      'totalDonated': totalDonated,
      'ngoDetails': ngoDetails?.toJson(),
      'volunteerDetails': volunteerDetails?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profileImage,
    Address? address,
    Location? location,
    bool? isVerified,
    bool? isActive,
    double? totalDonated,
    NGODetails? ngoDetails,
    VolunteerDetails? volunteerDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      totalDonated: totalDonated ?? this.totalDonated,
      ngoDetails: ngoDetails ?? this.ngoDetails,
      volunteerDetails: volunteerDetails ?? this.volunteerDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  bool get isDonor => role == 'donor';
  bool get isNGO => role == 'ngo';
  bool get isVolunteer => role == 'volunteer';
  bool get isAdmin => role == 'admin';
  
  String get displayRole {
    switch (role) {
      case 'donor':
        return 'Donor';
      case 'ngo':
        return 'NGO';
      case 'volunteer':
        return 'Volunteer';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }
}

// Address Model
class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? pincode;
  final String country;

  Address({
    this.street,
    this.city,
    this.state,
    this.pincode,
    this.country = 'India',
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'] ?? 'India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };
  }

  String get fullAddress {
    final parts = [street, city, state, pincode, country]
        .where((part) => part != null && part.isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}

// Location Model
class Location {
  final String type;
  final List<double> coordinates; // [longitude, latitude]

  Location({
    this.type = 'Point',
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates'] ?? [0.0, 0.0]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
  double get latitude => coordinates.length > 1 ? coordinates[1] : 0.0;
}

// NGO Details Model
class NGODetails {
  final String? organizationName;
  final String? registrationNumber;
  final String? description;
  final String? website;
  final DateTime? established;
  final bool verified;

  NGODetails({
    this.organizationName,
    this.registrationNumber,
    this.description,
    this.website,
    this.established,
    this.verified = false,
  });

  factory NGODetails.fromJson(Map<String, dynamic> json) {
    return NGODetails(
      organizationName: json['organizationName'],
      registrationNumber: json['registrationNumber'],
      description: json['description'],
      website: json['website'],
      established: json['established'] != null 
          ? DateTime.parse(json['established']) 
          : null,
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizationName': organizationName,
      'registrationNumber': registrationNumber,
      'description': description,
      'website': website,
      'established': established?.toIso8601String(),
      'verified': verified,
    };
  }
}

// Volunteer Details Model
class VolunteerDetails {
  final List<String> skills;
  final String? availability;
  final String? experience;
  final int eventsAttended;
  final int totalHours;
  final String badge;

  VolunteerDetails({
    this.skills = const [],
    this.availability,
    this.experience,
    this.eventsAttended = 0,
    this.totalHours = 0,
    this.badge = 'Beginner',
  });

  factory VolunteerDetails.fromJson(Map<String, dynamic> json) {
    return VolunteerDetails(
      skills: List<String>.from(json['skills'] ?? []),
      availability: json['availability'],
      experience: json['experience'],
      eventsAttended: json['eventsAttended'] ?? 0,
      totalHours: json['totalHours'] ?? 0,
      badge: json['badge'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skills': skills,
      'availability': availability,
      'experience': experience,
      'eventsAttended': eventsAttended,
      'totalHours': totalHours,
      'badge': badge,
    };
  }

  // Badge level helpers
  int get badgeLevel {
    switch (badge) {
      case 'Beginner':
        return 1;
      case 'Helper':
        return 2;
      case 'Contributor':
        return 3;
      case 'Champion':
        return 4;
      case 'Hero':
        return 5;
      case 'Legend':
        return 6;
      default:
        return 1;
    }
  }

  String get nextBadge {
    switch (badge) {
      case 'Beginner':
        return 'Helper';
      case 'Helper':
        return 'Contributor';
      case 'Contributor':
        return 'Champion';
      case 'Champion':
        return 'Hero';
      case 'Hero':
        return 'Legend';
      case 'Legend':
        return 'Legend';
      default:
        return 'Helper';
    }
  }

  int get eventsToNextBadge {
    if (eventsAttended < 5) return 5 - eventsAttended;
    if (eventsAttended < 10) return 10 - eventsAttended;
    if (eventsAttended < 20) return 20 - eventsAttended;
    if (eventsAttended < 30) return 30 - eventsAttended;
    if (eventsAttended < 50) return 50 - eventsAttended;
    return 0;
  }
}