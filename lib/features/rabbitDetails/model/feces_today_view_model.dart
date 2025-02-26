class FecesToday {
  String time;
  int quantity;

  FecesToday({
    required this.time,
    required this.quantity,
  });
}

class HealthHistoryItem {
  final int healthId;
  final String date;

  HealthHistoryItem({required this.healthId, required this.date});
}