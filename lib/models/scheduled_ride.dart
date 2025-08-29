enum ScheduledRideStatus {
  pending,
  confirmed,
  accepted,
  inProgress,
  cancelled,
  completed,
  available,
}

class ScheduledRide {
  final String id;
  final String passengerName;
  final String pickupAddress;
  final String destinationAddress;
  final DateTime scheduledTime;
  final double estimatedPrice;
  final double distance;
  final int estimatedDuration;
  ScheduledRideStatus status;
  final String notes;
  final DateTime createdAt;

  ScheduledRide({
    required this.id,
    required this.passengerName,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.scheduledTime,
    required this.estimatedPrice,
    required this.distance,
    required this.estimatedDuration,
    required this.status,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ScheduledRide.fromJson(Map<String, dynamic> json, [String? documentId]) {
    return ScheduledRide(
      id: documentId ?? json['id'],
      passengerName: json['passengerName'],
      pickupAddress: json['pickupAddress'],
      destinationAddress: json['destinationAddress'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      estimatedPrice: json['estimatedPrice'].toDouble(),
      distance: json['distance'].toDouble(),
      estimatedDuration: json['estimatedDuration'],
      status: ScheduledRideStatus.values.firstWhere(
        (e) => e.toString() == 'ScheduledRideStatus.${json['status']}',
        orElse: () => ScheduledRideStatus.pending,
      ),
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerName': passengerName,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'scheduledTime': scheduledTime.toIso8601String(),
      'estimatedPrice': estimatedPrice,
      'distance': distance,
      'estimatedDuration': estimatedDuration,
      'status': status.toString().split('.').last,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ScheduledRide copyWith({
    String? id,
    String? passengerName,
    String? pickupAddress,
    String? destinationAddress,
    DateTime? scheduledTime,
    double? estimatedPrice,
    double? distance,
    int? estimatedDuration,
    ScheduledRideStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return ScheduledRide(
      id: id ?? this.id,
      passengerName: passengerName ?? this.passengerName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      distance: distance ?? this.distance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}