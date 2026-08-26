import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// The standard construction phases/trades covered by the estimator,
/// ordered from foundation through to roofing, services, and finishes.
enum ConstructionPhase {
  siteworks,
  foundation,
  substructure,
  superstructure,
  roofing,
  electrical,
  plumbing,
  finishes,
}

extension ConstructionPhaseLabel on ConstructionPhase {
  String get label {
    switch (this) {
      case ConstructionPhase.siteworks:
        return 'Siteworks & Excavation';
      case ConstructionPhase.foundation:
        return 'Foundation';
      case ConstructionPhase.substructure:
        return 'Substructure & DPC';
      case ConstructionPhase.superstructure:
        return 'Superstructure & Walls';
      case ConstructionPhase.roofing:
        return 'Roofing';
      case ConstructionPhase.electrical:
        return 'Electrical';
      case ConstructionPhase.plumbing:
        return 'Plumbing';
      case ConstructionPhase.finishes:
        return 'Finishes';
    }
  }
}

ConstructionPhase constructionPhaseFromString(String value) {
  return ConstructionPhase.values.firstWhere(
    (p) => p.name == value,
    orElse: () => ConstructionPhase.foundation,
  );
}

/// A single line item within a phase: a material or work item with a
/// quantity, unit cost, and an associated labor cost.
class EstimateItem {
  final String id;
  final ConstructionPhase phase;
  final String description;
  final double quantity;
  final String unit;
  final double unitMaterialCost;
  final double laborCost;

  const EstimateItem({
    required this.id,
    required this.phase,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitMaterialCost,
    required this.laborCost,
  });

  double get materialTotal => quantity * unitMaterialCost;
  double get total => materialTotal + laborCost;

  factory EstimateItem.newItem({
    required ConstructionPhase phase,
    required String description,
    required double quantity,
    required String unit,
    required double unitMaterialCost,
    required double laborCost,
  }) {
    return EstimateItem(
      id: const Uuid().v4(),
      phase: phase,
      description: description,
      quantity: quantity,
      unit: unit,
      unitMaterialCost: unitMaterialCost,
      laborCost: laborCost,
    );
  }

  factory EstimateItem.fromMap(Map<String, dynamic> map) {
    return EstimateItem(
      id: map['id'] as String? ?? const Uuid().v4(),
      phase: constructionPhaseFromString(map['phase'] as String? ?? 'foundation'),
      description: map['description'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? '',
      unitMaterialCost: (map['unitMaterialCost'] as num?)?.toDouble() ?? 0,
      laborCost: (map['laborCost'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phase': phase.name,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unitMaterialCost': unitMaterialCost,
      'laborCost': laborCost,
    };
  }
}

/// A full cost estimate for a project, made up of line items across
/// every construction phase from foundation through to roofing.
class Estimate {
  final String id;
  final String companyId;
  final String projectId;
  final String title;
  final List<EstimateItem> items;
  final String createdBy;
  final DateTime createdAt;

  const Estimate({
    required this.id,
    required this.companyId,
    required this.projectId,
    required this.title,
    required this.items,
    required this.createdBy,
    required this.createdAt,
  });

  double get materialTotal => items.fold(0, (acc, i) => acc + i.materialTotal);
  double get laborTotal => items.fold(0, (acc, i) => acc + i.laborCost);
  double get grandTotal => materialTotal + laborTotal;

  List<EstimateItem> itemsForPhase(ConstructionPhase phase) =>
      items.where((i) => i.phase == phase).toList();

  double phaseTotal(ConstructionPhase phase) =>
      itemsForPhase(phase).fold(0, (acc, i) => acc + i.total);

  factory Estimate.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final rawItems = List<Map<String, dynamic>>.from(
      (data['items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    return Estimate(
      id: doc.id,
      companyId: data['companyId'] as String? ?? '',
      projectId: data['projectId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      items: rawItems.map(EstimateItem.fromMap).toList(),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'projectId': projectId,
      'title': title,
      'items': items.map((i) => i.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
