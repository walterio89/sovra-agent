enum SovraSafetyState { protected, attention, blocked, offline }

class HomeStatus {
  HomeStatus({required this.state, required this.subtitle, required this.lastSeenLabel});

  final SovraSafetyState state;
  final String subtitle;
  final String lastSeenLabel;
}
