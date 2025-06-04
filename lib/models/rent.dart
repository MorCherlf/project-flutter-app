import 'item_status.dart';

class Rent {
  final int rentId;
  final String itemId;
  final int userId;
  final String? startDate;
  final String? endDate;
  final bool? isBooking;
  final ItemStatus? rentStatus;

  Rent({
    required this.rentId,
    required this.itemId,
    required this.userId,
    this.startDate,
    this.endDate,
    this.isBooking,
    this.rentStatus,
  });
} 