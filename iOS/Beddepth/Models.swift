import Foundation

struct Layer: Identifiable, Codable, Equatable {
    var id: UUID
    var createdAt: Date
    var bedName: String
    var amendment: String
    var depthIn: Double
    var notes: String

    init(id: UUID = UUID(), createdAt: Date = Date(), bedName: String = "", amendment: String = "", depthIn: Double = 0, notes: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.bedName = bedName
        self.amendment = amendment
        self.depthIn = depthIn
        self.notes = notes
    }
}
