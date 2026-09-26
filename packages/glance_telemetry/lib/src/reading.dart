import 'freshness.dart';

final class Reading<T extends Object> {
  final Freshness freshness;

  final T? value;

  const Reading({required this.freshness, this.value});

  const Reading.missing() : this(freshness: Freshness.missing);

  bool get isLive => freshness == Freshness.live;

  T? get liveValue => isLive ? value : null;

  @override
  bool operator ==(Object other) => other is Reading<T> && other.freshness == freshness && other.value == value;

  @override
  int get hashCode => Object.hash(freshness, value);
}
