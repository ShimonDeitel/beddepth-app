import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Layer] = []
    @Published var isPro: Bool = false

    static let freeLimit = 25

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("beddepth_items.json")
        load()
    }

    var canAddMore: Bool { isPro || items.count < Store.freeLimit }

    func add(_ item: Layer) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: Layer) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Layer) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Layer].self, from: data) {
            items = decoded
        } else {
            items = [
        Layer(bedName: "Bed A", amendment: "Compost", depthIn: 2, notes: ""),
        Layer(bedName: "Bed A", amendment: "Aged manure", depthIn: 1, notes: ""),
        Layer(bedName: "Bed B", amendment: "Leaf mold", depthIn: 3, notes: "")
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
