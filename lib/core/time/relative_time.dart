const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String shortDate(DateTime d) {
  final local = d.toLocal();
  return '${local.day} ${_months[local.month - 1]}';
}

String relativeTime(DateTime then, DateTime now) {
  final diff = now.difference(then);
  if (diff.inSeconds < 60) {
    return 'Just now';
  }
  if (diff.inMinutes < 60) {
    final mins = diff.inMinutes;
    return mins == 1 ? '1 minute ago' : '$mins minutes ago';
  }
  if (diff.inHours < 24) {
    final hrs = diff.inHours;
    return hrs == 1 ? '1 hour ago' : '$hrs hours ago';
  }
  if (diff.inDays == 1) {
    return 'Yesterday';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} days ago';
  }
  final weeks = diff.inDays ~/ 7;
  if (weeks < 5) {
    return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
  }
  final local = then.toLocal();
  return '${shortDate(then)} ${local.year}';
}
