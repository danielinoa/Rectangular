import XCTest
@testable import Rectangular

final class FrameLayoutTests: XCTestCase {

    func test_responsive_item_spans_entire_width_within_a_larger_frame() {
        let bounds = Size(width: 100, height: 100)
        let item = ResponsiveItem(width: 20)
        let layout = FrameLayout(width: 30)
        let size = layout.size(fitting: [item], within: bounds)

        let expectedWidth: Double = 30 // This comes from the layout's specified width
        let expectedHeight: Double = 1 // This comes from the item's height

        XCTAssertEqual(size.width, expectedWidth)
        XCTAssertEqual(size.height, expectedHeight)
    }

    func test_item_height_increases_as_frame_shrinks_item_width() {
        let bounds = Size(width: 100, height: 100)
        let item = ResponsiveItem(width: 20)
        let layout = FrameLayout(width: 10)
        let size = layout.size(fitting: [item], within: bounds)

        let expectedWidth: Double = 10 // This comes from the layout's specified width
        let expectedHeight: Double = 2 // This comes from the item's height

        XCTAssertEqual(size.width, expectedWidth)
        XCTAssertEqual(size.height, expectedHeight)
    }

    func test_max_width_is_clamped_up_to_bounds_width() {
        let bounds = Size(width: 100, height: 100)
        let item = ResponsiveItem(width: 20)
        let layout = FrameLayout(maximumWidth: .infinity)
        let size = layout.size(fitting: [item], within: bounds)

        let expectedWidth: Double = 100 // This comes from the layout clamping the width up to the bounds
        let expectedHeight: Double = 1 // This comes from the item's height

        XCTAssertEqual(size.width, expectedWidth)
        XCTAssertEqual(size.height, expectedHeight)
    }

    func test_overflowing_min_width_is_NOT_clamped_up_to_bounds_width() {
        let bounds = Size(width: 100, height: 100)
        let item = ResponsiveItem(width: 20)
        let layout = FrameLayout(minimumWidth: .infinity)
        let size = layout.size(fitting: [item], within: bounds)

        let expectedWidth: Double = .infinity // This comes from the layout clamping the width up to the bounds
        let expectedHeight: Double = 1 // This comes from the item's height

        XCTAssertEqual(size.width, expectedWidth)
        XCTAssertEqual(size.height, expectedHeight)
    }

    func test_item_with_width_larger_than_layout_minwidth_forces_layout_width_to_expand_beyond_minwidth() {
        let bounds = Size(width: 100, height: 100)
        let item = ResponsiveItem(width: 40)
        let layout = FrameLayout(minimumWidth: 20)
        let size = layout.size(fitting: [item], within: bounds)

        let expectedLayoutWidth: Double = 40 // Thsi comes from the item's width forcing the layout's width to expand
        let expectedLayoutHeight: Double = 1 // This comes from the item's height

        XCTAssertEqual(size.width, expectedLayoutWidth)
        XCTAssertEqual(size.height, expectedLayoutHeight)
    }
}
