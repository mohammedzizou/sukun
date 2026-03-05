class PrayerTimeItem {
  final String name;
  final String time;
  final String iconPath;
  final bool isSilent;

  const PrayerTimeItem({
    required this.name,
    required this.time,
    required this.iconPath,
    required this.isSilent,
  });

  PrayerTimeItem copyWith({
    String? name,
    String? time,
    String? iconPath,
    bool? isSilent,
  }) {
    return PrayerTimeItem(
      name: name ?? this.name,
      time: time ?? this.time,
      iconPath: iconPath ?? this.iconPath,
      isSilent: isSilent ?? this.isSilent,
    );
  }
}
