class Employee {
  final int? id;
  final String employeeId;
  final String name;
  final String phone;
  final String role; // DRIVER, COLLECTOR
  final String? assignedZone;
  final String? shift;
  final String status; // AVAILABLE, ON_DUTY, OFF_DUTY, LEAVE
  final bool active;

  Employee({
    this.id,
    required this.employeeId,
    required this.name,
    required this.phone,
    required this.role,
    this.assignedZone,
    this.shift,
    required this.status,
    required this.active,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int?,
      employeeId: json['employeeId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      assignedZone: json['assignedZone'] as String?,
      shift: json['shift'] as String?,
      status: json['status'] as String,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'name': name,
      'phone': phone,
      'role': role,
      'assignedZone': assignedZone,
      'shift': shift,
      'status': status,
      'active': active,
    };
  }
}

class Vehicle {
  final int? id;
  final String registrationNumber;
  final String vehicleType;
  final double capacity;
  final String status; // AVAILABLE, ON_DUTY, MAINTENANCE, INACTIVE
  final DateTime? lastServiceDate;
  final DateTime? nextServiceDate;
  final bool active;

  Vehicle({
    this.id,
    required this.registrationNumber,
    required this.vehicleType,
    required this.capacity,
    required this.status,
    this.lastServiceDate,
    this.nextServiceDate,
    required this.active,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int?,
      registrationNumber: json['registrationNumber'] as String,
      vehicleType: json['vehicleType'] as String,
      capacity: (json['capacity'] as num).toDouble(),
      status: json['status'] as String,
      lastServiceDate: json['lastServiceDate'] != null
          ? DateTime.parse(json['lastServiceDate'] as String)
          : null,
      nextServiceDate: json['nextServiceDate'] != null
          ? DateTime.parse(json['nextServiceDate'] as String)
          : null,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      'vehicleType': vehicleType,
      'capacity': capacity,
      'status': status,
      'lastServiceDate': lastServiceDate?.toIso8601String().substring(0, 10),
      'nextServiceDate': nextServiceDate?.toIso8601String().substring(0, 10),
      'active': active,
    };
  }
}

class CollectionJob {
  final int? id;
  final String routeId;
  final String title;
  final String? description;
  final String zone;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  CollectionJob({
    this.id,
    required this.routeId,
    required this.title,
    this.description,
    required this.zone,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory CollectionJob.fromJson(Map<String, dynamic> json) {
    return CollectionJob(
      id: json['id'] as int?,
      routeId: json['routeId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      zone: json['zone'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'title': title,
      'description': description,
      'zone': zone,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
    };
  }
}

class ResourceAssignment {
  final int? id;
  final CollectionJob job;
  final Vehicle vehicle;
  final Employee driver;
  final List<Employee> collectors;
  final String status;
  final DateTime assignmentDate;

  ResourceAssignment({
    this.id,
    required this.job,
    required this.vehicle,
    required this.driver,
    required this.collectors,
    required this.status,
    required this.assignmentDate,
  });

  factory ResourceAssignment.fromJson(Map<String, dynamic> json) {
    var colsList = json['collectors'] as List;
    List<Employee> cols = colsList.map((c) => Employee.fromJson(c as Map<String, dynamic>)).toList();

    return ResourceAssignment(
      id: json['id'] as int?,
      job: CollectionJob.fromJson(json['job'] as Map<String, dynamic>),
      vehicle: Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>),
      driver: Employee.fromJson(json['driver'] as Map<String, dynamic>),
      collectors: cols,
      status: json['status'] as String,
      assignmentDate: DateTime.parse(json['assignmentDate'] as String),
    );
  }
}

class AssignmentRequest {
  final int jobId;
  final int vehicleId;
  final int driverId;
  final List<int> collectorIds;

  AssignmentRequest({
    required this.jobId,
    required this.vehicleId,
    required this.driverId,
    required this.collectorIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'collectorIds': collectorIds,
    };
  }
}

class NotificationModel {
  final int? id;
  final String employeeId;
  final String title;
  final String message;
  final DateTime dateTime;
  final bool read;

  NotificationModel({
    this.id,
    required this.employeeId,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      employeeId: json['employeeId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      read: json['read'] as bool? ?? false,
    );
  }
}
