import 'package:uuid/uuid.dart';

import 'estimate.dart';

enum FoundationType { strip, raft }

extension FoundationTypeLabel on FoundationType {
  String get label => this == FoundationType.strip ? 'Strip foundation' : 'Raft (slab) foundation';
}

FoundationType foundationTypeFromString(String value) {
  return FoundationType.values.firstWhere((t) => t.name == value, orElse: () => FoundationType.strip);
}

enum RoofType { flat, gable, hip }

extension RoofTypeLabel on RoofType {
  String get label {
    switch (this) {
      case RoofType.flat:
        return 'Flat roof';
      case RoofType.gable:
        return 'Gable (pitched)';
      case RoofType.hip:
        return 'Hip (pitched)';
    }
  }

  /// Rough-and-ready multiplier over the building's footprint area to
  /// account for roof pitch/overhang. Not a substitute for a proper roof
  /// takeoff, but a reasonable starting quantity to review and adjust.
  double get areaMultiplier {
    switch (this) {
      case RoofType.flat:
        return 1.05;
      case RoofType.gable:
        return 1.15;
      case RoofType.hip:
        return 1.2;
    }
  }
}

enum RoomType { bedroom, bathroom, kitchen, living, other }

extension RoomTypeLabel on RoomType {
  String get label {
    switch (this) {
      case RoomType.bedroom:
        return 'Bedroom';
      case RoomType.bathroom:
        return 'Bathroom / Toilet';
      case RoomType.kitchen:
        return 'Kitchen';
      case RoomType.living:
        return 'Living / Dining';
      case RoomType.other:
        return 'Other';
    }
  }

  /// Rough electrical points (sockets + lighting) typically wired per room
  /// of this type - a starting quantity for the electrical line item.
  int get electricalPoints {
    switch (this) {
      case RoomType.bedroom:
        return 6;
      case RoomType.bathroom:
        return 3;
      case RoomType.kitchen:
        return 8;
      case RoomType.living:
        return 8;
      case RoomType.other:
        return 4;
    }
  }

  /// Rough plumbing fixture count for rooms that need water/drainage.
  int get plumbingFixtures {
    switch (this) {
      case RoomType.bathroom:
        return 4; // WC, sink, shower/bath, floor drain
      case RoomType.kitchen:
        return 2; // sink, drain
      default:
        return 0;
    }
  }
}

RoomType roomTypeFromString(String value) {
  return RoomType.values.firstWhere((t) => t.name == value, orElse: () => RoomType.other);
}

class RoomSpec {
  final String id;
  final String name;
  final RoomType type;
  final double lengthM;
  final double widthM;

  const RoomSpec({
    required this.id,
    required this.name,
    required this.type,
    required this.lengthM,
    required this.widthM,
  });

  double get areaM2 => lengthM * widthM;

  factory RoomSpec.newRoom({
    required String name,
    required RoomType type,
    required double lengthM,
    required double widthM,
  }) {
    return RoomSpec(id: const Uuid().v4(), name: name, type: type, lengthM: lengthM, widthM: widthM);
  }

