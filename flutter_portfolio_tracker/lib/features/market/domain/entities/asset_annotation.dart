import 'package:equatable/equatable.dart';

class AssetAnnotation extends Equatable {
  const AssetAnnotation({
    required this.coin,
    required this.description,
    this.category,
  });

  final String coin;
  final String description;
  final String? category;

  static AssetAnnotation empty(String coin) => AssetAnnotation(
        coin: coin,
        description: '',
      );

  @override
  List<Object?> get props => [coin, description, category];
}
