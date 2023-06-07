import 'dart:convert';

class Charger {
  String id;
  String station_id;
  String charger_state;
  String rate;
  Charger({
    required this.id,
    required this.station_id,
    required this.charger_state,
    required this.rate,
  });

  Charger copyWith({
    String? id,
    String? station_id,
    String? charger_state,
    String? rate,
  }) {
    return Charger(
      id: id ?? this.id,
      station_id: station_id ?? this.station_id,
      charger_state: charger_state ?? this.charger_state,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'station_id': station_id,
      'charger_state': charger_state,
      'rate': rate,
    };
  }

  factory Charger.fromMap(Map<String, dynamic> map) {
    return Charger(
      id: map['id'] as String,
      station_id: map['station_id'] as String,
      charger_state: map['charger_state'] as String,
      rate: map['rate'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Charger.fromJson(String source) => Charger.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Charger(id: $id, station_id: $station_id, charger_state: $charger_state, rate: $rate)';
  }

  @override
  bool operator ==(covariant Charger other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.station_id == station_id &&
        other.charger_state == charger_state &&
        other.rate == rate;
  }

  @override
  int get hashCode {
    return id.hashCode ^ station_id.hashCode ^ charger_state.hashCode ^ rate.hashCode;
  }
}