  factory RoomSpec.fromMap(Map<String, dynamic> map) {
    return RoomSpec(
      id: map['id'] as String? ?? const Uuid().v4(),
      name: map['name'] as String? ?? '',
      type: roomTypeFromString(map['type'] as String? ?? 'other'),
      lengthM: (map['lengthM'] as num?)?.toDouble() ?? 0,
      widthM: (map['widthM'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'type': type.name, 'lengthM': lengthM, 'widthM': widthM};
  }
}

/// A structured, editable description of a house's layout - filled in by a
/// company admin while looking at the architect's plan drawing - used to
/// auto-suggest a full foundation-to-roofing cost estimate. This is a
/// deliberately simple geometric model (it does not parse the plan image
/// itself); every suggested quantity is a starting point the estimator can
/// review and adjust.
class BuildingSpec {
  final int floors;
  final double footprintLengthM;
  final double footprintWidthM;
  final double wallHeightM;
  final FoundationType foundationType;
  final RoofType roofType;
  final List<RoomSpec> rooms;

  const BuildingSpec({
    required this.floors,
    required this.footprintLengthM,
    required this.footprintWidthM,
    required this.wallHeightM,
    required this.foundationType,
    required this.roofType,
    required this.rooms,
  });

  factory BuildingSpec.empty() => const BuildingSpec(
        floors: 1,
        footprintLengthM: 0,
        footprintWidthM: 0,
        wallHeightM: 3.0,
        foundationType: FoundationType.strip,
        roofType: RoofType.gable,
        rooms: [],
      );

  double get footprintAreaM2 => footprintLengthM * footprintWidthM;
  double get footprintPerimeterM => 2 * (footprintLengthM + footprintWidthM);
  double get totalFloorAreaM2 => footprintAreaM2 * floors;

  BuildingSpec copyWith({
    int? floors,
    double? footprintLengthM,
    double? footprintWidthM,
    double? wallHeightM,
    FoundationType? foundationType,
    RoofType? roofType,
    List<RoomSpec>? rooms,
  }) {
    return BuildingSpec(
      floors: floors ?? this.floors,
      footprintLengthM: footprintLengthM ?? this.footprintLengthM,
      footprintWidthM: footprintWidthM ?? this.footprintWidthM,
      wallHeightM: wallHeightM ?? this.wallHeightM,
      foundationType: foundationType ?? this.foundationType,
      roofType: roofType ?? this.roofType,
      rooms: rooms ?? this.rooms,
    );
  }

  factory BuildingSpec.fromMap(Map<String, dynamic>? map) {
    if (map == null) return BuildingSpec.empty();
    return BuildingSpec(
      floors: (map['floors'] as num?)?.toInt() ?? 1,
      footprintLengthM: (map['footprintLengthM'] as num?)?.toDouble() ?? 0,
      footprintWidthM: (map['footprintWidthM'] as num?)?.toDouble() ?? 0,
      wallHeightM: (map['wallHeightM'] as num?)?.toDouble() ?? 3.0,
      foundationType: foundationTypeFromString(map['foundationType'] as String? ?? 'strip'),
      roofType: RoofType.values.firstWhere(
        (t) => t.name == (map['roofType'] as String? ?? 'gable'),
        orElse: () => RoofType.gable,
      ),
      rooms: List<Map<String, dynamic>>.from(
        (map['rooms'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      ).map(RoomSpec.fromMap).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'floors': floors,
      'footprintLengthM': footprintLengthM,
      'footprintWidthM': footprintWidthM,
      'wallHeightM': wallHeightM,
      'foundationType': foundationType.name,
      'roofType': roofType.name,
      'rooms': rooms.map((r) => r.toMap()).toList(),
    };
  }
}

/// Turns a [BuildingSpec] into a starting set of estimate line items across
/// every trade, from foundation through to finishes. Quantities are simple,
/// transparent rules of thumb (documented per item) meant to be reviewed and
/// adjusted, not a precise structural takeoff.
class TakeoffCalculator {
  static List<EstimateItem> generate(BuildingSpec spec) {
    if (spec.footprintAreaM2 <= 0) return [];

    final items = <EstimateItem>[];
    final perimeter = spec.footprintPerimeterM;

    if (spec.foundationType == FoundationType.strip) {
      items.add(EstimateItem.newItem(
        phase: ConstructionPhase.foundation,
        description: 'Strip foundation excavation & concrete (perimeter × 1.0m depth × 0.6m width)',
        quantity: double.parse((perimeter * 1.0 * 0.6).toStringAsFixed(2)),
        unit: 'm³',
        unitMaterialCost: 0,
        laborCost: 0,
      ));
    } else {
      items.add(EstimateItem.newItem(
        phase: ConstructionPhase.foundation,
        description: 'Raft foundation slab (footprint area × 0.3m thickness)',
        quantity: double.parse((spec.footprintAreaM2 * 0.3).toStringAsFixed(2)),
        unit: 'm³',
        unitMaterialCost: 0,
        laborCost: 0,
      ));
    }

    items.add(EstimateItem.newItem(
      phase: ConstructionPhase.substructure,
      description: 'Sub-structure walling & damp-proof course (perimeter × 0.45m)',
      quantity: double.parse((perimeter * 0.45).toStringAsFixed(2)),
      unit: 'm²',
      unitMaterialCost: 0,
      laborCost: 0,
    ));

    items.add(EstimateItem.newItem(
      phase: ConstructionPhase.superstructure,
      description:
          'Blockwork walling, ${spec.floors} floor(s) (perimeter × wall height × floors, openings not deducted)',
      quantity: double.parse((perimeter * spec.wallHeightM * spec.floors).toStringAsFixed(2)),
      unit: 'm²',
      unitMaterialCost: 0,
      laborCost: 0,
    ));

    items.add(EstimateItem.newItem(
      phase: ConstructionPhase.roofing,
      description: '${spec.roofType.label} covering & trusses (footprint × ${spec.roofType.areaMultiplier})',
      quantity: double.parse((spec.footprintAreaM2 * spec.roofType.areaMultiplier).toStringAsFixed(2)),
      unit: 'm²',
      unitMaterialCost: 0,
      laborCost: 0,
    ));

    final electricalPoints = spec.rooms.fold<int>(0, (sum, r) => sum + r.type.electricalPoints);
    if (electricalPoints > 0) {
      items.add(EstimateItem.newItem(
        phase: ConstructionPhase.electrical,
        description: 'Wiring, sockets & lighting points (sum of room allowances)',
        quantity: electricalPoints.toDouble(),
        unit: 'point',
        unitMaterialCost: 0,
        laborCost: 0,
      ));
    }

    final plumbingFixtures = spec.rooms.fold<int>(0, (sum, r) => sum + r.type.plumbingFixtures);
    if (plumbingFixtures > 0) {
      items.add(EstimateItem.newItem(
        phase: ConstructionPhase.plumbing,
        description: 'Pipework & fixtures - WC, sinks, showers, drains (sum of room allowances)',
        quantity: plumbingFixtures.toDouble(),
        unit: 'fixture',
        unitMaterialCost: 0,
        laborCost: 0,
      ));
    }

    items.add(EstimateItem.newItem(
      phase: ConstructionPhase.finishes,
      description: 'Floor, wall & ceiling finishes (total floor area × floors)',
      quantity: double.parse(spec.totalFloorAreaM2.toStringAsFixed(2)),
      unit: 'm²',
      unitMaterialCost: 0,
      laborCost: 0,
    ));

    return items;
  }
}
