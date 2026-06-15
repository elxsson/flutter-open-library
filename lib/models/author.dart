class Author {
  final String key;
  final String name;
  final String? bio;
  final String? birthDate;
  final String? deathDate;
  final String? olid;

  Author({
    required this.key,
    required this.name,
    this.bio,
    this.birthDate,
    this.deathDate,
    this.olid,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    String? parseBio(dynamic data) {
      if (data is String) return data;
      if (data is Map) return data['value']?.toString();
      return null;
    }

    final key = json['key']?.toString() ?? '';
    final parts = key.split('/');

    return Author(
      key: key,
      name: json['name']?.toString() ?? '',
      bio: parseBio(json['bio']),
      birthDate: json['birth_date']?.toString(),
      deathDate: json['death_date']?.toString(),
      olid: parts.length > 2 ? parts[2] : null,
    );
  }
}
