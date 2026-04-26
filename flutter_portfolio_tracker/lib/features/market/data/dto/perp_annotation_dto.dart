class PerpAnnotationDto {
  const PerpAnnotationDto({
    this.category,
    this.description,
  });

  factory PerpAnnotationDto.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const PerpAnnotationDto();
    }
    return PerpAnnotationDto(
      category: json['category'] as String?,
      description: json['description'] as String?,
    );
  }

  final String? category;
  final String? description;
}
