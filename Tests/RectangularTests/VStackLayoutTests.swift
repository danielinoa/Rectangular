//
//  Created by Daniel Inoa on 1/4/24.
//

import XCTest
@testable import Rectangular

final class VStackLayoutTests: XCTestCase {

    func test_size_with_no_items() {
        let layout = VStackLayout()
        let size = layout.naturalSize(for: [])
        XCTAssertEqual(size, .zero)
    }

    func test_size_with_no_items_and_with_non_zero_spacing() {
        var layout = VStackLayout()
        layout.spacing = 10
        let size = layout.naturalSize(for: [])
        XCTAssertEqual(size, .zero)
    }

    func test_size_with_one_item_and_with_non_zero_spacing() {
        struct FixedItem: LayoutItem {
            var intrinsicSize: Size { .square(100) }
            func sizeThatFits(_ size: Size) -> Size { intrinsicSize }
        }
        var layout = VStackLayout()
        layout.spacing = 10
        let item1 = FixedItem()
        let size = layout.naturalSize(for: [item1])
        let expected = Size.square(100)
        XCTAssertEqual(size, expected)
    }

    func test_size_with_2_flexible_items() {
        struct Spacer: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { size }
        }
        let bounds = Size.square(100)
        let item1 = Spacer()
        let item2 = Spacer()
        let layout = VStackLayout()
        let size = layout.sizeThatFits(items: [item1, item2], within: bounds)
        let expected = Size.square(100)
        XCTAssertEqual(size, expected)
    }

    func test_size_with_2_flexible_items_and_spacing() {
        struct Spacer: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { size }
        }
        let bounds = Size.square(100)
        let item1 = Spacer()
        let item2 = Spacer()
        let layout = VStackLayout.init(spacing: 10)
        let size = layout.sizeThatFits(items: [item1, item2], within: bounds)
        let expected = Size.square(100)
        XCTAssertEqual(size, expected)
    }

    func test_size_with_1_fixed_item() {
        struct FixedItem: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { .init(width: size.width, height: 50) }
        }
        let bounds = Size.square(100)
        let item1 = FixedItem()
        let layout = VStackLayout()
        let size = layout.sizeThatFits(items: [item1], within: bounds)
        let expected = Size.init(width: 100, height: 50)
        XCTAssertEqual(size, expected)
    }

    func test_size_with_1_fixed_item_with_spacing() {
        struct FixedItem: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { .init(width: size.width, height: 50) }
        }
        let bounds = Size.square(100)
        let item1 = FixedItem()
        let layout = VStackLayout(spacing: 10)
        let size = layout.sizeThatFits(items: [item1], within: bounds)
        let expected = Size.init(width: 100, height: 50)
        XCTAssertEqual(size, expected)
    }

    func test_size_with_2_fixed_items_and_spacing() {
        struct FixedItem: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { .init(width: size.width, height: 20) }
        }
        let bounds = Size.square(100)
        let item1 = FixedItem()
        let item2 = FixedItem()
        let layout = VStackLayout(spacing: 10)
        let size = layout.sizeThatFits(items: [item1, item2], within: bounds)
        let expected = Size.init(width: 100, height: 50)
        XCTAssertEqual(size, expected)
    }

    func test_frames_of_2_fixed_items_and_spacing() throws {
        struct FixedItem: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { .square(20) }
        }
        let item1 = FixedItem()
        let item2 = FixedItem()
        let bounds = Rectangle(origin: .zero, size: .square(100))
        let layout = VStackLayout(spacing: 10)
        let frames = layout.frames(for: [item1, item2], within: bounds)

        XCTAssertEqual(frames.first!.x, 40)
        XCTAssertEqual(frames.first!.y, 0)
        XCTAssertEqual(frames.last!.x, 40)
        XCTAssertEqual(frames.last!.y, 30)
    }

    func test_frames_with_fixed_and_flexible_item() {
        struct FixedItem: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { .init(width: size.width, height: 25) }
        }
        struct FlexibleItem: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { size }
        }
        let bounds = Rectangle(origin: .zero, size: .square(100))
        let layout = VStackLayout()
        let items: [any LayoutItem] = [FixedItem(), FlexibleItem()]
        let frames = layout.frames(for: items, within: bounds)

        XCTAssertEqual(frames.first!.y, 0)
        XCTAssertEqual(frames.first!.height, 25)
        XCTAssertEqual(frames.last!.y, 25)
        XCTAssertEqual(frames.last!.height, 75)
    }

    func test_frames_with_flexible_and_fixed_item() {
        struct FixedItem: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { .init(width: size.width, height: 25) }
        }
        struct FlexibleItem: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { size }
        }
        let bounds = Rectangle(origin: .zero, size: .square(100))
        let layout = VStackLayout()
        let items: [any LayoutItem] = [FlexibleItem(), FixedItem()]
        let frames = layout.frames(for: items, within: bounds)

        XCTAssertEqual(frames.first!.y, 0)
        XCTAssertEqual(frames.first!.height, 75)
        XCTAssertEqual(frames.last!.y, 75)
        XCTAssertEqual(frames.last!.height, 25)
    }

    func test_frames_with_fixed_item_between_flexible_items() {
        struct FixedItem: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { .init(width: size.width, height: 30) }
        }
        struct FlexibleItem: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { size }
        }
        let bounds = Rectangle(origin: .zero, size: .square(100))
        let layout = VStackLayout()
        let items: [any LayoutItem] = [FlexibleItem(), FixedItem(), FlexibleItem()]
        let frames = layout.frames(for: items, within: bounds)

        XCTAssertEqual(frames[0].y, 0)
        XCTAssertEqual(frames[0].height, 35)
        XCTAssertEqual(frames[1].y, 35)
        XCTAssertEqual(frames[1].height, 30)
        XCTAssertEqual(frames[2].y, 65)
        XCTAssertEqual(frames[2].height, 35)
    }

    func test_frames_where_flexible_item_has_higher_priority_than_fixed_item() {
        struct FixedItem: LayoutItem {
            func sizeThatFits(_ size: Size) -> Size { .init(width: 30, height: 30) }
        }
        struct FlexibleItem: LayoutItem {
            var priority: Int { 1 }
            func sizeThatFits(_ size: Size) -> Size { size }
        }
        let bounds = Rectangle(origin: .zero, size: .square(100))
        let layout = VStackLayout()
        let items: [any LayoutItem] = [FlexibleItem(), FixedItem()]
        let frames = layout.frames(for: items, within: bounds)

        XCTAssertEqual(frames[0].y, 0)
        XCTAssertEqual(frames[0].width, 100)
        XCTAssertEqual(frames[0].height, 100)
        XCTAssertEqual(frames[1].y, 100)
        XCTAssertEqual(frames[1].width, 30)
        XCTAssertEqual(frames[1].height, 30)
    }
}
