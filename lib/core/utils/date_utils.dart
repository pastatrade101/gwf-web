String timeAgo(DateTime? dt) {
  if (dt == null) return "—";
  final now = DateTime.now();
  final d = DateTime(dt.year, dt.month, dt.day);
  final n = DateTime(now.year, now.month, now.day);
  final diff = n.difference(d).inDays;

  if (diff == 0) return "Today";
  if (diff == 1) return "Yesterday";
  if (diff < 7) return "$diff days ago";

  final mm = dt.month.toString().padLeft(2, '0');
  final dd = dt.day.toString().padLeft(2, '0');
  return "${dt.year}-$mm-$dd";
}