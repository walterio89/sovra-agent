String timeAgo(DateTime? dt) {
  if (dt == null) return 'mai';
  final diff = DateTime.now().difference(dt);

  if (diff.inSeconds < 10) return 'adesso';
  if (diff.inSeconds < 60) return '${diff.inSeconds}s fa';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min fa';
  if (diff.inHours < 24) return '${diff.inHours} h fa';
  return '${diff.inDays} g fa';
}
