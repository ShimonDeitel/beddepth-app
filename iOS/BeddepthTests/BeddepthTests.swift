import XCTest
@testable import Beddepth

@MainActor
final class BeddepthTests: XCTestCase {
    var store: Store!

    override func setUp() async throws {
        store = Store()
    }

    func testSeedDataLoadsUnderFreeLimit() {
        XCTAssertLessThan(store.items.count, Store.freeLimit)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        store.add(Layer(bedName: "Test", amendment: "Test", depthIn: 1, notes: "Test"))
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testDeleteDecreasesCount() {
        store.add(Layer(bedName: "Test", amendment: "Test", depthIn: 1, notes: "Test"))
        let before = store.items.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, before - 1)
    }

    func testDeleteByItem() {
        let item = Layer(bedName: "Test", amendment: "Test", depthIn: 1, notes: "Test")
        store.add(item)
        store.delete(item)
        XCTAssertFalse(store.items.contains(where: { $0.id == item.id }))
    }

    func testCanAddMoreWhenUnderLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtLimitWhenFree() {
        for _ in 0..<(Store.freeLimit + 5) {
            store.add(Layer(bedName: "Test", amendment: "Test", depthIn: 1, notes: "Test"))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testProAlwaysCanAddMore() {
        store.isPro = true
        for _ in 0..<(Store.freeLimit + 5) {
            store.add(Layer(bedName: "Test", amendment: "Test", depthIn: 1, notes: "Test"))
        }
        XCTAssertTrue(store.canAddMore)
    }

    func testUpdateModifiesItem() {
        let item = Layer(bedName: "Test", amendment: "Test", depthIn: 1, notes: "Test")
        store.add(item)
        var updated = item
        store.update(updated)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.id, item.id)
    }
}
