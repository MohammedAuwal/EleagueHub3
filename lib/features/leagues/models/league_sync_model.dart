import 'league_format.dart';

/// Represents a league that can exist offline and sync later.
class LocalLeague {
  final String id;
  final String name;
  final LeagueFormat format;
  final bool isSynced; // False if local changes haven't reached the server
  final int lastModified; // Timestamp to handle "Vice Versa" sync logic

  const LocalLeague({
    required this.id,
    required this.name,
    required this.format,
    this.isSynced = false,
    required this.lastModified,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'format': format.index,
    'isSynced': isSynced ? 1 : 0,
    'lastModified': lastModified,
  };
}
