import Foundation

struct PlanItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var provider: String
    var monthlyFee: Double
    var capacityGB: Double
    var usedGB: Double
    var dateAdded: Date = Date()
}
