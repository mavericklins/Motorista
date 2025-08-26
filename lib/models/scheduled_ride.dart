
class ScheduledRide {
  final String id;
  final String passengerId;
  final String? motoristaId;
  final String passengerName;
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final DateTime scheduledDateTime;
  final double estimatedFare;
  final String status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? specialInstructions;

  ScheduledRide({
    required this.id,
    required this.passengerId,
    this.motoristaId,
    required this.passengerName,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.scheduledDateTime,
    required this.estimatedFare,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.specialInstructions,
  });

  factory ScheduledRide.fromMap(Map<String, dynamic> map, String documentId) {
    return ScheduledRide(
      id: documentId,
      passengerId: map['passengerId'] ?? '',
      motoristaId: map['motoristaId'],
      passengerName: map['passengerName'] ?? '',
      pickupAddress: map['pickupAddress'] ?? '',
      destinationAddress: map['destinationAddress'] ?? '',
      pickupLatitude: (map['pickupLatitude'] ?? 0.0).toDouble(),
      pickupLongitude: (map['pickupLongitude'] ?? 0.0).toDouble(),
      destinationLatitude: (map['destinationLatitude'] ?? 0.0).toDouble(),
      destinationLongitude: (map['destinationLongitude'] ?? 0.0).toDouble(),
      scheduledDateTime: DateTime.parse(map['scheduledDateTime']),
      estimatedFare: (map['estimatedFare'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
      acceptedAt: map['acceptedAt'] != null ? DateTime.parse(map['acceptedAt']) : null,
      startedAt: map['startedAt'] != null ? DateTime.parse(map['startedAt']) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      cancelledAt: map['cancelledAt'] != null ? DateTime.parse(map['cancelledAt']) : null,
      cancellationReason: map['cancellationReason'],
      specialInstructions: map['specialInstructions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'passengerId': passengerId,
      'motoristaId': motoristaId,
      'passengerName': passengerName,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
      'estimatedFare': estimatedFare,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'specialInstructions': specialInstructions,
    };
  }

  ScheduledRide copyWith({
    String? id,
    String? passengerId,
    String? motoristaId,
    String? passengerName,
    String? pickupAddress,
    String? destinationAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    DateTime? scheduledDateTime,
    double? estimatedFare,
    String? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? specialInstructions,
  }) {
    return ScheduledRide(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      motoristaId: motoristaId ?? this.motoristaId,
      passengerName: passengerName ?? this.passengerName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}
