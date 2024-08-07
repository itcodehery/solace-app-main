class DayCalc {
  final DateTime? date;

  DayCalc({required this.date});

  String get dayAgo {
    if (date!.day == DateTime.now().day) {
      return "Today";
    } else if (date!.day ==
        DateTime.now().subtract(const Duration(days: 1)).day) {
      return "Yesterday";
    } else {
      return "${date!.day}/${date!.month}/${date!.year}";
    }
  }
}
