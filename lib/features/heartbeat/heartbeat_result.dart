sealed class HeartbeatResult {
  const HeartbeatResult();

  factory HeartbeatResult.ok({required int deviceId, required DateTime lastSeenAt}) = HeartbeatOk;
  factory HeartbeatResult.offline({required String message}) = HeartbeatOffline;
  factory HeartbeatResult.reconnect({required String reason}) = HeartbeatReconnect;
  factory HeartbeatResult.blocked() = HeartbeatBlocked;
}

class HeartbeatOk extends HeartbeatResult {
  const HeartbeatOk({required this.deviceId, required this.lastSeenAt});
  final int deviceId;
  final DateTime lastSeenAt;
}

class HeartbeatOffline extends HeartbeatResult {
  const HeartbeatOffline({required this.message});
  final String message;
}

class HeartbeatReconnect extends HeartbeatResult {
  const HeartbeatReconnect({required this.reason});
  final String reason;
}

class HeartbeatBlocked extends HeartbeatResult {
  const HeartbeatBlocked();
}
