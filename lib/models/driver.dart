import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String cpf;
  final String cnh;
  final String? profileImageUrl;
  final Vehicle vehicle;
  final DriverLocation? location;
  final String status; // offline, online, busy
  final double rating;
  final int totalRides;
  final double totalEarnings;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> documents; // URLs dos documentos
  final BankAccount? bankAccount;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.cpf,
    required this.cnh,
    this.profileImageUrl,
    required this.vehicle,
    this.location,
    required this.status,
    this.rating = 5.0,
    this.totalRides = 0,
    this.totalEarnings = 0.0,
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
    this.documents = const [],
    this.bankAccount,
  });

  factory Driver.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Driver(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      cpf: data['cpf'] ?? '',
      cnh: data['cnh'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      vehicle: Vehicle.fromMap(data['vehicle'] ?? {}),
      location: data['location'] != null 
          ? DriverLocation.fromMap(data['location']) 
          : null,
      status: data['status'] ?? 'offline',
      rating: (data['rating'] ?? 5.0).toDouble(),
      totalRides: data['totalRides'] ?? 0,
      totalEarnings: (data['totalEarnings'] ?? 0.0).toDouble(),
      isActive: data['isActive'] ?? true,
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      documents: List<String>.from(data['documents'] ?? []),
      bankAccount: data['bankAccount'] != null 
          ? BankAccount.fromMap(data['bankAccount']) 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'cpf': cpf,
      'cnh': cnh,
      'profileImageUrl': profileImageUrl,
      'vehicle': vehicle.toMap(),
      'location': location?.toMap(),
      'status': status,
      'rating': rating,
      'totalRides': totalRides,
      'totalEarnings': totalEarnings,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'documents': documents,
      'bankAccount': bankAccount?.toMap(),
    };
  }

  Driver copyWith({
    String? name,
    String? email,
    String? phone,
    String? cpf,
    String? cnh,
    String? profileImageUrl,
    Vehicle? vehicle,
    DriverLocation? location,
    String? status,
    double? rating,
    int? totalRides,
    double? totalEarnings,
    bool? isActive,
    bool? isVerified,
    DateTime? updatedAt,
    List<String>? documents,
    BankAccount? bankAccount,
  }) {
    return Driver(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cpf: cpf ?? this.cpf,
      cnh: cnh ?? this.cnh,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      vehicle: vehicle ?? this.vehicle,
      location: location ?? this.location,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      documents: documents ?? this.documents,
      bankAccount: bankAccount ?? this.bankAccount,
    );
  }
}

class Vehicle {
  final String brand;
  final String model;
  final String year;
  final String color;
  final String plate;
  final String category; // economico, conforto, premium
  final int seats;
  final List<String> photos;
  final String? renavam;

  Vehicle({
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.plate,
    required this.category,
    this.seats = 4,
    this.photos = const [],
    this.renavam,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? '',
      color: map['color'] ?? '',
      plate: map['plate'] ?? '',
      category: map['category'] ?? 'economico',
      seats: map['seats'] ?? 4,
      photos: List<String>.from(map['photos'] ?? []),
      renavam: map['renavam'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'plate': plate,
      'category': category,
      'seats': seats,
      'photos': photos,
      'renavam': renavam,
    };
  }
}

class DriverLocation {
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final DateTime timestamp;

  DriverLocation({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    required this.timestamp,
  });

  factory DriverLocation.fromMap(Map<String, dynamic> map) {
    return DriverLocation(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      heading: map['heading']?.toDouble(),
      speed: map['speed']?.toDouble(),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class BankAccount {
  final String bank;
  final String agency;
  final String account;
  final String accountType; // corrente, poupanca
  final String holderName;
  final String holderCpf;

  BankAccount({
    required this.bank,
    required this.agency,
    required this.account,
    required this.accountType,
    required this.holderName,
    required this.holderCpf,
  });

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      bank: map['bank'] ?? '',
      agency: map['agency'] ?? '',
      account: map['account'] ?? '',
      accountType: map['accountType'] ?? 'corrente',
      holderName: map['holderName'] ?? '',
      holderCpf: map['holderCpf'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bank': bank,
      'agency': agency,
      'account': account,
      'accountType': accountType,
      'holderName': holderName,
      'holderCpf': holderCpf,
    };
  }
}

