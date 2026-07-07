import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [PlanItem] = []
    @Published var isPro: Bool = false

    static let freeLimit = 15

    private let fileName = "storagecost_items.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([PlanItem].self, from: data) else {
            items = [
        PlanItem(provider: "iCloud+", monthlyFee: 2.99, capacityGB: 200, usedGB: 140),
        PlanItem(provider: "Google One", monthlyFee: 1.99, capacityGB: 100, usedGB: 60),
        PlanItem(provider: "Dropbox Plus", monthlyFee: 11.99, capacityGB: 2000, usedGB: 900)
            ]
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    @discardableResult
    func add(_ item: PlanItem) -> Bool {
        guard canAddMore else { return false }
        items.append(item)
        save()
        return true
    }

    func update(_ item: PlanItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: PlanItem) {
        items.removeAll(where: { $0.id == item.id })
        save()
    }
}
